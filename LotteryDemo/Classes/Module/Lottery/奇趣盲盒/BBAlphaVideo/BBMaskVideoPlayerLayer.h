//
//  BBMaskVideoPlayerLayer.h
//  SangoLive
//
//  Created by 胡伟伟 on 2021/3/4.
//  Copyright © 2021 Sango. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BBMaskVideoPlayerLayer;

@protocol BBMaskVideoPlayerDelegate <NSObject>

@optional
- (void)maskVideoDidPlayFinish:(BBMaskVideoPlayerLayer *)playerLayer;
- (void)maskVideoDidPlayOnce:(BBMaskVideoPlayerLayer *)playerLayer;

@end

@interface BBMaskVideoPlayerLayer : AVPlayerLayer

@property (nonatomic, assign) NSInteger type; // 1-背景 2-钩子 3-滚动

/// 循环次数 默认为1次 <=0为无限循环
@property (nonatomic,assign) NSInteger loop;

/// playDelegate
@property (nonatomic,weak) id<BBMaskVideoPlayerDelegate>playDelegate;

/// 播放视频
/// @param videoURL 视频路径
-(void)playVideoURL:(NSURL *)videoURL isInit:(BOOL)isInit;

/// 暂停播放
- (void)pause;

/// 恢复播放
- (void)resume;

/// 释放资源
- (void)clear;

@end

NS_ASSUME_NONNULL_END
