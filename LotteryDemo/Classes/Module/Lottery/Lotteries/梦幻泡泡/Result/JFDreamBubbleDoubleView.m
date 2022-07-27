//
//  JFDreamBubbleDoubleView.m
//  VoiceChat
//
//  Created by feng on 2022/5/14.
//  Copyright © 2022 NoCardData. All rights reserved.
//

#import "JFDreamBubbleDoubleView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SVGAParser.h>
#import <SVGAImageView.h>
#import "SVGAVideoEntity.h"

@interface JFDreamBubbleDoubleView () <SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet SVGAImageView *svgaImageView;

@property (nonatomic, strong) NSArray<JFLotteryResultItem *> *models;
@property (nonatomic, copy) DreamBubbleDoubleFinished finished;

@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *image4;
@property (nonatomic, strong) UIImage *image5;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation JFDreamBubbleDoubleView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.svgaImageView.delegate = self;
}

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models finished:(DreamBubbleDoubleFinished)finished
{
    JFDreamBubbleDoubleView *view = [[NSBundle mainBundle]loadNibNamed:@"JFDreamBubbleDoubleView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.alpha = 0;
    
    view.models = models;
    view.finished = finished;
    
    [UIView animateWithDuration:0.28 animations:^{
        view.alpha = 1;
    }];
    [view downloadImage];
}

- (void)downloadImage
{
    [self.indicator startAnimating];
    
    NSMutableArray<NSString *> *imageNames = [NSMutableArray array];
    for (JFLotteryResultItem *item in self.models) {
        if (imageNames.count < 5) {
            [imageNames addObject:item.picUrl];
        }
    }
    
    self.image1 = [UIImage imageNamed:imageNames[0]];
    self.image2 = [UIImage imageNamed:imageNames[1]];
    self.image3 = [UIImage imageNamed:imageNames[2]];
    self.image4 = [UIImage imageNamed:imageNames[3]];
    self.image5 = [UIImage imageNamed:imageNames[4]];
    
    [self setupGiftImageAnimation];
}

- (void)setupGiftImageAnimation
{
    CGSize imageSize = CGSizeMake(88, 88);
    CGFloat radius = imageSize.width * 0.5;
    
    UIImage *gift1 = [self.image1 imageByResizeToSize:imageSize contentMode:UIViewContentModeScaleAspectFill];
    UIImage *gift2 = [self.image2 imageByResizeToSize:imageSize contentMode:UIViewContentModeScaleAspectFill];
    UIImage *gift3 = [self.image3 imageByResizeToSize:imageSize contentMode:UIViewContentModeScaleAspectFill];
    UIImage *gift4 = [self.image4 imageByResizeToSize:imageSize contentMode:UIViewContentModeScaleAspectFill];
    UIImage *gift5 = [self.image5 imageByResizeToSize:imageSize contentMode:UIViewContentModeScaleAspectFill];
    
    UIImage *gift1Radius = [gift1 imageByRoundCornerRadius:radius];
    UIImage *gift2Radius = [gift2 imageByRoundCornerRadius:radius];
    UIImage *gift3Radius = [gift3 imageByRoundCornerRadius:radius];
    UIImage *gift4Radius = [gift4 imageByRoundCornerRadius:radius];
    UIImage *gift5Radius = [gift5 imageByRoundCornerRadius:radius];
    
    [self.svgaImageView setImage:gift1Radius forKey:@"gift1"];
    [self.svgaImageView setImage:gift2Radius forKey:@"gift2"];
    [self.svgaImageView setImage:gift3Radius forKey:@"gift3"];
    [self.svgaImageView setImage:gift4Radius forKey:@"gift4"];
    [self.svgaImageView setImage:gift5Radius forKey:@"gift5"];
    
    self.svgaImageView.imageName = @"dream_bubble_double_normal";
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - SVGAPlayerDelegate
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        if (self.finished) {
            self.finished();
        }
    });
}

@end
