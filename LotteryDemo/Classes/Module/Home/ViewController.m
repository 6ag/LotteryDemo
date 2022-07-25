//
//  ViewController.m
//  LotteryDemo
//
//  Created by feng on 2022/7/16.
//

#import "ViewController.h"
#import "JFLotteryListCell.h"
#import "JFLotteryListModel.h"
#import <objc/runtime.h>

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<JFLotteryListModel *> *lotteryList;

@end

// 所有抽奖换UICollectionView展示，截图和名字，文字底部加遮罩
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.lotteryList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = (SCREEN_WIDTH - 15 * 2 - 10) / 2.0;
    return CGSizeMake(floor(itemWidth), itemWidth * 0.75);
}

// 滚动方向的item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

// 滚动方向的交叉方向的item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JFLotteryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LotteryItemID" forIndexPath:indexPath];
    cell.model = self.lotteryList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    JFLotteryListModel *model = self.lotteryList[indexPath.item];
    
    [model.viewClass performSelector:@selector(show)];
}

#pragma mark - setter/getter
- (NSMutableArray<JFLotteryListModel *> *)lotteryList
{
    if (!_lotteryList) {
        _lotteryList = [NSMutableArray array];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFIdolProjectView") image:@"lottery_idol_project" title:@"爱豆计划"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFPetView") image:@"lottery_pet_view" title:@"萌宠考拉"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFRoomWishView") image:@"lottery_wish_crystal" title:@"许愿水晶"]];
    }
    return _lotteryList;
}

@end

