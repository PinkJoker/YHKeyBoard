//
//  ViewController.m
//  YHKeyboard
//
//  Created by 我叫MT on 16/8/24.
//  Copyright © 2016年 Pinksnow. All rights reserved.
//

#import "ViewController.h"

#define kHeight   [UIScreen mainScreen].bounds.size.height
#define kWidth   [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UITextViewDelegate>


//接口
@property(nonatomic, assign)CGFloat BgViewHeight;

@property(nonatomic, assign)CGFloat keyboardHeight;
@property(nonatomic, strong)UIActivityIndicatorView *activeIndicator;
@property(nonatomic, strong)UIVisualEffectView *frontView;

@property(nonatomic,strong)UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
  
    [self loadMyView];
    [self addObserverWithNotification];
    self.keyboardHeight = 0;//初始键盘高度
}
/**
 *  监听系统键盘事件
 *
 */
-(void)addObserverWithNotification
{

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handilKeyBoardHiden:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleKeyBoardAction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleKeyBoardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)loadMyView
{
    self.button = [[UIButton alloc]init];
    [self.view addSubview:self.button];
    [self.button setTitle:@"发表评论" forState:UIControlStateNormal];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(50);
    }];
    self.button.backgroundColor = [UIColor orangeColor];
    [self.button addTarget:self action:@selector(touchButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.bgView = [[UIView alloc]init];
    [self.view addSubview:self.bgView];
    self.bgView.backgroundColor = [UIColor magentaColor];
//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(44);
//        make.bottom.mas_equalTo(44);
//    }];
    self.bgView.frame = CGRectMake(0,kHeight - 49, kWidth, 49);
    self.cancelBtn = [[UIButton alloc]init];
    [self.bgView addSubview:self.cancelBtn];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(hideKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.backgroundColor = [UIColor yellowColor];
    self.cancelBtn.frame = CGRectMake(0, 10, self.bgView.bounds.size.width * 0.2, 30);
//    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(5);
//        make.top.mas_equalTo(5);
//        make.height.mas_equalTo(35);
//        make.width.mas_equalTo(60);
//    }];
    
    self.enterBtn = [[UIButton alloc]init];
    [self.bgView addSubview:self.enterBtn];
    [self.enterBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.enterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.enterBtn.backgroundColor = [UIColor greenColor];
    [self.enterBtn addTarget:self action:@selector(sendTextViewMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.enterBtn.frame = CGRectMake(kWidth - self.cancelBtn.bounds.size.width, 10, self.cancelBtn.bounds.size.width, self.cancelBtn.bounds.size.height);
//    [self.enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-5);
//        make.top.mas_equalTo(5);
//        make.height.mas_equalTo(35);
//        make.width.mas_equalTo(60);
//    }];
    self.textView = [[UITextView alloc]init];
    [self.bgView addSubview:self.textView];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.frame = CGRectMake(self.cancelBtn.bounds.size.width+5, 0, self.bgView.bounds.size.width - self.cancelBtn.bounds.size.width * 2 +10, self.bgView.bounds.size.height);
//    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.cancelBtn.mas_right).offset(5);
//        make.top.mas_equalTo(0);
//        make.right.mas_equalTo(self.enterBtn.mas_left).offset(-5);
//        make.bottom.mas_equalTo(0);
//    }];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.scrollEnabled = NO;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.textColor = [UIColor blackColor];
  //  self.textView.text = @"要显示的文本内容";
    self.textView.delegate = self;
    
    /**
     添加加载菊花
     */
    self.activeIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat x = self.view.bounds.size.width *0.5;
    CGFloat y = self.view.bounds.size.height *0.3;
    self.activeIndicator.center =CGPointMake(x,y);
    [self.view addSubview:self.activeIndicator];
    self.activeIndicator.color = [UIColor blackColor];
    [self.activeIndicator setHidesWhenStopped:YES];
    
    
    
}
//懒加载蒙版
-(UIVisualEffectView *)frontView
{
    if (!_frontView) {
        _frontView = [[UIVisualEffectView alloc]initWithFrame:CGRectMake(0, 0, sWidth, sHeight-self.keyboardHeight-44)];
        _frontView.backgroundColor = [UIColor grayColor];
        _frontView.alpha = 0.2;
        _frontView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideFrontView)];
        [_frontView addGestureRecognizer:tap];
    }
    return _frontView;
}
//手势点击蒙版回收键盘
-(void)hideFrontView
{
    [self.activeIndicator stopAnimating];
    [self.textView resignFirstResponder];
    [self.bgView removeFromSuperview];
    [self.textView removeFromSuperview];
    self.textView = nil;
}

/**
 *      取消按钮
 *
 *  @param sender
 */
-(void)hideKeyBoard:(UIButton *)sender
{
    [self.activeIndicator stopAnimating];
    [self.textView resignFirstResponder];
    [self.bgView removeFromSuperview];
    [self.textView removeFromSuperview];
    self.textView = nil;
}
/**
 *  发送按钮
 *
 *  @param sender <#sender description#>
 */
-(void)sendTextViewMessage:(UIButton *)sender
{
    [self.activeIndicator startAnimating];
    /**
     *  模仿发送内容
     *
     *  @return self.textView.text
     */
    weakSelf(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.activeIndicator stopAnimating];
        [weakSelf.textView resignFirstResponder];
        [weakSelf.bgView removeFromSuperview];
        [weakSelf.textView removeFromSuperview];
        weakSelf.textView = nil;
        NSLog(@"内容发送成功");
    });
    
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"结束");
}

-(void)touchButton
{
    _frontView.frame = CGRectMake(0, 0, sWidth, sHeight-self.keyboardHeight-44);
    [self loadMyView];
    [self.textView becomeFirstResponder];
}

-(void)handleKeyBoardChangeFrame:(NSNotification *)notification
{
    NSLog(@",改变");
    CGRect rect = [notification.userInfo[UIKeyboardIsLocalUserInfoKey]CGRectValue];
    NSLog(@"%@",NSStringFromCGRect(rect));
}
//监听系统键盘的弹出 通过masonry更改布局
-(void)handilKeyBoardHiden:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue] ;
    self.keyboardHeight = rect.size.height ;
    NSLog(@"%lf",self.keyboardHeight);
    weakSelf(weakSelf);
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.bgView.transform = CGAffineTransformMakeTranslation(0, -self.keyboardHeight );
        NSLog(@"%@",  NSStringFromCGRect(self.bgView.bounds));
//        self.textView.transform = CGAffineTransformMakeTranslation(0, -self.keyboardHeight );
//        self.button.transform = CGAffineTransformMakeTranslation(0, -self.keyboardHeight );
//        self.cancelBtn.transform = CGAffineTransformMakeTranslation(0, -self.keyboardHeight );
        
    } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.frontView];
    }];
//    [UIView animateWithDuration:duration animations:^{
//        [weakSelf.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(-weakSelf.keyboardHeight);
//        }];
//
//    }];
}
//监听系统键盘的弹出 通过masonry更改布局
-(void)handleKeyBoardAction:(NSNotification *)notification
{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
//    CGFloat height = frame.size.height;
    weakSelf(weakSelf);
//    [UIView animateWithDuration:duration animations:^{
//        [weakSelf.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(50);
//        }];
//         [weakSelf.frontView removeFromSuperview];
//    }];
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.bgView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.textView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.button.transform = CGAffineTransformMakeTranslation(0, 0);
        self.cancelBtn.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
          [weakSelf.frontView removeFromSuperview];
    }];
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length]>140) {
        return NO;
    }
    return YES;
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
//        self.textView.text = @"";
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
/**
 *  通过代理设置TextView高度自适应
 *
 *  @param textView <#textView description#>
 */
-(void)textViewDidChange:(UITextView *)textView
{
    weakSelf(weakSelf);
    CGRect frame = textView.frame;
    CGFloat height = [self heightForTextView:self.textView WithText:self.textView.text];
    frame.size.height = height;
    if (  height >= 44 && height <= sHeight *0.2) {
        _frontView.frame = CGRectMake(0, 0, sWidth, sHeight-self.keyboardHeight-height);
        [UIView animateWithDuration:0.5 animations:^{
            [weakSelf.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
        }];
    }else if(height >sHeight *0.2 ){
        height = sHeight *0.2;
        frame.size.height = height;
        _frontView.frame = CGRectMake(0, 0, sWidth, sHeight-self.keyboardHeight-height);
        [UIView animateWithDuration:0.5 animations:^{
            [weakSelf.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            
        }];
    }
}

//高度变化计算
- (CGFloat ) heightForTextView: (UITextView *)textView WithText: (NSString *) strText
{
    CGSize constraint = CGSizeMake(textView.contentSize.width , CGFLOAT_MAX);
    CGRect size = [strText boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                        context:nil];
    CGFloat textHeight = size.size.height+20;
    return textHeight;
}

-(void)dealloc
{
    [self.bgView removeFromSuperview];
    self.bgView = nil;
    self.textView = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
