//
//  ViewController.m
//  RAC_Study
//
//  Created by lxy on 2019/3/8.
//  Copyright © 2019年 lxy. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
@interface ViewController ()

@property (nonatomic, copy) NSString * (^BBLOCK)(id qqq);
@end

@implementation ViewController

- (void)qqq:(NSString * (^)(id qqq))block{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    RACSignal * single = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //subsciber 是订阅者，是一个协议，不是一个类
        [subscriber sendNext:@3];
        //发送完成
        [subscriber sendCompleted];

        //RACDisaposable 用于取消订阅h或者清理资源，当信号发送完成或者发送错误时候，就会自动触发
        //执行完Block之后，当前信号就不再被订阅了
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁了");
        }];
    }];
    
    //singlex信号类调用subscribeNext方法订阅信号，订阅之后才会激活这个信号，注意顺序
    [single subscribeNext:^(id  _Nullable x) {
        NSLog(@"得到了数据： %@",x);
    }];
}


@end
