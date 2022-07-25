//
//  SLAlphaVideoDefines.h
//  SangoLive
//
//  Created by 胡伟伟 on 2021/3/4.
//  Copyright © 2021 Sango. All rights reserved.
//

#ifndef SLAlphaVideoDefines_h
#define SLAlphaVideoDefines_h

#import <CoreImage/CoreImage.h>

static CIColorKernel *videoKernel = nil;

typedef NS_ENUM(NSUInteger,alphaVideoMaskDirection) {
    alphaVideoMaskDirectionLeftToRight = 1<<1,//白幕在左 实际效果在右
    alphaVideoMaskDirectionRightToLeft = 1<<2,//白幕在右 实际效果在左
    alphaVideoMaskDirectionTopToBottom = 1<3,//白幕在上 实际效果在下
    alphaVideoMaskDirectionBottomToTop = 1<<4//白幕在下  实际效果在下
};

//typedef ns_en <#new#>;
#endif /* SLAlphaVideoDefines_h */
