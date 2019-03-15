//
//  ViewController.m
//  RAC_Study
//
//  Created by lxy on 2019/3/8.
//  Copyright © 2019年 lxy. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import "ModuleBViewController.h"
#import <RACReturnSignal.h>

static  NSString * const fflabeltTextNotification = @"ff_Notification";



@interface ViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *ffView;
@property (weak, nonatomic) IBOutlet UIButton *ffBtn;
@property (weak, nonatomic) IBOutlet UILabel *fflabel;
@property (weak, nonatomic) IBOutlet UITextField *ffField;


@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:fflabeltTextNotification object:nil];
    
#pragma mark --RAC用于代理
    ModuleBViewController * module = [[ModuleBViewController alloc] init];
    module.subject = [RACSubject subject];
    [module.subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"RACd代理反向传值 ：%@",x);
    }];
    [self presentViewController:module animated:YES completion:nil];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createRACmap];
    [self createRACflattenMap];
    [self createRACreduce];
  
}

#pragma mark --RAC绑定按钮事件
- (void)createRACbtnAction
{
    [[[[self.ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(__kindof UIControl * _Nullable x) {
        [self.ffBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }] map:^id _Nullable(__kindof UIControl * _Nullable value) {
        return @(NO);
    }] subscribeNext:^(id  _Nullable x) {
        self.ffBtn.backgroundColor = x ? [UIColor orangeColor] : [UIColor cyanColor];
    }];
}

#pragma mark --RAC手势
- (void)createGesture{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        NSLog(@"点击了ffLabel:%@",x);
    }];
    //这个。。。我y记得Xcode10之前是只有ImageView，不默认YES的。。加上就哦了
    _fflabel.userInteractionEnabled = YES;
    [_fflabel addGestureRecognizer:tap];
}


#pragma mark --RAC UIControlEvent事件
- (void)createBtnAction{
    [[_ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"FF 按钮事件");
    }];
    
    [[_ffBtn rac_signalForControlEvents:UIControlEventTouchDragInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        //实现内部拖动s事件的时候，最后还是回会调用 UIControlEventTouchUpInside 事件，我们可以创建一个变量 isDrag 控制其触发
        //实现内部拖动事件的话，按钮会在周围o有70px的扩展范围，如果需要禁止的话，重写按钮点击事件，取出事件点判断是否在当前按钮上CGRectContainPoint
        NSLog(@"FF 内部拖动事件");
    }];
}

#pragma mark --RAC文本框
- (void)createTextSignal{
    //    只要文本框中内容一产生变化，就会走这个block
    //    注意，这个值返回的是textField的内容而不是当前输入的值，
    [_ffField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"UITextField :%@",x);
    }];
    
    //按需状态去实现
    //UIControlEventEditingDidEndOnExit  return之后隐藏键盘
    [[_ffField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UITextField * field = x;
        //这里可以加校验，判断格式，field去显示
        if ([field.text containsString:@"h"]) {
            field.text = [field.text substringToIndex:field.text.length-1];
        }
        NSLog(@"x :%@",field.text);
    }];
}

#pragma mark --RAC通知
- (void)createNotification{
    //    takeUntil:[self rac_willDeallocSignal]释放通知
    //    信号的创建中只调用了sendNext:方法，没有调用sendError: sendCompleted方法，所以清理对象的清理方法不会调用。
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:fflabeltTextNotification object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"ff接到了通知 ： %@",x);
    }];
    
    //    当然发通知还是得我们进行
    //    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    //    {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:fflabeltTextNotification object:nil];
    //    }
}

#pragma mark --RAC 实现KVO监听属性
- (void)createRACKVO{
    //不指定options 会在  self.ffView.fram 之前之后都调用一遍
    [[_ffView rac_valuesForKeyPath:@"frame" observer:self] subscribeNext:^(id  _Nullable x) {
        
    }];
    //指定options 之后  self.ffView.fram 改变之后m，去其新值
    [[_ffView rac_valuesAndChangesForKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> * _Nullable x) {
        
        //        RACTwoTuple<__covariant First, __covariant Second>  元组
        //        这里我们取其第二个值里的new值
        
        NSLog(@"result NSRect : %@",x[1][@"new"]);
    }];
    
    self.ffView.frame = CGRectMake(0, 100, 300, 300);
}


#pragma mark --RAC alertView
- (void)createRAC_ActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机", @"相册", nil];
    [[self rac_signalForSelector:@selector(actionSheet:clickedButtonAtIndex:) fromProtocol:@protocol(UIActionSheetDelegate)] subscribeNext:^(RACTuple * tuple) {
        
        RACTupleUnpack(UIActionSheet *alert, NSNumber *index) = tuple;
        NSLog(@"alertView : %@------%@",alert, index);
    }];
    [sheet showInView:self.view];
}

#pragma mark --RAC alertView
- (void)createRACalertView
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"是否确认登录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //实现alertView的点击事件的delegate方法
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple * tuple) {
        //点击取消、确定按钮会到本block
        RACTupleUnpack(UIAlertView *alert, NSNumber *index) = tuple;
        
        if (index.intValue == 0) {
            
        }else{
            NSLog(@"alertView : %@------%@",alert, index);
        }
    }];
    [alertView show];
}

#pragma mark --RAC Timer
- (void)createRACTimer
{
    [[RACScheduler mainThreadScheduler] after:[NSDate dateWithTimeIntervalSinceNow:2.0] schedule:^{
        NSLog(@"延迟两秒执行:%@",[NSThread currentThread]);
        
    }];
    
    //作用在主线程的，会阻塞线程
    [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        //        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //        NSLog(@"%@",[formatter stringFromDate:x]);
        [NSThread sleepForTimeInterval:3];
        NSLog(@"还是每隔一秒执行么？");
    }];
}







#pragma mark --RACSequence RAC集合类
- (void)createRACSequence
{
//    RACSequence RAC中的集合类，可以用来快速遍历数组，字典！
//    RACTuple RAC中的元组类,类似NSArray,用来包装值
    
    NSArray * numbers = @[@"1",@"2",@"3",@"4"];
    [numbers.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"遍历 ：%@",x);
    }];
    
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来
    
    
    NSDictionary *dict = @{@"name":@"张旭",@"age":@24};
//    遍历字典,遍历出来的键值对会包装成RACTuple(元组对象
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"RACTuple = %@",x);
//    解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"%@ %@",key,value);
    }];
}


#pragma mark --RACReplaySubject RAC信号类的子类
- (void)createReplaySubject
{
    
//    RACSubject的子类
//    可以发现不同的是
//    当  先发送 后订阅  得到的打印结果是，先走两遍第一个订阅者，再走两遍第二个订阅者
//    当  先订阅 后发送  得到的打印结果是z按照订阅者的顺序来的，也就是，第一个发送把所有订阅者走完之后开始走第二个发送者
    
    RACReplaySubject * replaySubject = [RACReplaySubject subject];

    [replaySubject sendNext:@1314];
    [replaySubject sendNext:@1315];
    
    [replaySubject subscribeNext:^(id  _Nullable x) {
         NSLog(@"第一个订阅者 %@",x);
    }];
    
    [replaySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二个订阅者 %@",x);
    }];
    
    
}
#pragma mark --RAC信号类
- (void)createRACSubject
{
    
//    RACSubject 信号类，它可以自己充当信号，又能发送信号
//    RACSubject 信号类，只能是先订阅信号，再发送信号

//  RACSubject信号类是可以代替代理的
    
    RACSubject * subject = [RACSubject subject];
    
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"第一个订阅者 %@",x);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二个订阅者 %@",x);
    }];
    
    [subject sendNext:@520];
    [subject sendNext:@521];
}


#pragma mark --RAC信号量
- (void)createRACSignal{
    RACSignal * single = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"创建信号");
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
    
    //    1：RACSiganl（信号类）只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者subscriber去发出。
    //
    //    2：默认一个信号都是冷信号，就算是值改变了，但你没有订阅这个信号的话它也不会触发的，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发
}


#pragma mark __RACz常用的d宏定义

- (void)createRACDefine
{
    @weakify(self)//1、防止循环引用，类似__weak typeof(self)waekSelf = self;
    [_ffField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        
        @strongify(self)
        self.ffField.text = x;
        
    }];
    
    
    
    //   1
    // 用来给某个对象的某个属性绑定信号,只要产生信号内容,就会把内容给属性赋值
    RAC(_fflabel,text) = _ffField.rac_textSignal;
    
    //监听fflabel里的b内容变化.此处的内容变化，我们有ffField引起
    
    [RACObserve(_fflabel,text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"ffLabel text属性的值：%@",x);
        
    }];
    
    
    //2、把数据包装成RACTuple（元组类）
    RACTuple * tuple = RACTuplePack(@"互联运力真优秀",@2);
    NSLog(@"----- %@",tuple[0]);
    
//    把RACTuple（元组类）解包成对应的数据。
    RACTupleUnpack(NSString * str,NSNumber * value) = tuple;
    NSLog(@"--name: %@--- value:%@",str,value);
    
}

#pragma mark -- flattenMap
- (void)createRACflattenMap
{
    //    flattenMap：映射，取到信号源的值，映射成一个新的信号，返回出去！！
    //    开发中，如果信号发出的值是信号，映射就使用FlatternMap
    RACSignal * signal = [_ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[[_ffField rac_textSignal] flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        
        value = [NSString stringWithFormat:@"数据处理: %@",value];
        
        return [RACReturnSignal return:value];
        //        return [RACReturnSignal return:value];
        return nil;
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
        
    }];
    
}

#pragma mark -- map
- (void)createRACmap
{
    
    //     map：映射，取到监听后的值，映射成一个新值，返回出去！！
    [[[_ffField rac_textSignal] map:^id _Nullable(NSString * _Nullable value) {
        
        return @(value.length > 0);
        
    }] subscribeNext:^(id  _Nullable x) {
        
        self.ffView.hidden = [x boolValue];
        
    }];
}


#pragma mark -- reduce
- (void)createRACreduce
{
    //    reduce：把元祖里的值分别都取出来，然后对这些值做一些操作，再合成一个值返回出去
    RACSignal * signal = [_ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[RACSignal combineLatest:@[_ffField.rac_textSignal,signal] reduce:^id _Nullable(NSString * value){
        return @(value.length>0);
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark -- distinctUntilChanged
- (void)createRACdistinctUntilChanged{
    //    distinctUntilChanged：监听的值有明显变化时，才会发出信号
    //    beginEdit 什么的信号都会屏蔽掉
    [[[_ffField rac_textSignal] distinctUntilChanged] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- ignore
- (void)createRACignore{
    //    这个忽略的不是输入的3，而是field的内容为3的时候，忽略掉信号
    [[[_ffField rac_textSignal] ignore:@"3"] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
}


#pragma mark -- filter
- (void)createRACfilter{
    //    filter：过滤信号，return 满足条件的信号。
    [[[_ffField rac_textSignal] filter:^BOOL(NSString * _Nullable value) {
        return [value integerValue] % 2 == 0;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- takeLast
- (void)createRACtakeLast{
    //    takeLast：取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号，然后取最后N次的信号！！
    RACSubject * subject = [RACSubject subject];
    [[subject takeLast:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"one"];
    [subject sendNext:@"two"];
    [subject sendNext:@"three"];
    [subject sendCompleted];
}


#pragma mark -- take
- (void)createRACtake
{
    //    take：从开始一共取N次的信号
    //    你点击按钮的前三次，都会有打印，第四次开始就不会再打印了
    RACSignal *signalBtn = [_ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[signalBtn take:3] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- merge
- (void)createRACmerge
{
    //    RAC merge 捆绑法。不分先后，谁事件调用打印谁
    RACSignal * signal = [_ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    [[_ffField.rac_textSignal merge:signal] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark --zipWith
- (void)createRACzipWith{
    
    //    zipWith：把两个信号压缩成一个信号，且必须两个信号都触发了（同次数），才会打印。两个信号的值，会合并成一个元组。
    RACSignal *signalBtn = [_ffBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[[_ffField rac_textSignal] zipWith:signalBtn] subscribeNext:^(RACTwoTuple<NSString *,id> * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
}

#pragma mark -- concat
- (void)createRACconcat{
    //    concat：按顺序拼接信号，按顺序接收信号，但是必须等上一个信号完成，下一个信号才有用！！！
    //    signalTwo必须得是在x第一个信号调用sendConpleted之后
    RACSignal *signalOne = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"下载"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalTwo = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"解压"];
        return nil;
    }];
    [[signalOne concat:signalTwo] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
        //先打印下载，后打印解压
    }];
    
}


#pragma mark -- then
- (void)createRACthen{
    //    concat：按顺序拼接信号，按顺序接收信号，但是必须等上一个信号完成，下一个信号才有用！！！
    //    signalTwo必须得是在x第一个信号调用sendConpleted之后
    RACSignal *signalOne = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"下载"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalTwo = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"解压"];
        return nil;
    }];
    
    [[signalOne then:^RACSignal * _Nonnull{
        return signalTwo;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    
}

@end
