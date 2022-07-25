//
//  CCTurntableOptionView.h
//  VoiceChat
//
//  Created by feng on 2021/1/13.
//  Copyright © 2021 NoCardData. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCTurntableOptionView : UIView

/// 当前选中下标，0、1、2
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL isLuxury;

@end

NS_ASSUME_NONNULL_END
