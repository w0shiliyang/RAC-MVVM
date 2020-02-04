//
//  CeshiViewController.m
//  RAC+MVVM练习
//
//  Created by 李洋 on 2020/2/1.
//  Copyright © 2020 李洋. All rights reserved.
//

#import "CeshiViewController.h"
#import <ReactiveObjC.h>
#import "CeshiViewModel.h"

@interface CeshiViewController ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) CeshiViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeView;

@end

@implementation CeshiViewController

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activeView.hidden = YES;
    
    RAC(self.viewModel, userName) = self.userNameTextField.rac_textSignal;
    RAC(self.viewModel, passWord) = self.passWordTextField.rac_textSignal;
    self.btn.rac_command = self.viewModel.command;
    __weak typeof(self) weakself = self;
    
//    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        weakself.activeView.hidden = NO;
//        [[weakself.viewModel.command executionSignals] subscribeNext:^(id  _Nullable x) {
//            weakself.activeView.hidden = YES;
//        }];
//    }];
    
    [[self.viewModel.command executionSignals] subscribeNext:^(RACSignal * x) {
        weakself.activeView.hidden = NO;
        [x subscribeNext:^(id  _Nullable x) {
            weakself.activeView.hidden = YES;
        }];
    }];
    
}

- (CeshiViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CeshiViewModel alloc] init];
    }
    return _viewModel;
}
@end
