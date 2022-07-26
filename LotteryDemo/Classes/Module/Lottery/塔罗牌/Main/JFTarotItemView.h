//
//  JFTarotItemView.h
//  VoiceChat
//
//  Created by feng on 2021/12/30.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFTarotItemView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickCardBlock)(JFTarotItemView *view);

@interface JFTarotItemView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *frontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (nonatomic, copy) ClickCardBlock onClickCard;
@property (nonatomic, assign) BOOL isAnimation;

- (void)drawCardSuccessWithResultModel:(JFLotteryResultItem *)model;
- (void)drawCardFailure;

@end

NS_ASSUME_NONNULL_END
