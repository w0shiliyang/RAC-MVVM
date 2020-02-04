//
//  CeshiViewModel.h
//  RAC+MVVM练习
//
//  Created by 李洋 on 2020/2/4.
//  Copyright © 2020 李洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface CeshiViewModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *passWord;
@property (nonatomic, strong) RACCommand *command;



@end

NS_ASSUME_NONNULL_END
