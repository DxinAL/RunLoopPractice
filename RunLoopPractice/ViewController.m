//
//  ViewController.m
//  RunLoopPractice
//
//  Created by D.xin on 2016/11/7.
//  Copyright © 2016年 D.xin. All rights reserved.
//


/*
    1 :运行循环
    
     2 多线程的三种操作方式
   
     3 总结
 
 
    NSOperation是对GCD面向对象层面的封装
 
 
 */
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(runs) object:nil];
    [invocation start];
    
    
    //NSBlockOperation
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //此处是在主线程中执行
        NSLog(@"%@",[NSThread currentThread]);
    }];
    
    //添加额外的子任务，在子线程中执行
    [op  addExecutionBlock:^{
        
        //在子线程中执行的
        NSLog(@"%@",[NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
       
        //在子线程中执行
    }];
    [op start];
    
    
    //将NSOperation添加到NSOperationQueue中就会异步执行  系统也会自动执行NSOperation中的操作
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:op];
    
    
    //设置最大的并发数
    queue.maxConcurrentOperationCount = 2;//设置成1 就变成了串行的队列
    [op addDependency:invocation];//invacation执行完之后才能执行op
    
    
    //线程之间的通讯
    //场景：在子线程加载图片，然后回到主线程更新UI
    [[[NSOperationQueue alloc]init]addOperationWithBlock:^{
        
        NSURL *url = [NSURL URLWithString:@"www.baidu.com"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage  *image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            //回到主线程更新UI
            UIImageView *imageView;
            imageView.image = image;
        }];
    }];
    
    //监听一个操作的执行
    op.completionBlock = ^(){
        NSLog(@"本操作执行完毕");
    };
    
    
    
    
}


-(void)runs{
    //开启strat并不会开启一个新的线程，而是在当前的线程中同步执行
    //只有在放进NSOperationQueue中的时候才会一步执行
    NSLog(@"%@",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
