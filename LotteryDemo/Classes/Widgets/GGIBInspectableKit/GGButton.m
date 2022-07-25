//
//  GGButton.m
//  VoiceChat
//
//  Created by apple on 2018/10/23.
//  Copyright © 2018 XC. All rights reserved.
//

#import "GGButton.h"

@implementation GGButton

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
    self.layer.masksToBounds = YES;
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}
- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)setMasksToBounds:(BOOL)masksToBounds
{
    _masksToBounds = masksToBounds;
    self.layer.masksToBounds = _masksToBounds;
}

- (void)setStartColor:(UIColor *)startColor
{
    _startColor = startColor;
}

- (void)setEndColor:(UIColor *)endColor
{
    _endColor = endColor;
}

- (void)setIsLeftToRightStytle:(BOOL)isLeftToRightStytle
{
    _isLeftToRightStytle = isLeftToRightStytle;
    
    
    if (isLeftToRightStytle) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)self.startColor.CGColor,
                           (id)self.endColor.CGColor,
                           nil];
        [self.layer insertSublayer:gradient atIndex:0];
    }
}

- (void)setIsTopToRBottomStytle:(BOOL)isTopToRBottomStytle
{
    _isTopToRBottomStytle = isTopToRBottomStytle;
    
    
    if (isTopToRBottomStytle) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        gradient.startPoint = CGPointMake(0.5, 0);
        gradient.endPoint = CGPointMake(0.5, 1);
        gradient.locations = @[@(0), @(1.0f)];
        gradient.colors = [NSArray arrayWithObjects:
                           (id)self.startColor.CGColor,
                           (id)self.endColor.CGColor,
                           nil];
        [self.layer insertSublayer:gradient atIndex:0];
    }
}

- (void)updateGradientLayer:(UIColor *)leftColor rightColor:(UIColor *)rightColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)leftColor.CGColor,
                       (id)rightColor.CGColor,
                       nil];
    [self.layer insertSublayer:gradient atIndex:0];
    

}

@end
