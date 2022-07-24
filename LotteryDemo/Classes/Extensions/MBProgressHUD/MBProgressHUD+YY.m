//
//  MBProgressHUD+YY.m
//  NJWisdomCard
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Weconex. All rights reserved.
//

#import "MBProgressHUD+YY.h"

#define HUD_TIP_TIME (1.5)
#define HUD_GRACE_TIME (0.5)

@implementation MBProgressHUD (YY)

#pragma mark - 显示短暂提示
/// 显示成功信息
/// @param message 信息内容
+ (void)showSuccess:(NSString *)message
{
    [self showSuccess:message toView:nil];
}

/// 显示成功信息
/// @param message 信息内容
/// @param view 显示MBProgressHUD的视图
+ (void)showSuccess:(NSString *)message toView:(UIView *)view
{
    [self show:message icon:@"hud_success" view:view];
}

/// 显示错误信息
/// @param message 信息内容
+ (void)showError:(NSString *)message
{
    [self showError:message toView:nil];
}

/// 显示错误信息
/// @param message 信息内容
/// @param view 显示MBProgressHUD的视图
+ (void)showError:(NSString *)message toView:(UIView *)view
{
    [self show:message icon:@"hud_error" view:view];
}

/// 显示短暂提示信息
/// @param message 信息内容
/// @param icon 图标
/// @param view 显示MBProgressHUD的视图
+ (void)show:(NSString *)message icon:(NSString *)icon view:(UIView *)view
{
    [self hideHUD];
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
        if (view == nil) {
            return;
        }
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    
    // 设置HUD显示最小时间避免显示后立即被隐藏
    hud.minShowTime = HUD_TIP_TIME;
    
    // 隐藏HUD后从父视图移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 内容颜色（标签、按钮、指示器等）
    hud.contentColor = [UIColor whiteColor];
    
    // 边框
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    
    // 自定义图标
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    
    // 显示文本
    hud.label.text = message;
    
    // 添加到父视图
    [view addSubview:hud];
    
    // 显示HUD
    [hud showAnimated:YES];
    
    // 隐藏HUD
    [hud hideAnimated:YES afterDelay:HUD_TIP_TIME];
    
}

#pragma mark - 显示加载提示
/// 显示加载提示
+ (MBProgressHUD *)showLoading
{
    return [self showMessage:nil toView:nil];
}

/// 显示加载提示
/// @param view 显示MBProgressHUD的视图
+ (MBProgressHUD *)showLoadingToView:(UIView *)view
{
    return [self showMessage:nil toView:view];
}

/// 显示加载提示信息
/// @param message 信息内容
+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

/// 显示加载提示信息
/// @param message 信息内容
/// @param view 显示MBProgressHUD的视图
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view
{
    [self hideHUD];
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
        if (view == nil) {
            return nil;
        }
    }

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    
    // 设置HUD显示最小时间避免显示后立即被隐藏。注释掉这个，防止同时出现多个HUD
    // hud.minShowTime = HUD_TIP_TIME;
    
    // graceTime防止过短的hud显示
    // hud.graceTime = HUD_GRACE_TIME;
    
    // 隐藏HUD后从父视图移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 内容颜色（标签、按钮、指示器等）
    hud.contentColor = [UIColor whiteColor];
    
    // 边框
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    
    // 显示文本
    hud.label.text = message;
    
    // 添加到父视图
    [view addSubview:hud];
    
    // 显示HUD
    [hud showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HUD_GRACE_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 隐藏HUD
        [hud hideAnimated:YES afterDelay:15];
    });
    
    return hud;
}

#pragma mark - 隐藏提示
/// 手动关闭MBProgressHUD
+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

/// 手动关闭MBProgressHUD
/// @param view 显示MBProgressHUD的视图
+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
        if (view == nil) {
            return;
        }
    }
    
    [self hideHUDForView:view animated:YES];
}

@end
