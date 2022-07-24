//
//  JFLotteryListModel.h
//  LotteryDemo
//
//  Created by feng on 2022/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFLotteryListModel : NSObject

@property (nonatomic, strong) Class viewClass;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithViewClass:(Class)viewClass image:(NSString *)image title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
