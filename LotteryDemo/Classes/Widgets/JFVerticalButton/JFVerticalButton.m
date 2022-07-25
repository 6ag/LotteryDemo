//
//  JFVerticalButton.m
//  VoiceChat
//
//  Created by apple on 2019/6/17.
//

#import "JFVerticalButton.h"

@implementation JFVerticalButton

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)verticalImageAndTitle:(CGFloat)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
    
}

- (void)setTitleSpacing:(CGFloat)titleSpacing
{
    _titleSpacing = titleSpacing;
    
    [self verticalImageAndTitle:titleSpacing];
}


@end
