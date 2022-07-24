//
//  MBProgressHUD+YY.h
//  NJWisdomCard
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Weconex. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (YY)

/// 显示成功信息
/// @param message 信息内容
+ (void)showSuccess:(NSString *)message;

/// 显示成功信息
/// @param message 信息内容
/// @param view 显示MBProgressHUD的视图
+ (void)showSuccess:(NSString *)message toView:(UIView *)view;

/// 显示错误信息
/// @param message 信息内容
+ (void)showError:(NSString *)message;

/// 显示错误信息
/// @param message 信息内容
/// @param view 显示MBProgressHUD的视图
+ (void)showError:(NSString *)message toView:(UIView *)view;


/// 显示加载提示
+ (MBProgressHUD *)showLoading;

/// 显示加载提示
/// @param view 显示MBProgressHUD的视图
+ (MBProgressHUD *)showLoadingToView:(UIView *)view;

/// 显示加载提示信息
/// @param message 信息内容
+ (MBProgressHUD *)showMessage:(NSString *)message;

/// 显示加载提示信息
/// @param message 信息内容
/// @param view 显示MBProgressHUD的视图
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


/// 手动关闭MBProgressHUD
+ (void)hideHUD;

/// 手动关闭MBProgressHUD
/// @param view 显示MBProgressHUD的视图
+ (void)hideHUDForView:(UIView *)view;

@end
