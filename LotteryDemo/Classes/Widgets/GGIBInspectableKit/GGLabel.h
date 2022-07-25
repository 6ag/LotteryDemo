//
//  GGLabel.h
//  VoiceChat
//
//  Created by apple on 2018/10/23.
//  Copyright © 2018 XC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGLabel : UILabel

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable BOOL masksToBounds;
@property (nonatomic, assign) UIEdgeInsets textInsets; // 控制字体与控件边界的间隙


@end

NS_ASSUME_NONNULL_END
