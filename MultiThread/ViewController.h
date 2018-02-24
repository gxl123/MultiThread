//
//  ViewController.h
//  MultiThread
//
//  Created by tommy on 15/11/10.
//  Copyright © 2015年 gxl. All rights reserved.
//
/**GCD用来做耗时的操作
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSURL * url = [NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
    NSData * data = [[NSData alloc]initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc]initWithData:data];
    if (data != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    }
});
 */
/**dispatch_group_async
*可以实现监听一组任务是否完成，完成后得到通知执行其他的操作。这个方法很有用，比如你执行三个下载任务，当三个任务都下载完成后你才通知界面说完成的了。下面是一段例子代码：
*/

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


- (IBAction)clickedSerialQueue:(id)sender;
- (IBAction)clickedGrobalQueue:(id)sender;
+ (id)sharedInstance ;
@end

