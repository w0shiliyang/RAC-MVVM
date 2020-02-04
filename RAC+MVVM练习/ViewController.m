//
//  ViewController.m
//  RAC+MVVM练习
//
//  Created by 李洋 on 2020/1/7.
//  Copyright © 2020 李洋. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import <RACReturnSignal.h>

@protocol AAA;

@interface CeshiAAA : NSObject
@property (nonatomic, copy) NSString *name1;
@property (nonatomic, weak) id<AAA> delegate;
@end

@implementation CeshiAAA

@end

@protocol AAA <NSObject>
- (void)logA:(id)obj1 B:(id)objB;
@end


@interface ViewController ()<AAA>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, copy) NSString *name;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic, strong) CeshiAAA *ceshiA;

@property (nonatomic, strong) NSMutableArray * arr;

+ (void)abc:(NSString *)aaa;

@property (nonatomic, strong) RACDisposable *disposable1;

@property (nonatomic, strong) RACSignal *signal1;
@property (nonatomic, strong) RACSignal *signal2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - notification
- (void)aa:(NSNotification *)notifi {
    NSLog(@"%@",notifi.object);
}

#pragma mark - 基本使用
/// UI基本使用 button textfield
- (void)UIActionRAC {
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [self.textfield.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    /// 隐射
    [[self.textfield.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        NSLog(@"value = %@",value);
        return [RACReturnSignal return:[NSString stringWithFormat:@"+86%@",value]];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"逻辑：%@",x);
    }];
    
    // 过滤 YES才会发信号，no不发
    [[self.textfield.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        if (value.length > 6) {
            self.textfield.text = [value substringToIndex:6];
        }
        return value.length <= 6;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"x = %@",x);
    }];
}
/// delegate
- (void)delegateRAC {
    [[self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"fromProtocol: %@",x);
    }];
    self.textfield.delegate = self;
}
/// notification
- (void)notificationRAC {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"a" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"a" object:@"a"];
}
/// kvo 监听属性
- (void)KVORAC {
    [RACObserve(self, name) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    self.name = @"123";
    
    [[self rac_valuesForKeyPath:@"name" observer:self] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    /// 此处RAC宏相当于让label订阅了textield的文本变化信号
    /// 赋值给label的text属性
    RAC(self.label, text) = self.textfield.rac_textSignal;
}
/// array dictionary
- (void)sequenceRAC {
    NSArray * arr = @[@"1",@"2",@"3",@"4"];
    [arr.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    NSDictionary * dic = @{@"name":@"co",@"2":@"4"};
    [dic.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
/// RACSignal
- (void)racSignal {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 发送信号
        [subscriber sendNext:@"123"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribe:%@", x);
    }];
}
/// 定时器
- (void)timerSignal {
    self.disposable1 = [[RACSignal interval:1 onScheduler: [RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"时间：%@",x);
//        [weakself.disposable1 dispose];
    }];
    
    /// 延时2秒
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"延时2秒"];
        return nil;
    }] delay:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"--> %@",x);
    }];
}
/// 既是信号又可以发信号
- (void)racSubject {
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"");
    }];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"1");
    }];
    [subject sendNext: @"1"];
}
/// RACMulticastConnection 用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block
- (void)racMulticastConnection {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signal1-->🍺🍺🍺🍺🍺🍺🍺"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal1销毁了");
        }];
    }];
    
    RACMulticastConnection *connection = [signal1 publish];
    
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext-->1");
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext-->2");
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext-->3");
    }];
    [connection connect];
}
/// RACCommand -- 可以监听信号的状态等
- (void)racCommand {
    NSString *input = @"执行";
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input-->%@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"🍺🍺🍺🍺🍺🍺🍺"];
            [subscriber sendError:[NSError errorWithDomain:@"error" code:-1 userInfo:nil]];
//            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"signal销毁了");
            }];
        }];
    }];
    [command.executionSignals subscribeNext:^(RACSignal   * _Nullable x) {
        NSLog(@"executionSignals-->%@",x);
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"executionSignals-->subscribeNext-->%@",x);
        }];
    }];
    [command.executionSignals subscribeNext:^(RACSignal   * _Nullable x) {
        NSLog(@"111-->%@",x);
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"222-->subscribeNext-->%@",x);
        }];
    }];
    [[command.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchToLatest-->%@",x);
    }];
    [command.executing subscribeNext:^(id  _Nullable x) {
        NSLog(@"executing-->%@",x);
    }];
    [command.errors subscribeNext:^(id  _Nullable x) {
        NSLog(@"errors-->%@",x);
    }];
    //开始执行
    [command execute:input];
}

#pragma mark - 两个信号的处理
/// 1.0 初始化两个信号
- (void)twoSignalInit {
    self.signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       [subscriber sendNext:@"signal1-->🍺🍺🍺🍺🍺🍺🍺"];
       [subscriber sendCompleted];
       return [RACDisposable disposableWithBlock:^{
           NSLog(@"signal1销毁了");
       }];
    }];
    self.signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       [subscriber sendNext:@"signal2-->🍺🍺🍺🍺🍺🍺🍺"];
       [subscriber sendCompleted];
       return [RACDisposable disposableWithBlock:^{
           NSLog(@"signal2销毁了");
       }];
    }];
}
/// 1.1、 concat -- 当多个信号发出的时候，有顺序的接收信号
- (void)concatSignal {
    [self twoSignalInit];
    RACSignal *signal3 = [self.signal1 concat:self.signal2];
    [signal3 subscribeNext:^(id  _Nullable x) {
        NSLog(@"signal3-->%@",x);
    }];
}
/// 1.2、 combineLatestWith -- 将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号(订阅者每次接收的参数都是所有信号的最新值),不论触发哪个信号都会触发合并的信号
- (void)combineLatestWith {
    [self twoSignalInit];
    RACSignal *signal3 = [self.signal1 combineLatestWith:self.signal2];
    [signal3 subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
/// 1.3、 then -- 用于连接两个信号，等待第一个信号完成，才会连接then返回的信号
- (void)thenAction {
    [self twoSignalInit];
    RACSignal *signal3 = [self.signal1 then:^RACSignal * _Nonnull{
        return self.signal2;
    }];
    [signal3 subscribeNext:^(id  _Nullable x) {
        NSLog(@"signal3-->%@",x);
    }];
}
/// 1.4、 merge -- 把多个信号合并为一个信号来监听，任何一个信号有新值的时候就会调用
/// 一个信号signal3去监听signal1和signal2，每次回调一个信号
- (void)merge {
    [self twoSignalInit];
    RACSignal *signal3 = [self.signal1 merge:self.signal2];
    [signal3 subscribeNext:^(id  _Nullable x) {
        NSLog(@"signal3-->%@",x);
    }];
}
/// 1.5、 zipWith -- 把两个信号压缩成一个信号，只有当两个信号都发出信号内容时，才会触发
/// 一个信号signal3去监听signal1和signal2，但必须两个信号都有发出（不需要同时，例如signal1信号发出了，signal2信号等了10秒之后发出，那么signal3的订阅回调是等signal2信号发出的那一刻触发）
- (void)zipWith {
    [self twoSignalInit];
    RACSignal *signal3 = [self.signal1 zipWith:self.signal2];
    [signal3 subscribeNext:^(id  _Nullable x) {
        NSLog(@"signal3-->%@",x);
    }];
}
/// 1.6、 combineLatest reduce 聚合 -- 把多个信号的值按照自定义的组合返回
- (void)combineLatest {
    [self twoSignalInit];
    RACSignal *signal3 = [RACSignal combineLatest:@[self.signal1,self.signal2] reduce:^id(NSString *s1 ,NSString *s2){
        return [NSString stringWithFormat:@"%@ %@",s1,s2];
    }];
    [signal3 subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/// 其他 两个信号合并，
- (void)twoSignalCombine {
    RACSignal *signalA = self.textfield.rac_textSignal;
    RACSignal *signalB = [self.btn rac_signalForControlEvents:UIControlEventTouchUpInside];
        
    [[RACSignal combineLatest:@[signalA, signalB] reduce:^id (id valueA, id valueB) {
        return [NSString stringWithFormat:@"%@---%@", valueA, valueB];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

/// 2、flattenMap & map 映射
/// flattenMap 的底层实现是通过bind实现的
/// map 的底层实现是通过 flattenMap 实现的
- (void)mapFlattenMap {
    //map事例
    [[self.textfield.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return [NSString stringWithFormat:@"%@🍺🍺🍺🍺🍺🍺🍺",value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"-->%@",x);
    }];
    
    //flattenMap事例
     [[self.textfield.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:[NSString stringWithFormat:@"%@🍺🍺🍺🍺🍺🍺🍺",value]];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^(){}];
        }];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"-->%@",x);
    }] ;
}

#pragma mark - getter and setter
- (CeshiAAA *)ceshiA {
    if (!_ceshiA) {
        _ceshiA = [[CeshiAAA alloc] init];
        _ceshiA.delegate = self;
        _ceshiA.name1 = @"123";
    }
    return _ceshiA;
}

@end
