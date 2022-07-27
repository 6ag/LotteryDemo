//
//  BBMaskVideoPlayerLayer.m
//  SangoLive
//
//  Created by 胡伟伟 on 2021/3/4.
//  Copyright © 2021 Sango. All rights reserved.
//

#import "BBMaskVideoPlayerLayer.h"
#import <CoreImage/CoreImage.h>

@interface BBMaskVideoPlayerLayer () {
    NSInteger _playCount;
}

/// 视频播放器
@property (nonatomic,strong) AVPlayer *videoPlayer;

/// 视频路径 支持URL 下载播放
@property (nonatomic,strong) NSURL *videoURL;

/// playItem
@property (nonatomic,strong) AVPlayerItem *playItem;

@end

static CIColorKernel *videoKernel = nil;

@implementation BBMaskVideoPlayerLayer

- (void)dealloc
{
    self.videoPlayer = nil;
}

/// 初始化
- (instancetype)init
{
    if (self = [super init]) {
        self.loop = 1;
        self.pixelBufferAttributes = @{@"PixelFormatType":@(kCMPixelFormat_32BGRA)};
        self.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        if (!videoKernel) {
            NSURL *kernelURL = [[NSBundle mainBundle] URLForResource:@"default" withExtension:@"metallib"];
            NSError *error;
            NSData *kernelData = [NSData dataWithContentsOfURL:kernelURL];
            videoKernel = [CIColorKernel kernelWithFunctionName:@"maskVideoMetal" fromMetalLibraryData:kernelData error:&error];
#if DEBUG
            NSAssert(!error, @"videoKernel=%@",error);
#else
#endif
        }
    }
    return self;
}

/// 播放视频
/// @param videoURL 视频路径
-(void)playVideoURL:(NSURL *)videoURL isInit:(BOOL)isInit
{
    self.videoURL = videoURL;
    self.player = self.videoPlayer;
    
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    @weakify(self);
    [videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            AVPlayerItem *playItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
            [self intilizaPlayItem:playItem];
            if (self.loop != -1 || !isInit) {
                [self.videoPlayer play];
            }
        });
    }];
}

/// 设置  playerItem
/// @param playItem playItem
- (void)intilizaPlayItem:(AVPlayerItem *)playItem
{
    [self.videoPlayer seekToTime:kCMTimeZero];
    [self intilizaPlayItemComposition:playItem];
    [self intilizaItemObserver:playItem];
    [self.videoPlayer replaceCurrentItemWithPlayerItem:playItem];
}

/// 设置 AVMutableVideoComposition
/// @param playItem playItem
- (void)intilizaPlayItemComposition:(AVPlayerItem *)playItem
{
    switch (self.type) {
        case 1:
            [self intilizaRightTop:playItem];
            break;
        case 2:
            [self intilizaLeftBottom:playItem];
            break;
        default:
            break;
    }
}

- (void)intilizaLeftBottom:(AVPlayerItem *)playItem
{
    // 获取轨道
    NSArray <AVAssetTrack *> *assetTracks = playItem.asset.tracks;
#if DEBUG
    NSAssert(assetTracks, @"NO tracks please check video source");
#else
    if (!assetTracks.count) return;
#endif
    
    CGSize videoSize = CGSizeMake(assetTracks.firstObject.naturalSize.width, assetTracks.firstObject.naturalSize.height / 1.5);
    
#if DEBUG
    NSAssert(videoSize.width && videoSize.height, @"videoSize can't be zero");
#else
    if (!videoSize.width ||!videoSize.height) return;
#endif
    NSLog(@"videoSize=%@", NSStringFromCGSize(videoSize));
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:playItem.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        
        CGRect sourceRect = (CGRect){0, 0, videoSize.width, videoSize.height};
        CGRect alphaRect = (CGRect){0, videoSize.height * 0.5, videoSize.width, videoSize.height};
        
        CIImage *inputImage = [request.sourceImage imageByCroppingToRect:sourceRect];
        inputImage = [inputImage imageByApplyingTransform:CGAffineTransformMakeScale(2, 2)];
        
        CIImage *maskImage = [request.sourceImage imageByCroppingToRect:alphaRect];
        maskImage = [maskImage imageByApplyingTransform:CGAffineTransformMakeTranslation(0, -videoSize.height * 0.495)];
        
        CIImage *outPutImage = [videoKernel applyWithExtent:CGRectMake(0, 0, videoSize.width, videoSize.height) arguments:@[(id)maskImage, (id)inputImage]];
        
        [request finishWithImage:outPutImage context:nil];
    }];
    videoComposition.renderSize = videoSize;
    playItem.videoComposition = videoComposition;
    playItem.seekingWaitsForVideoCompositionRendering = YES;
}

- (void)intilizaRightTop:(AVPlayerItem *)playItem
{
    // 获取轨道
    NSArray <AVAssetTrack *> *assetTracks = playItem.asset.tracks;
#if DEBUG
    NSAssert(assetTracks, @"NO tracks please check video source");
#else
    if (!assetTracks.count) return;
#endif
    
    CGSize videoSize = CGSizeMake(assetTracks.firstObject.naturalSize.width / 1.5f, assetTracks.firstObject.naturalSize.height);
    
#if DEBUG
    NSAssert(videoSize.width && videoSize.height, @"videoSize can't be zero");
#else
    if (!videoSize.width ||!videoSize.height) return;
#endif
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:playItem.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        
        CGRect sourceRect = (CGRect){0, 0, videoSize.width, videoSize.height};
        CGRect alphaRect = (CGRect){videoSize.width, 0, videoSize.width, videoSize.height};
        
        CIImage *inputImage = [request.sourceImage imageByCroppingToRect:sourceRect];
        CIImage *maskImage = [request.sourceImage imageByCroppingToRect:alphaRect];
        
        maskImage = [maskImage imageByApplyingTransform:CGAffineTransformMakeScale(2.0, 2.0)];
        maskImage = [maskImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-videoSize.width * 2.0, -videoSize.height)];
        // 调整mask位置
        // x数值越小越靠左
        // y数值越小越靠下
        
        CIImage *outPutImage = [videoKernel applyWithExtent:inputImage.extent arguments:@[(id)inputImage, (id)maskImage]];
        [request finishWithImage:outPutImage context:nil];
    }];
    videoComposition.renderSize = videoSize;
    playItem.videoComposition = videoComposition;
    playItem.seekingWaitsForVideoCompositionRendering = YES;
}

- (void)videoDidPlayFihisn
{
    [self.videoPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            if (self.loop == -1) { // 每次播放完就暂停
                if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(maskVideoDidPlayOnce:)]) {
                    [self.playDelegate maskVideoDidPlayOnce:self];
                }
            } else if (self.loop == 0) { // 自动循环播放
                [self.videoPlayer play];
            }else if (self.loop == 1) { // 只播放一次
                [self didFinishPlay];
            }else{
                self->_playCount ++;
                if (self->_playCount >= self.loop) {
                    self->_playCount = 0;
                    [self didFinishPlay];
                    return;
                }
                [self.videoPlayer play];
            }
        } else {
            [self clear];
            if (self.playDelegate &&[self.playDelegate respondsToSelector:@selector(maskVideoDidPlayFinish:)]) {
                [self.playDelegate maskVideoDidPlayFinish:self];
            }
        }
        
    }];
}

/// 设置observer
/// @param playItem playItem
- (void)intilizaItemObserver:(AVPlayerItem *)playItem
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayFihisn) name:AVPlayerItemDidPlayToEndTimeNotification object:playItem];
}

- (void)didFinishPlay
{
    NSLog(@"play Finish");
    [self clear];
    if (self.playDelegate &&[self.playDelegate respondsToSelector:@selector(maskVideoDidPlayFinish:)]) {
        [self.playDelegate maskVideoDidPlayFinish:self];
    }
}

/// 设置Session
- (void)initSession
{
    // 修复房间说话没声音，这里会让麦克风资源被强占
    return;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:NULL];
}

/// 暂停播放
- (void)pause
{
    [self.videoPlayer pause];
}

/// 恢复播放
- (void)resume
{
    [self initSession];
    [self.videoPlayer play];
}

/// 释放资源
- (void)clear
{
    [self pause];
    
    [self.videoPlayer.currentItem cancelPendingSeeks];
    [self.videoPlayer.currentItem.asset cancelLoading];
    [self.videoPlayer replaceCurrentItemWithPlayerItem:nil];
//    self.videoPlayer = nil;
    
    if (self.playItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playItem];
        self.playItem = nil;
    }
    
    [self removeFromSuperlayer];
}

#pragma mark - setter/getter
- (AVPlayer *)videoPlayer
{
    if (!_videoPlayer) {
        _videoPlayer = [[AVPlayer alloc] init];
    }
    return _videoPlayer;
}

@end
