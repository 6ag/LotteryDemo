//
//  JFRoomWishView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/15.
//

#import "JFRoomWishView.h"
#import "JFRoomWishResultView.h"
#import "JFHttpRequestHelper.h"
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

@interface JFRoomWishView ()<SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *giftAnimationBtn;
@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;

@property (weak, nonatomic) IBOutlet UILabel *goldBalanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *wishBallBtn;
@property (weak, nonatomic) IBOutlet UIButton *wishBtn1;
@property (weak, nonatomic) IBOutlet UIButton *wishBtn10;
@property (weak, nonatomic) IBOutlet UIButton *wishBtn20;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_bgView;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;

@property (nonatomic,assign) BOOL isShowingSvga;
@property (nonatomic,assign) BOOL isRequesting;

@property (strong, nonatomic) SVGAImageView *svgaDisplayView;

@end

@implementation JFRoomWishView

+ (void)show
{
    JFRoomWishView *view = [[NSBundle mainBundle]loadNibNamed:@"JFRoomWishView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.tag = 80001;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    view.giftAnimationBtn.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:@"ClosePetEatAnimation"];
    
    [view setSvgaView];
    view.bottom_bgView.constant = -SCREEN_WIDTH/375*472;
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        view.bottom_bgView.constant = 0;
        [view layoutIfNeeded];
    }];
    
}

- (void)close
{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottom_bgView.constant = -SCREEN_WIDTH/375*472;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setSvgaView
{
    [self layoutIfNeeded];
    self.svgaDisplayView.frame = self.ballImageView.bounds;
}

//关闭
- (IBAction)closeBtnAction:(id)sender {
    [self close];
}

//礼物动画开关
- (IBAction)giftAnimationBtnAction:(id)sender {
    self.giftAnimationBtn.selected = !self.giftAnimationBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:!self.giftAnimationBtn.selected forKey:@"ClosePetEatAnimation"];
}

//排行榜
- (IBAction)rankBtnAction:(id)sender {
    
}

//记录
- (IBAction)recordBtnAction:(id)sender {
    
}

//礼品
- (IBAction)giftBtnAction:(id)sender {
    
}

//规则
- (IBAction)ruleBtnAction:(id)sender {
    
}

//许愿1次
- (IBAction)openBtnAction1:(id)sender {
    [self openWishAction:1];
}

//许愿10次
- (IBAction)openBtnAction2:(id)sender {
    [self openWishAction:2];
}

//许愿100次
- (IBAction)openBtnAction3:(id)sender {
    [self openWishAction:5];
}

/// 切换喂食按钮交互
/// @param canTap 是否可以点击
- (void)setWishBtnUserinterface:(BOOL)canTap
{
    self.wishBallBtn.userInteractionEnabled = canTap;
    self.wishBtn1.userInteractionEnabled = canTap;
    self.wishBtn10.userInteractionEnabled = canTap;
    self.wishBtn20.userInteractionEnabled = canTap;
}

#pragma mark - Svga动画
- (void)showWishSvga
{
    [self.svgaDisplayView stopAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.ballImageView.hidden = YES;
    });
    
    self.svgaDisplayView.imageName = @"room_wish_crystal_animation";
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    self.isShowingSvga = NO;
    self.ballImageView.hidden = NO;
    [self checkHadShowResult];
}

#pragma mark - Network
- (void)openWishAction:(NSInteger)type
{
    if (self.isRequesting) {
        return;
    }
    
    self.isRequesting = YES;
    if (self.giftAnimationBtn.selected) {
        self.isShowingSvga = YES;
        [self showWishSvga];
    }
    [self setWishBtnUserinterface:NO];
    
    __weak typeof(self) weakSelf = self;
    [JFHttpRequestHelper wish:type success:^(id data) {
        weakSelf.isRequesting = NO;
        weakSelf.models = [data copy];
        
        if (!weakSelf.giftAnimationBtn.selected) {
            [weakSelf checkHadShowResult];
        }
        
    } failure:^(NSNumber *code, NSString *msg) {
        weakSelf.isRequesting = NO;
        [weakSelf setWishBtnUserinterface:YES];
    }];
}

/// 显示开箱子结果弹窗视图
- (void)checkHadShowResult
{
    if (self.isRequesting) {
        return;
    }
    
    if (self.models) {
        // 弹出结果视图
        [JFRoomWishResultView showWish:self.models];
        
        self.models = nil;
        [self setWishBtnUserinterface:YES];
    }
    
}

#pragma mark - setter/getter
- (SVGAImageView *)svgaDisplayView {
    if (!_svgaDisplayView) {
        _svgaDisplayView = [SVGAImageView new];
        _svgaDisplayView.userInteractionEnabled = false;
        _svgaDisplayView.alpha = 1;
        _svgaDisplayView.autoPlay = YES;
        _svgaDisplayView.loops = 1;
        _svgaDisplayView.clearsAfterStop = YES;
        _svgaDisplayView.delegate = self;
        [self.bgView insertSubview:_svgaDisplayView aboveSubview:self.ballImageView];
    }
    return _svgaDisplayView;
}

@end
