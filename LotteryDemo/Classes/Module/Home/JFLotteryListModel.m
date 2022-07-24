//
//  JFLotteryListModel.m
//  LotteryDemo
//
//  Created by feng on 2022/7/17.
//

#import "JFLotteryListModel.h"

@implementation JFLotteryListModel

- (instancetype)initWithViewClass:(Class)viewClass image:(NSString *)image title:(NSString *)title
{
    if (self = [super init]) {
        _viewClass = viewClass;
        _image = image;
        _title = title;
    }
    return self;
}
@end
