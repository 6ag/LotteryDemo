//
//  JFIdolProjectResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>
#import "JFLotteryResultItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFIdolProjectResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models againType:(NSInteger)againType buyBlock:(JFRoomWishAgain)buyBlock;

@end

NS_ASSUME_NONNULL_END
