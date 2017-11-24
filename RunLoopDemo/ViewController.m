//
//  ViewController.m
//  RunLoopDemo
//
//  Created by 贺廷濬 on 2017/11/17.
//  Copyright © 2017年 cbx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSPortDelegate>

@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CFRunLoopSourceContext context;


@end

/* Run Loop Source Context的三个回调方法，其实是C语言函数 */

// 当把当前的Run Loop Source添加到Run Loop中时，会回调这个方法。
void runLoopSourceScheduleRoutine (void *info, CFRunLoopRef runLoopRef, CFStringRef mode)
{
    NSLog(@"Input source被添加%@",[NSThread currentThread]);

}

// 当前Input source被告知需要处理事件的回调方法
void runLoopSourcePerformRoutine (void *info)
{
    NSLog(@"回调方法%@",[NSThread currentThread]);
}

// 如果使用CFRunLoopSourceInvalidate函数把输入源从Run Loop里面移除的话,系统会回调该方法。
void runLoopSourceCancelRoutine (void *info, CFRunLoopRef runLoopRef, CFStringRef mode)
{
    NSLog(@"Input source被移除%@",[NSThread currentThread]);
}

// RunLoop监听回调
void currentRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSString *activityDescription;
    switch (activity) {
        case kCFRunLoopEntry:
            activityDescription = @"kCFRunLoopEntry";
            break;
        case kCFRunLoopBeforeTimers:
            activityDescription = @"kCFRunLoopBeforeTimers";
            break;
        case kCFRunLoopBeforeSources:
            activityDescription = @"kCFRunLoopBeforeSources";
            break;
        case kCFRunLoopBeforeWaiting:
            activityDescription = @"kCFRunLoopBeforeWaiting";
            break;
        case kCFRunLoopAfterWaiting:
            activityDescription = @"kCFRunLoopAfterWaiting";
            break;
        case kCFRunLoopExit:
            activityDescription = @"kCFRunLoopExit";
            break;
        default:
            break;
    }
    NSLog(@"Run Loop activity: %@", activityDescription);
}

@implementation ViewController{
    CFRunLoopSourceRef runLoopSource;
    CFRunLoopRef runLoop;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化并开启，在线程内部开启它的runloop
    self.thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"这是一条子线程%@",[NSThread currentThread]);
        
        runLoop = CFRunLoopGetCurrent();
        
        //为runLoop添加自定义输入源
        [self addCustomInputSourceToRunLoop];
        //为runLoop添加观察者
        [self addObserverToRunLoop];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];

    }];
    [self.thread start];
    
    //添加一个timer到当前runloop
//    [self addTimerToCurrentRunLoop];
}

- (void)addTimerToCurrentRunLoop{
    //创建一个Timer
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"timer");
    }];
    
    //把它加到RunLoop里
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
}

- (void)addCustomInputSourceToRunLoop{
    
    //为runLoop添加自定义runLoopSource
    CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
        &runLoopSourceScheduleRoutine,
        &runLoopSourceCancelRoutine,
        &runLoopSourcePerformRoutine};
    
    //CFAllocatorRef内存分配器，默认NULL，CFIndex优先索引，默认0，CFRunLoopSourceContext上下文
    runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}

- (void)addObserverToRunLoop{
    //为runLoop添加观察者
    CFRunLoopObserverContext  runLoopObserverContext = {0, NULL,    NULL, NULL, NULL};
    CFRunLoopObserverRef    observer = CFRunLoopObserverCreate(NULL,//内存分配器，默认NULL
                                                               kCFRunLoopAllActivities,//所有状态
                                                               YES,//是否循环
                                                               0,//优先索引，一般为0
                                                               &currentRunLoopObserver,//回调方法
                                                               &runLoopObserverContext//上下文
                                                               );
    if (observer)
    {
        CFRunLoopAddObserver(runLoop, observer, kCFRunLoopDefaultMode);
    }
    CFRelease(observer);
}



- (void)test{
    NSLog(@"哈哈哈%@",[NSThread currentThread]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //通知自定义的InputSource
    [self wakeUpCustomInputSource];
}

- (void)wakeUpCustomInputSource{
    //通知InputSource
    CFRunLoopSourceSignal(runLoopSource);
    //唤醒runLoop
    CFRunLoopWakeUp(runLoop);
}

- (void)dealloc {
    CFRelease(runLoopSource);
}

@end
