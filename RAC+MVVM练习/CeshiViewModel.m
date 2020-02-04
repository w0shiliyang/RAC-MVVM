//
//  CeshiViewModel.m
//  RAC+MVVM练习
//
//  Created by 李洋 on 2020/2/4.
//  Copyright © 2020 李洋. All rights reserved.
//

#import "CeshiViewModel.h"
#import "CeshiNetwork.h"

@implementation CeshiViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        RACSignal * usernameSignal = [RACObserve(self, userName) map:^id _Nullable(NSString * value) {
            if (value.length >= 6) {
                return @(YES);
            }
            return @(NO);
        }];
        
        RACSignal * passwordSignal = [RACObserve(self, passWord) map:^id _Nullable(NSString * value) {
            if (value.length >= 6) {
                return @(YES);
            }
            return @(NO);
        }];
        
        RACSignal * buttonEnableSignal = [RACSignal combineLatest:@[usernameSignal, passwordSignal] reduce:^id(NSNumber * userName, NSNumber * password) {
            return @(userName.boolValue && password.boolValue);
        }];
        
        self.command = [[RACCommand alloc] initWithEnabled:buttonEnableSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [CeshiNetwork loginWithUsername:self.userName password:self.passWord];
        }];
    }
    return self;
}

@end


