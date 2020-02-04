//
//  CeshiNetwork.m
//  RAC+MVVM练习
//
//  Created by 李洋 on 2020/2/4.
//  Copyright © 2020 李洋. All rights reserved.
//

#import "CeshiNetwork.h"

@implementation CeshiNetwork

+ (RACSignal *)loginWithUsername:(NSString *)userName password:(NSString *)password {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext: @"isOK"];
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

@end
