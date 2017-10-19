//
//  MJAlertManager.h
//  Common
//
//  Created by 黄磊 on 2017/10/10.
//  统一管理Alert和ActionSheet弹窗

#import <Foundation/Foundation.h>

@interface MJAlertManager : NSObject

/// 是否有弹框正在显示
+ (BOOL)haveAnythingInShow;

/// 代码点击一个Alert来销毁它
+ (void)clickAlert:(UIAlertController *)alertController atIndex:(NSInteger)buttonIndex;

+ (void)refreshAlert:(UIAlertController *)alertController title:(NSString *)title message:(NSString *)message;

#pragma mark - Alert

/// 显示一个普通弹框，包括本地化的确定按钮
+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/// 显示一个普通弹框，包括本地化的确定按钮，可以接受点击回掉
+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(NSInteger selectIndex))completion;

/// 显示一个弹框，自己设置按钮标题，自己处理按钮本地化，可以接受点击回掉
+ (UIAlertController *)showAlertWithTitle:(NSString *)title
                                  message:(NSString *)message
                                   cancel:(NSString *)cancel
                                  confirm:(NSString *)confirm
                               completion:(void (^)(NSInteger selectIndex))completion;
/// 显示一个弹框，alertInfo可以保护本地化信息，可以接受点击回掉
+ (UIAlertController *)showAlertWith:(NSDictionary *)alertInfo completion:(void (^)(NSInteger selectIndex))completion;

/// 显示一个弹框，自己设置按钮标题，自己处理按钮本地化，可以接受点击回掉
+ (UIAlertController *)showAlertWithTitle:(NSString *)title
                                  message:(NSString *)message
                                   cancel:(NSString *)cancel
                                  confirm:(NSString *)confirm
                                  destroy:(NSString *)destroy
                             otherButtons:(NSArray *)arrBtns
                               completion:(void (^)(NSInteger selectIndex))completion;

/// 显示一个没有按钮的弹框，这个弹框只能用代码销毁
+ (UIAlertController *)showAlertNoBtnsWithTitle:title message:message;

#pragma mark - 显示自定义View，后续开发

//+ (MJAlertController *)showCustomAlertView:(UIView *)customView;
//
//+ (MJAlertController *)showCustomAlertView:(UIView *)customView
//                                    cancel:(UIButton *)cancel
//                                   confirm:(UIButton *)confirm
//                                completion:(void (^)(NSInteger selectIndex))completion;
//
//+ (MJAlertController *)showCustomAlertView:(UIView *)customView
//                                    cancel:(UIButton *)cancel
//                                   confirm:(UIButton *)confirm
//                                   destroy:(UIButton *)destroy
//                              otherButtons:(NSArray *)arrBtns
//                                completion:(void (^)(NSInteger selectIndex))completion;

#pragma ActionSheet

/// 显示一个普通弹框，包括本地化的确定按钮
+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title message:(NSString *)message;

/// 显示一个普通弹框，包括本地化的确定按钮，可以接受点击回掉
+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(NSInteger selectIndex))completion;

/// 显示一个弹框，自己设置按钮标题，自己处理按钮本地化，可以接受点击回掉
+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title
                                        message:(NSString *)message
                                         cancel:(NSString *)cancel
                                        confirm:(NSString *)confirm
                                     completion:(void (^)(NSInteger selectIndex))completion;
/// 显示一个弹框，alertInfo可以保护本地化信息，可以接受点击回掉
+ (UIAlertController *)showActionSheetWith:(NSDictionary *)alertInfo completion:(void (^)(NSInteger selectIndex))completion;

/// 显示一个弹框，自己设置按钮标题，自己处理按钮本地化，可以接受点击回掉
+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title
                                        message:(NSString *)message
                                         cancel:(NSString *)cancel
                                        confirm:(NSString *)confirm
                                        destroy:(NSString *)destroy
                                   otherButtons:(NSArray *)arrBtns
                                     completion:(void (^)(NSInteger selectIndex))completion;



@end
