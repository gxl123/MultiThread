//
//  ViewController.m
//  MultiThread
//
//  Created by tommy on 15/11/10.
//  Copyright © 2015年 gxl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     NSLog(@"==============主线程%@",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *创建串行队列
 */
- (void)createSerialQueue {
    dispatch_queue_t queue = dispatch_queue_create("sq1", DISPATCH_QUEUE_SERIAL); // 创建
    dispatch_async(queue, ^{
        for(int i=0; i<10;i++)
            NSLog(@"异步串行队列sq1----所在线程%@,i=%d",[NSThread currentThread],i);
    });
    dispatch_async(queue, ^{
        for(char j='a'; j<'n';j++)
            NSLog(@"异步串行队列sq1----所在线程%@,j=%c",[NSThread currentThread],j);
    });
    
    dispatch_queue_t queue2 = dispatch_queue_create("sq2", DISPATCH_QUEUE_SERIAL); // 创建
    dispatch_async(queue2, ^{
        for(char k=0; k<10;k++)
            NSLog(@"异步串行队列sq2----所在线程%@，k=%d",[NSThread currentThread],k);
    });
    //dispatch_release(queue); // 非ARC需要释放手动创建的队列
}
/**
 *执行全局并行队列
 */
- (void)ExcuteGrobalConcurrentQueue{
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for(int i=0; i<10;i++)
            NSLog(@"全局并行队列任务1----所在线程%@,i=%d",[NSThread currentThread],i);
    });
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for(char j='a'; j<'n';j++)
            NSLog(@"全局并行队列任务2----所在线程%@,j=%c",[NSThread currentThread],j);
    });
}

- (IBAction)clickedSerialQueue:(id)sender {
    [self createSerialQueue];
}

- (IBAction)clickedGrobalQueue:(id)sender {
    [self ExcuteGrobalConcurrentQueue];
}
/**dispatch_group_async可以实现监听一组任务是否完成，完成后得到通知执行其他的操作。这个方法很有用，比如你执行三个下载任务，
 *当个任务都下载完成后你才通知界面说完成的了
 */
- (IBAction)clickedGroupAsync:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"group1----所在线程%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"group2----所在线程%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"group3----所在线程%@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"updateUi----所在线程%@",[NSThread currentThread]);
    });
    //dispatch_release(group);
}
/**dispatch_barrier_async是在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
 *注意：必须用DISPATCH_QUEUE_CONCURRENT，不能用dispatch_get_global_queue
 */
- (IBAction)clickedBarrierAsync:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("q1", DISPATCH_QUEUE_CONCURRENT);
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_async1----所在线程%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:4];
        NSLog(@"dispatch_async2----所在线程%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async----所在线程%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
        
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async3----所在线程%@",[NSThread currentThread]);
    });
}
/**
 *执行某个代码片段N次。
 */
- (IBAction)clickedApply:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(5, queue, ^(size_t index) {
        // 执行5次
        NSLog(@"copy-%ld", index);
        for(int i=0; i<10;i++)
            NSLog(@"并行队列任务----所在线程%@,i=%d,index=%zu",[NSThread currentThread],i,index);
    });
}

- (IBAction)clickedOnce:(id)sender {
    //self.sharedInstance
    
}

- (IBAction)clickedTime:(id)sender {
    // 延迟2秒执行：
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // code to be executed on the main queue after delay
    });

}
/**synchronized实现线程同步
 *类似与NSLock、NSCondition
 */
- (IBAction)clickedSynch:(id)sender {
    __block int i=100;
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      //  @synchronized(self) {
            while(i>0)
                NSLog(@"全局并行队列任务1----所在线程%@,i=%d",[NSThread currentThread],i--);
     //   }
    });
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
     //    @synchronized(self) {
             while(i>0)
                 NSLog(@"全局并行队列任务1----所在线程%@,i=%d",[NSThread currentThread],i--);
     //    }
    });
}

/**
 *一次性执行，一般用于单例模式
 */
+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{ sharedInstance = [[self alloc] init]; }); return sharedInstance;
}
@end
