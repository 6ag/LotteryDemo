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

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<JFLotteryListModel *> *lotteryList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 0, 15);
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
    [self.lotteryList[indexPath.item].viewClass performSelector:@selector(show)];
}

#pragma mark - setter/getter
- (NSMutableArray<JFLotteryListModel *> *)lotteryList
{
    if (!_lotteryList) {
        _lotteryList = [NSMutableArray array];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFMoonTreasureView") image:@"lottery_moon_treasure" title:@"月球宝藏"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFMagicPrayView") image:@"lottery_magic_pray" title:@"魔法祈愿池"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFDreamBubbleView") image:@"lottery_dream_bubble" title:@"梦幻泡泡"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFWhackMoleView") image:@"lottery_whack_mole" title:@"打地鼠"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFBindBoxView") image:@"lottery_bind_box" title:@"奇趣盲盒"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFTarotView") image:@"lottery_tarot" title:@"塔罗牌"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFSummonBeastView") image:@"lottery_summon_beast" title:@"召唤神兽"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFPrayLotusView") image:@"lottery_pray_lotus" title:@"祈福莲华"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFWishBottleView") image:@"lottery_wish_bottle" title:@"许愿水瓶"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("CCTreasureBoxView") image:@"lottery_cc_treasure_box" title:@"潘多拉魔盒"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFUnlimitedTreasureChestView") image:@"lottery_unlimited_treasure_chest" title:@"无限宝箱"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFTreasureBoxView") image:@"lottery_treasure_box" title:@"开宝箱"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("BBTreasureBoxView") image:@"lottery_bb_treasure_box" title:@"开宝箱2"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("CCTurntableView") image:@"lottery_cc_turntable" title:@"比翼转盘"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("AATurntableView") image:@"lottery_aa_turntable" title:@"幸运转盘"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("EETurntableView") image:@"lottery_ee_turntable" title:@"幸运转盘2"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("BBTurntableView") image:@"lottery_bb_turntable" title:@"幸运大转盘"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("DDTurntableView") image:@"lottery_dd_turntable" title:@"幸运大转盘2"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("FFTurntableView") image:@"lottery_ff_turntable" title:@"幸运大转盘3"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("GGTurntableView") image:@"lottery_gg_turntable" title:@"幸运大转盘4"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("HHTurntableView") image:@"lottery_hh_turntable" title:@"幸运大转盘5"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFIdolProjectView") image:@"lottery_idol_project" title:@"爱豆计划"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFPetView") image:@"lottery_pet_view" title:@"萌宠考拉"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFRoomWishView") image:@"lottery_wish_crystal" title:@"许愿水晶"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFTwistedEggView") image:@"lottery_twisted_egg" title:@"快乐扭蛋"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFMagicTableView") image:@"lottery_magic_table" title:@"魔法仙台"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFPentagramBallView") image:@"lottery_pentagram_ball" title:@"五角星球"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFInterstellarTravelView") image:@"lottery_interstellar_travel" title:@"星际旅行"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFRocketView") image:@"lottery_rocket" title:@"火箭大作战"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFLuckyBottleView") image:@"lottery_lucky_bottle" title:@"幸运瓶"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFOrchardView") image:@"lottery_orchard" title:@"果农乐园"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFMiningView") image:@"lottery_mining" title:@"挖矿"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFDragonSlayerView") image:@"lottery_dragon_slayer" title:@"屠龙勇士"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFDollMachineView") image:@"lottery_doll_machine" title:@"抓娃娃"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFMakeCandyView") image:@"lottery_make_candy" title:@"糖果制造机"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFPenguinMinerView") image:@"lottery_penguin_miner" title:@"企鹅矿工"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFCatteryView") image:@"lottery_cattery_cat" title:@"幸运猫舍"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("JFWaterTreeView") image:@"lottery_water_tree" title:@"给树浇水"]];
        [_lotteryList addObject:[[JFLotteryListModel alloc] initWithViewClass:objc_getClass("BBWaterTreeView") image:@"lottery_bb_water_tree" title:@"给树浇水2"]];
    }
    return _lotteryList;
}

@end
