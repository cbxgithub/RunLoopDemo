//
//  MyViewController.m
//  RunLoopDemo
//
//  Created by 贺廷濬 on 2017/11/21.
//  Copyright © 2017年 cbx. All rights reserved.
//

#import "MyViewController.h"

//定义一个任务
typedef void(^RunLoopTask)(void);

@interface MyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

//用来存放任务的数组
@property (nonatomic, strong) NSMutableArray<RunLoopTask> *tasks;
//最大任务数量
@property (nonatomic, assign) NSInteger maxTaskCount;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数据
    self.maxTaskCount = 24;
    self.tasks = [NSMutableArray array];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.tableView];
    
    [self addObserverToMainRunLoop];
    
    //添加一个timer到主线程，让runloop一直执行
    [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
       //timer里面什么也不做，只是为了唤醒runloop
    }];
}

//添加任务到数组
- (void)addTask:(RunLoopTask)task{
    
    [self.tasks addObject:task];
    
    //保证之前没来得及显示的图片不会再绘制
    if (self.tasks.count > _maxTaskCount) {
        [self.tasks removeObjectAtIndex:0];
    }
}

# pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 299;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    
    //添加任务
    [self addTask:^{
        UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timg2"]];
        imageView1.frame = CGRectMake(10, 10, 100, 80);
        [cell addSubview:imageView1];
    }];
    
    [self addTask:^{
        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timg2"]];
        imageView2.frame = CGRectMake(120, 10, 100, 80);
        [cell addSubview:imageView2];
    }];
    

    [self addTask:^{
        UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timg2"]];
        imageView3.frame = CGRectMake(230, 10, 100, 80);
        [cell addSubview:imageView3];
    }];
    
    return cell;
}

- (void)addObserverToMainRunLoop{
    //为runLoop添加观察者
    CFRunLoopObserverContext  runLoopObserverContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFRunLoopObserverRef    observer = CFRunLoopObserverCreate(NULL,//内存分配器，默认NULL
                                                               kCFRunLoopBeforeWaiting,//等待之前
                                                               YES,//是否循环
                                                               0,//优先索引，一般为0
                                                               &currentRunLoopObserver,//回调方法
                                                               &runLoopObserverContext//上下文
                                                               );
    if (observer)
    {
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    }
    CFRelease(observer);
}

// RunLoop监听回调
static void currentRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    MyViewController *vc = (__bridge MyViewController *)info;
    if (vc.tasks.count == 0) {
        return;
    }
    RunLoopTask task = vc.tasks.firstObject;
    task();
    [vc.tasks removeObjectAtIndex:0];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end
