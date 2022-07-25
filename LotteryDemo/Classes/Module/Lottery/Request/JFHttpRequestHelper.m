//
//  JFHttpRequestHelper+wishV2.m
//  VoiceChat
//
//  Created by feng on 2020/12/24.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFHttpRequestHelper.h"

@implementation JFHttpRequestHelper

/// 许愿
/// @param type 许愿类型: 1:1次 2:10次 3:20次 4:50次 5:100次
/// @param success 成功回调
/// @param failure 失败回调
+ (void)wish:(NSInteger)type success:(void (^)(id data))success failure:(void (^)(NSNumber *code, NSString *msg))failure {
    
    NSMutableArray *array = [NSMutableArray array];
    if (type >= 1) {
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称1" picUrl:@"00c1807fa04edf24be8121f94f320ca2" goldPrice:1 num:1]];
    }
    if (type >= 2) {
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称2" picUrl:@"50c96713694f9301144ff5c2316d3a3d" goldPrice:512 num:arc4random_uniform(5) + 1]];
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称3" picUrl:@"57dfcabe35bf5b4e106bed9293ce816e" goldPrice:20 num:arc4random_uniform(5) + 1]];
    }
    if (type >= 3) {
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称4" picUrl:@"86b0e10fc1f20691563506f11a914c62" goldPrice:1024 num:arc4random_uniform(10) + 1]];
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称5" picUrl:@"97b7f86d6917d8e7841105fc8e2b4b23" goldPrice:50 num:arc4random_uniform(10) + 1]];
    }
    if (type >= 4) {
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称6" picUrl:@"275f5e8206bf3a92adde3b8e9ef5727d" goldPrice:2048 num:arc4random_uniform(20) + 1]];
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称7" picUrl:@"792fee74deca8d9c8c2407fe08b260b9" goldPrice:100 num:arc4random_uniform(20) + 1]];
    }
    if (type >= 5) {
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称8" picUrl:@"853c2f27915d582a3f2a3404ce58b514" goldPrice:1314 num:arc4random_uniform(30) + 1]];
        [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称9" picUrl:@"1167164b2cc8446fcad77e96ac370ee3" goldPrice:200 num:arc4random_uniform(30) + 1]];
    }
    success(array);
}

+ (void)getWishListWithSuccess:(void (^)(id data))success failure:(void (^)(NSNumber *code, NSString *msg))failure
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称1" picUrl:@"00c1807fa04edf24be8121f94f320ca2" goldPrice:1 num:1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称2" picUrl:@"50c96713694f9301144ff5c2316d3a3d" goldPrice:512 num:arc4random_uniform(5) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称3" picUrl:@"57dfcabe35bf5b4e106bed9293ce816e" goldPrice:20 num:arc4random_uniform(5) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称4" picUrl:@"86b0e10fc1f20691563506f11a914c62" goldPrice:1024 num:arc4random_uniform(10) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称5" picUrl:@"97b7f86d6917d8e7841105fc8e2b4b23" goldPrice:50 num:arc4random_uniform(10) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称6" picUrl:@"275f5e8206bf3a92adde3b8e9ef5727d" goldPrice:2048 num:arc4random_uniform(20) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称7" picUrl:@"792fee74deca8d9c8c2407fe08b260b9" goldPrice:100 num:arc4random_uniform(20) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称8" picUrl:@"853c2f27915d582a3f2a3404ce58b514" goldPrice:1314 num:arc4random_uniform(30) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称9" picUrl:@"1167164b2cc8446fcad77e96ac370ee3" goldPrice:200 num:arc4random_uniform(30) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称10" picUrl:@"79711238321decb9c8e4084fc65b93b9" goldPrice:200 num:arc4random_uniform(30) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称11" picUrl:@"aca1997487def995144ccf0c50b3be43" goldPrice:200 num:arc4random_uniform(30) + 1]];
    [array addObject:[[JFLotteryResultItem alloc] initWithItemName:@"礼物名称12" picUrl:@"cdb4bdc6312ca904298b4776afde1202" goldPrice:200 num:arc4random_uniform(30) + 1]];
    success(array);
}

@end
