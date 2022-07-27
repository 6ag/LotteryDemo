//
//  JFRocketResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

typedef void(^JFRocketResultAgainBlock)(NSInteger type);

NS_ASSUME_NONNULL_BEGIN

@interface JFRocketResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models type:(NSInteger)type againBlock:(JFRocketResultAgainBlock)againBlock;

@end

NS_ASSUME_NONNULL_END
