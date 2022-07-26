//
//  JFLotteryResultItem.h
//  VoiceChat
//
//  Created by Mc on 2020/4/17.
//

#import <Foundation/Foundation.h>

@interface JFLotteryResultItem : NSObject

@property (nonatomic, assign) NSInteger giftId;
@property (nonatomic, copy) NSString *itemName; // 名称
@property (nonatomic, copy) NSString *picUrl; // 图片
@property (nonatomic, assign) NSInteger goldPrice; // 价值
@property (nonatomic, assign) NSInteger num; // 数量

@property (nonatomic, assign) NSInteger angle; // 角度
@property (nonatomic, assign) NSInteger againType; // 类型

- (instancetype)initWithItemName:(NSString *)itemName picUrl:(NSString *)picUrl goldPrice:(NSInteger)goldPrice num:(NSInteger)num;

@end
