//
//  JFPetResultView.h
//  VoiceChat
//
//  Created by Mc on 2020/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFPetResultView : UIView

+ (void)showWish:(NSArray<JFLotteryResultItem *> *)models againType:(NSInteger)againType buyBlock:(JFRoomWishAgain)buyBlock closeBlock:(JFRoomWishClose)closeBlock;
@end

NS_ASSUME_NONNULL_END
