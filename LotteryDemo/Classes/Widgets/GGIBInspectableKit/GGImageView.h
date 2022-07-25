//
//  GGImageView.h
//  VoiceChat
//
//  Created by apple on 2018/10/23.
//  Copyright © 2018 XC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGImageView : UIImageView

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable BOOL masksToBounds;

//渐变颜色设置
@property (nonatomic, assign) IBInspectable UIColor *startColor;//必须设置
@property (nonatomic, assign) IBInspectable UIColor *endColor;//必须设置

@property (nonatomic, assign) IBInspectable BOOL isLeftToRightStytle;//左到右渐变，二选一
@property (nonatomic, assign) IBInspectable BOOL isTopToRBottomStytle;//上到下渐变，二选一

- (void)updateGradientLayer:(UIColor *)leftColor rightColor:(UIColor *)rightColor;

@end

NS_ASSUME_NONNULL_END
