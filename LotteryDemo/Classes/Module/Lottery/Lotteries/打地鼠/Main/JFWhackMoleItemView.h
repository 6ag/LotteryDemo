//
//  JFWhackMoleItemView.h
//  VoiceChat
//
//  Created by feng on 2021/12/30.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFWhackMoleItemView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickCardBlock)(JFWhackMoleItemView *view);

@interface JFWhackMoleItemView : UIView

@property (nonatomic, copy) ClickCardBlock onClickCard;
@property (nonatomic, assign, readonly) BOOL isClickable;

@property (nonatomic, assign) NSInteger type; // 锤子的类型 1-4
@property (nonatomic, assign) NSInteger mouseType; // 老鼠的类型 1-4

- (void)drawCardSuccessWithResultModel:(JFLotteryResultItem *)model;
- (void)drawCardFailure;

@end

NS_ASSUME_NONNULL_END
