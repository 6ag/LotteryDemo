//
//  JFLotteryResultItem.m
//  VoiceChat
//
//  Created by Mc on 2020/4/17.
//

#import "JFLotteryResultItem.h"

@implementation JFLotteryResultItem

- (instancetype)initWithItemName:(NSString *)itemName picUrl:(NSString *)picUrl goldPrice:(NSInteger)goldPrice num:(NSInteger)num
{
    if (self = [super init]) {
        _itemName = itemName;
        _picUrl = picUrl;
        _goldPrice = goldPrice;
        _num = num;
    }
    return self;
}
@end
