//
//  YHKeyBoardView.m
//  YHKeyboard
//
//  Created by 我叫MT on 16/8/24.
//  Copyright © 2016年 Pinksnow. All rights reserved.
//

#import "YHKeyBoardView.h"

@interface YHKeyBoardView ()<UITextViewDelegate>
@property(nonatomic, assign)CGFloat keyboardHeight;
@property(nonatomic, strong)UIActivityIndicatorView *activeIndicator;
@property(nonatomic, strong)UIVisualEffectView *frontView;
@property(nonatomic,strong)UILabel *label;

@end
@implementation YHKeyBoardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatMyTextView];
    }
    return self;
}

-(void)creatMyTextView
{
    self.bgView = [[UIView alloc]init];
    [self addSubview:self.bgView];
    self.bgView.backgroundColor = [UIColor magentaColor];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(44);
    }];
    self.cancelBtn = [[UIButton alloc]init];
    [self.bgView addSubview:self.cancelBtn];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(hideKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
//    [[self.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
//        
//    }];
    
    self.cancelBtn.backgroundColor = [UIColor yellowColor];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(60);
    }];
    
    self.enterBtn = [[UIButton alloc]init];
    [self.bgView addSubview:self.enterBtn];
    [self.enterBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.enterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.enterBtn.backgroundColor = [UIColor greenColor];
    [self.enterBtn addTarget:self action:@selector(sendTextViewMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(60);
    }];
    self.textView = [[UITextView alloc]init];
    [self.bgView addSubview:self.textView];
    self.textView.backgroundColor = [UIColor whiteColor];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cancelBtn.mas_right).offset(5);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.enterBtn.mas_left).offset(-5);
        make.bottom.mas_equalTo(0);
    }];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.scrollEnabled = NO;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.textColor = [UIColor blackColor];
    self.textView.delegate = self;
    
    /**
     添加加载菊花
     */
    self.activeIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat x = self.bounds.size.width *0.5;
    CGFloat y = self.bounds.size.height *0.3;
    self.activeIndicator.center =CGPointMake(x,y);
    [self addSubview:self.activeIndicator];
    self.activeIndicator.color = [UIColor blackColor];
    [self.activeIndicator setHidesWhenStopped:YES];
    
    

}

@end
