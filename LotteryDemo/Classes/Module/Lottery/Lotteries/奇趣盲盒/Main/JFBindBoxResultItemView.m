//
//  JFBindBoxResultItemView.m
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import "JFBindBoxResultItemView.h"

@interface JFBindBoxResultItemView () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UIImageView *count1ImageView; // 百
@property (weak, nonatomic) IBOutlet UIImageView *count2ImageView; // 十
@property (weak, nonatomic) IBOutlet UIImageView *count3ImageView; // 个
@property (weak, nonatomic) IBOutlet UIImageView *countXImageView;

@property (nonatomic, strong) UIBezierPath *customPath;

@end

@implementation JFBindBoxResultItemView

- (void)setModel:(JFLotteryResultItem *)model
{
    _model = model;
    
    self.logoImageView.image = [UIImage imageNamed:model.picUrl];
    
    NSInteger giftNum = model.num;
    int individual = giftNum % 10;
    int ten = giftNum / 10 % 10;
    int hundred = giftNum / 100 % 10;
    self.count3ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bind_box_result_num_%d", individual]];
    self.count2ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bind_box_result_num_%d", ten]];
    self.count1ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bind_box_result_num_%d", hundred]];
    
    if (hundred == 0) {
        self.count1ImageView.hidden = YES;
    }
    if (hundred == 0 && ten == 0) {
        self.count2ImageView.hidden = YES;
    }
    if (hundred == 0 && ten == 0 && individual == 1) {
        self.count3ImageView.hidden = YES;
        self.countXImageView.hidden = YES;
    }
}

- (void)startAnimation
{
    self.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    CGPoint startPoint = self.center;
    CGPoint showPoint = CGPointMake(startPoint.x, startPoint.y - 170);
    
    BOOL randomBool = arc4random_uniform(2) == 0;
    int randomOffsetX = arc4random_uniform((int)(SCREEN_WIDTH * 0.3));
    int randomOffsetY = arc4random_uniform(80);
    if (randomBool) {
        showPoint = CGPointMake(showPoint.x + randomOffsetX, showPoint.y + randomOffsetY);
    } else {
        showPoint = CGPointMake(showPoint.x - randomOffsetX, showPoint.y + randomOffsetY);
    }
    
    // 移动
    CABasicAnimation *showAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    showAnim.duration = 0.5;
    showAnim.fromValue = [NSValue valueWithCGPoint:startPoint];
    showAnim.toValue = [NSValue valueWithCGPoint:showPoint];
    showAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    showAnim.fillMode = kCAFillModeForwards;
    
    // 缩放
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.duration = 0.5;
    scaleAnim.fromValue = @(0);
    scaleAnim.toValue = @(1);
    scaleAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnim.fillMode = kCAFillModeForwards;
    
    // 透明度
    CABasicAnimation *alphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnim.duration = 0.5;
    alphaAnim.fromValue = @(0);
    alphaAnim.toValue = @(1);
    alphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alphaAnim.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group1 = [[CAAnimationGroup alloc] init];
    group1.animations = @[showAnim, scaleAnim, alphaAnim];
    group1.duration = 0.5;
    group1.removedOnCompletion = NO;
    group1.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:group1 forKey:@"showAnim"];
    
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        // 抛物线
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:showPoint];
        [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH - 120, SCREEN_HEIGHT - 70) controlPoint:CGPointMake(SCREEN_WIDTH * 0.6, showPoint.y + 80)];
        CAKeyframeAnimation *parabolaAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        parabolaAnim.duration = 0.5;
        parabolaAnim.path = path.CGPath;
        parabolaAnim.fillMode = kCAFillModeForwards;
        
        // 透明度
        CABasicAnimation *alphaAnim2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnim2.duration = 0.5;
        alphaAnim2.fromValue = @(1);
        alphaAnim2.toValue = @(0.1);
        alphaAnim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        alphaAnim2.fillMode = kCAFillModeForwards;
        
        CAAnimationGroup *group2 = [[CAAnimationGroup alloc] init];
        group2.animations = @[parabolaAnim, alphaAnim2];
        group2.duration = 0.5;
        group2.removedOnCompletion = NO;
        group2.fillMode = kCAFillModeForwards;
        group2.delegate = self;
        [self.layer addAnimation:group2 forKey:@"parabolaAnim"];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self removeFromSuperview];
}

@end
