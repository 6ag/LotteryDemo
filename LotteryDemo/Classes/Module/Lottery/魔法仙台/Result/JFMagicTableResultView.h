//
//  JFMagicTableResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFMagicTableResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models buyBlock:(JFRoomWishAgain)buyBlock;

@end

NS_ASSUME_NONNULL_END
