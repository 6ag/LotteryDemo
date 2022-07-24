//
//  JFHttpRequestHelper+wishV2.h
//  VoiceChat
//
//  Created by feng on 2020/12/24.
//  Copyright © 2020 NoCardData. All rights reserved.
//

#import "JFHttpRequestHelper.h"
#import "JFLotteryResultItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFHttpRequestHelper : NSObject

/// 许愿
/// @param type 许愿类型: 1:1次 2:10次 3:20次 4:50次 5:100次
/// @param success 成功回调
/// @param failure 失败回调
+ (void)wish:(NSInteger)type success:(void (^)(id data))success failure:(void (^)(NSNumber *code, NSString *msg))failure;

@end

NS_ASSUME_NONNULL_END
