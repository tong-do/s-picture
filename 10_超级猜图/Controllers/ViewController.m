//
//  ViewController.m
//  10_超级猜图
//
//  Created by 童益鳴 on 2020/02/17.
//  Copyright © 2020 童益鳴. All rights reserved.
//

#import "ViewController.h"
#import "TYMQuestion.h"

@interface ViewController () <UIAlertViewDelegate>

//所有问题的数据都在这个数组中
@property (nonatomic, strong) NSArray *questions;

//控制题目索引
@property (nonatomic, assign) int index;

//记录头像按钮原始的frame
@property (nonatomic, assign)CGRect iconFrame;
//用来引用阴影按钮的属性
@property (nonatomic, weak) UIButton *cover;

@property (weak, nonatomic) IBOutlet UILabel *lblIndex;
@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;

- (IBAction)btnNextClick;
- (IBAction)bigImage:(id)sender;
- (IBAction)btnIconClick:(id)sender;
- (IBAction)btnTipClick;

@end

@implementation ViewController

//懒加载数据

-(NSArray *)questions
{
    if (_questions == nil) {
        //加载数据
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        NSArray *arrayDict = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *arrayModel = [NSMutableArray array];
        
        //遍历字典转模型
        for (NSDictionary *dict in arrayDict) {
            TYMQuestion *model = [TYMQuestion questionWithDict:dict];
            [arrayModel addObject:model];
        }
        _questions = arrayModel;
    }
    return _questions;
}

//改变状态栏的文字颜色为白色
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化显示第一题
    self.index = -1;
    [self nextQuestion];
}


- (IBAction)btnNextClick {
    [self nextQuestion];
}

//显示大图
- (IBAction)bigImage:(id)sender {
    //记录一下头像按钮的原始frame
    self.iconFrame = self.btnIcon.frame;
    
    //创建大小与self.view一样的按钮,阴影显示
    UIButton *btnCover = [[UIButton alloc] init];
    btnCover.frame = self.view.bounds;
    btnCover.backgroundColor = [UIColor blackColor];
    //设置按钮透明度
    btnCover.alpha = 0.0;
    [self.view addSubview:btnCover];
    
    //为阴影按钮注册一个单击事件 监听
    [btnCover addTarget:self action:@selector(smallImage) forControlEvents:UIControlEventTouchUpInside];
    
    //把图片设置到阴影的上面 btnIcon显示到最上层
    [self.view bringSubviewToFront:self.btnIcon];
    
    //通过self.cover来引用btnCover
    self.cover = btnCover;
    
    //通过动画的方式把图片变大
    CGFloat iconW = self.view.frame.size.width;
    CGFloat iconH = iconW;
    CGFloat iconX = 0;
    CGFloat iconY = (self.view.frame.size.height - iconH) * 0.5;
    
    [UIView animateWithDuration:0.7f animations:^{
        //设置按钮透明度
        btnCover.alpha = 0.6;
        //设置图片新frame
        self.btnIcon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    }];
    
}

//头像按钮的单击事件
- (IBAction)btnIconClick:(id)sender {
    if (self.cover == nil) {
        //显示大图
        [self bigImage:nil];
    } else {
        [self smallImage];
    }
}


//点击提示按钮
- (IBAction)btnTipClick {
    [self addBtnScore:-1000];
    
    //把答案按钮清空
    for (UIButton *btnAnswer in self.answerView.subviews) {
        //让每个答案按钮点击一下
        [self btnAnswerClick:btnAnswer];
    }
    
    //从模型中取出当前这条数据的模型
    TYMQuestion *model = self.questions[self.index];
    //截取正确答案中的第一个字符
    NSString *firstChar = [model.answer substringToIndex:1];
    //找出对应的option按钮，并点击
    for (UIButton *btnOpt in self.optionsView.subviews) {
        if ([btnOpt.currentTitle isEqualToString:firstChar]) {
            [self optionButtonClick:btnOpt];
            break;
        }
    }
}

//阴影的单击事件
- (void)smallImage
{
//    //头像按钮frame还原
//    self.btnIcon.frame = self.iconFrame;
//    //让阴影按钮透明度为零
//
//    //移除阴影按钮
//    [self.cover removeFromSuperview];
    
    //动画还原
    [UIView animateWithDuration:0.7f animations:^{
        //头像按钮frame还原
        self.btnIcon.frame = self.iconFrame;
        //让阴影按钮透明度为零
        self.cover.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
     //移除阴影按钮
           [self.cover removeFromSuperview];
            //当头像图片变成小图以后，再把self.cover设置成nil
            self.cover = nil;
        }
    }];
    
}

- (void) nextQuestion {
    //1,让索引++
    self.index++;
    
    //判断当前索引是否越界，如果越界则提示用户
    if (self.index == self.questions.count) {
        NSLog(@"答题完毕！！！");
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"操作提示" message:@"恭喜通关" delegate:nil cancelButtonTitle:@"★取消★" otherButtonTitles:@"确定",@"哈哈哈",nil];
//        [alertView show];
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"操作提示" message:@"恭喜通关" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"★取消★" style:UIAlertActionStyleCancel handler:nil];
        //新api（UIAlertController）代替了旧的UIAlertview，不需要设置代理监听各个按钮，只需要在具体按钮生成时的代码块中实现点击该按钮后的具体操作即可
        UIAlertAction *confirmBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"确定按钮被点击");
            //让程序再回到第0个问题
            self.index = -1;
            [self nextQuestion];
        }];
        UIAlertAction *otherBtn = [UIAlertAction actionWithTitle:@"哈哈哈" style:UIAlertActionStyleDefault handler:nil];
        [alertView addAction:cancelBtn];
        [alertView addAction:confirmBtn];
        [alertView addAction:otherBtn];
        
        [self presentViewController:alertView animated:YES completion:nil];
        return;
    }
    
    //2,根据索引获取当前的模型数据
    TYMQuestion *model = self.questions[self.index];
    
    //3,根据模型设计数据
    [self settingData:model];
    
    //4,动态创建答案按钮
    [self makeAnswerButtons:model];
    
    //5,动态创建待选按钮
    [self makeOptionsButton:model];
    
}

//创建待选按钮
- (void)makeOptionsButton:(TYMQuestion *)model
{
    //设置optionView可以与用户交互
    self.optionsView.userInteractionEnabled = YES;
    //清除待选按钮的view中的所有子控件
    [self.optionsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //获取当前题目的待选文字的数组
    NSArray *words = model.options;
    //根据待选文字循环来创建按钮
    
    //指定每个待选按钮的大小
    CGFloat optionW = 35;
    CGFloat optionH = 35;
    //指定每个按钮之间的间距
    CGFloat margin = 10;
    //指定每行有多少个按钮
    int columns = 7;
    //计算出每行第一个按钮距离左边的距离
    CGFloat marginLeft = (self.optionsView.frame.size.width - columns * optionW - (columns - 1) * margin) / 2;
    
    for (int i = 0; i < words.count; i++) {
        //创建一个按钮
        UIButton *btnOpt = [[UIButton alloc] init];
        
        //给每一个option按钮一个唯一的tag值
        btnOpt.tag = i;
        //设置按钮背景
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        //设置按钮文字
        [btnOpt setTitle:words[i] forState:UIControlStateNormal];
        [btnOpt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //计算当前按钮的列索引和行索引
        int colIdx = i % columns;
        int rowIdx = i / columns;
        
        CGFloat optionX = marginLeft + colIdx * (optionW + margin);
        CGFloat optionY = 0 + rowIdx * (optionH + margin);
        //设置按钮frame
        btnOpt.frame = CGRectMake(optionX, optionY, optionW, optionH);
        //把按钮添加到optionsView中
        [self.optionsView addSubview:btnOpt];
        //为待选按钮注册单击时间
        [btnOpt addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)optionButtonClick:(UIButton *)sender
{
    //隐藏当前被点击按钮
    sender.hidden = YES; //把当前被点击的按钮s的文字显示到第一个为空的答案按钮上
//    NSString *text = [sender titleForState:UIControlStateNormal];//获取按钮指定状态下的文字
    NSString *text = sender.currentTitle;//获取按钮当前状态下的文字
    //把文字显示到答案按钮上
    
    
    for (UIButton *answerBtn in self.answerView.subviews) {
        //判断每个答案上的文字是否为nil
        if (answerBtn.currentTitle == nil) {
            [answerBtn setTitle:text forState:UIControlStateNormal];
            //把当前点击的待选按钮的tag值也设置给对应的答案按钮
            answerBtn.tag = sender.tag;
            break;
        }
    }
    
    //判断答案按钮是否已经填满了
    //一开始假设答案按钮是填满了
    BOOL isFull = YES;
    
    NSMutableString *userInput = [NSMutableString string];
    
    for (UIButton *btnAnswer in self.answerView.subviews) {
        if (btnAnswer.currentTitle == nil) {
            isFull = NO;
            break;
        } else {
            [userInput appendString:btnAnswer.currentTitle];
        }
    }
    if (isFull) {
        self.optionsView.userInteractionEnabled = NO;
        //获取正确答案
        TYMQuestion *model = self.questions[self.index];
        //如果答案按钮被填满了，那么就判断用户点击输入的答案是否与标准答案一致
        if ([model.answer isEqualToString:userInput]) {
            
            [self addBtnScore:100];
            
            //正确，设置答案按钮的文字颜色为蓝色
            [self setAnswerButtonsTitleColor:[UIColor blueColor]];
            
            //延迟0.5秒，下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5];
        } else {
            [self addBtnScore:-100];
            //错误，设置答案按钮的文字颜色为红色
            [self setAnswerButtonsTitleColor:[UIColor redColor]];
        }
    }
}

//根据指定分数，来对界面上的分数加减
- (void)addBtnScore:(int)score
{
    NSString *str = self.btnScore.currentTitle;
    int currentScore = str.intValue;
    currentScore = currentScore + score;
    [self.btnScore setTitle:[NSString stringWithFormat:@"%d", currentScore] forState:UIControlStateNormal];
}
//统一设置答案按钮颜色
- (void)setAnswerButtonsTitleColor:(UIColor *)color
{
    for (UIButton *btnAnswer in self.answerView.subviews) {
        [btnAnswer setTitleColor:color forState:UIControlStateNormal];
    }
}

//加载数据，把模型数据设置到界面的控件上
- (void)settingData:(TYMQuestion *)model
{
    //3,把模型数据设置到界面对应的控件上
    self.lblIndex.text = [NSString stringWithFormat:@"%d / %lu",self.index + 1,(unsigned long)self.questions.count];
    self.lblTitle.text = model.title;
    [self.btnIcon setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
    //4,设置到达最后一题以后，禁用“下一题”按钮
    self.btnNext.enabled = (self.index != self.questions.count - 1);
}

//创建答案按钮
-(void)makeAnswerButtons:(TYMQuestion *)model
{
    //清除上次的答案按钮
    //    while (self.answerView.subviews.firstObject) {
    //        [self.answerView.subviews.firstObject removeFromSuperview];
    //    }
        //让subviews数组中的每个对象，分别调用一次removeFromSuperview，内部自动执行循环
        [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        //5,动态创建答案按钮 获取当前答案文字个数
        NSUInteger len = model.answer.length;
        //设置按钮的frame
        CGFloat margin = 10;
        CGFloat answerH = 35;
               CGFloat answerW = 35;
               CGFloat answerY = 35;
        //答题小方框距离左右的距离
        CGFloat marginLeft = (self.answerView.frame.size.width - (len * answerW) - (len - 1) * margin) / 2;
        //循环创建答案按钮，有几个文字就创建几个按钮
        for (int i = 0; i < len; i++) {
        //创建按钮
            UIButton *btnAnswer = [[UIButton alloc]init];
            [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
            [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
            
           //计算按钮的X轴
            CGFloat answerX = marginLeft + i * (answerW + margin);
            btnAnswer.frame = CGRectMake(answerX, answerY, answerW, answerH);
            
            //设置答案按钮的文字颜色
            [btnAnswer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //把按钮加到answerView中
            [self.answerView addSubview:btnAnswer];
            
            //为答案按钮注册单击事件
            [btnAnswer addTarget:self action:@selector(btnAnswerClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
}

//参数sender，就表示当前点击的答案按钮
- (void)btnAnswerClick:(UIButton *)sender
{
    //启用optionView与用户交互
    self.optionsView.userInteractionEnabled = YES;
    
    //设置答案按钮的颜色
    [self setAnswerButtonsTitleColor:[UIColor blackColor]];
    //清空当前被点击的答案按钮的文字
    for (UIButton *optBtn in self.optionsView.subviews) {
//        if ([sender.currentTitle isEqualToString:optBtn.currentTitle]) {
//            optBtn.hidden = NO;
//        }
        if (sender.tag == optBtn.tag) {
            optBtn.hidden = NO;
            break;
        }
    }
    //在待选按钮中找到与当前被点击的答案按钮文字相同的待选按钮，设置该按钮显示出来
    [sender setTitle:nil forState:UIControlStateNormal];
}
@end
