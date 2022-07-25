//
//  SLMaskVideoPlayerLayer.m
//  SangoLive
//
//  Created by 胡伟伟 on 2021/3/4.
//  Copyright © 2021 Sango. All rights reserved.
//

#import "SLMaskVideoPlayerLayer.h"

@interface SLMaskVideoPlayerLayer () {
    NSInteger _playCount;
}

/// 视频播放器
@property (nonatomic,strong) AVPlayer *videoPlayer;

/// 视频路径 支持URL 下载播放
@property (nonatomic,strong) NSURL *videoURL;

/// playItem
@property (nonatomic,strong) AVPlayerItem *playItem;

@end

@implementation SLMaskVideoPlayerLayer

- (void)dealloc
{
    self.videoPlayer = nil;
}

/// 初始化
- (instancetype)init
{
    if (self = [super init]) {
        self.muted = NO;
        self.loop = 1;
        self.maskDirection = alphaVideoMaskDirectionLeftToRight;
        self.pixelBufferAttributes = @{@"PixelFormatType":@(kCMPixelFormat_32BGRA)};
        self.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

/// 播放视频
/// @param videoURL 视频路径
-(void)playVideoURL:(NSURL *)videoURL
{
    self.videoURL = videoURL;
    self.player = self.videoPlayer;
    
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    @weakify(self);
    [videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            AVPlayerItem *playItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
            // self.playItem = playItem;
            if (self.playItem) {
                [self intilizaAudioTacks:self.muted];
            }
            [self intilizaPlayItem:playItem];
            [self.videoPlayer play];
        });
    }];
}



/// 设置音轨
/// @param muted 是否静音
- (void)intilizaAudioTacks:(BOOL)muted
{
    // 修复房间说话没声音
    return;
    
    NSArray *audioTracks = [self.playItem.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:muted ? 0 : [AVAudioSession sharedInstance].outputVolume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    [self.playItem setAudioMix:audioMix];
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
    //获取轨道
    NSArray <AVAssetTrack *> *assetTracks = playItem.asset.tracks;
#if DEBUG
    NSAssert(assetTracks, @"NO tracks please check video source");
#else
    if(!assetTracks.count)return;
    
#endif
    
    CGSize videoSize = CGSizeZero;
    switch (self.maskDirection) {
        case alphaVideoMaskDirectionLeftToRight:
        case alphaVideoMaskDirectionRightToLeft:{
            videoSize = CGSizeMake(assetTracks.firstObject.naturalSize.width/2.f, assetTracks.firstObject.naturalSize.height);
        }
            break;
        case alphaVideoMaskDirectionTopToBottom:
        case alphaVideoMaskDirectionBottomToTop:
        {
            videoSize =   CGSizeMake(assetTracks.firstObject.naturalSize.width, assetTracks.firstObject.naturalSize.height/2.f);
        }
        default:
            break;
    }
#if DEBUG
    NSAssert(videoSize.width && videoSize.height, @"videoSize can't be zero");
#else
    if (!videoSize.width ||!videoSize.height) return;
    
#endif
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:playItem.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        //source rect this is you will show
        CGRect sourceRect = (CGRect){0,0,videoSize.width,videoSize.height};
        CGRect alphaRect = CGRectZero;
        
        CGFloat dx;
        CGFloat dy;
        switch (self.maskDirection) {
            case alphaVideoMaskDirectionLeftToRight:
            case alphaVideoMaskDirectionRightToLeft:{
                alphaRect = CGRectOffset(sourceRect, videoSize.width, 0);
                dx = -sourceRect.size.width;
                dy = 0;
            }
                break;
            case alphaVideoMaskDirectionTopToBottom:
            case alphaVideoMaskDirectionBottomToTop:
            {
                alphaRect = CGRectOffset(sourceRect, 0, videoSize.height);
                dx = 0;
                dy = -sourceRect.size.height;
            }
            default:
                break;
        }
        
        if (@available(iOS 11.0, *)) {
            if (!videoKernel) {
                NSURL *kernelURL = [[NSBundle mainBundle] URLForResource:@"default" withExtension:@"metallib"];
                NSError *error;
                NSData *kernelData = [NSData dataWithContentsOfURL:kernelURL];
                videoKernel = [CIColorKernel kernelWithFunctionName:@"maskVideoMetal" fromMetalLibraryData:kernelData error:&error];
#if DEBUG
                NSAssert(!error, @"%@",error);
#else
                
#endif
                // NSLog(@"---error%@",error);
            }
        } else {
            if (!videoKernel) {
                videoKernel = [CIColorKernel kernelWithString:@"kernel vec4 alphaFrame(__sample s, __sample m) {return vec4(s.rgb, m.r);}"];
            }
        }
        
        CIImage *inputImage;
        CIImage *maskImage;
        switch (self.maskDirection) {
            case alphaVideoMaskDirectionLeftToRight:{ // 右边内容。右边获取到后 平移到左边来。
                inputImage = [[request.sourceImage imageByCroppingToRect:alphaRect] imageByApplyingTransform:CGAffineTransformMakeTranslation(dx, dy)];
                maskImage = [request.sourceImage imageByCroppingToRect:sourceRect];
            }
                break;
            case alphaVideoMaskDirectionRightToLeft:{ // 左边内容。
                inputImage = [request.sourceImage imageByCroppingToRect:sourceRect];
                maskImage = [[request.sourceImage imageByCroppingToRect:alphaRect] imageByApplyingTransform:CGAffineTransformMakeTranslation(dx, dy)];
            }
                break;
            case alphaVideoMaskDirectionTopToBottom:{
                inputImage = [request.sourceImage imageByCroppingToRect:sourceRect];
                maskImage = [[request.sourceImage imageByCroppingToRect:alphaRect] imageByApplyingTransform:CGAffineTransformMakeTranslation(dx, dy)];
            }
                break;
            case alphaVideoMaskDirectionBottomToTop:
            {
                inputImage = [[request.sourceImage imageByCroppingToRect:alphaRect] imageByApplyingTransform:CGAffineTransformMakeTranslation(dx, dy)];
                maskImage = [request.sourceImage imageByCroppingToRect:sourceRect];
            }
            default:
                break;
        }
        
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
            if (self.loop <=0) {//play cycle
                [self.videoPlayer play];
            }else if (self.loop ==1){//play Once
                [self didFinishPlay];
            }else{
                self->_playCount ++;
                if (self->_playCount>=self.loop) {
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
- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    if (self.playItem) {
        [self intilizaAudioTacks:muted];
    }
}

- (AVPlayer *)videoPlayer
{
    if (!_videoPlayer) {
        _videoPlayer = [[AVPlayer alloc] init];
    }
    return _videoPlayer;
}

@end
