//
//  MJAlertManager.m
//  Common
//
//  Created by 黄磊 on 2017/10/10.
//

#import "MJAlertManager.h"
#import "MJAlertAction.h"
#import HEADER_LOCALIZE
#import HEADER_WINDOW_ROOT_VIEW_CONTROLLER

static UIWindow *s_alertWindow = nil;
static NSMutableArray *s_arrAlerts = nil;
static BOOL s_alertWindowInShow = NO;


@implementation MJAlertManager

+ (BOOL)haveAnythingInShow
{
    if (s_arrAlerts && [s_arrAlerts count] > 0) {
        return YES;
    }
    return NO;
}

#pragma mark -Windows

+ (UIWindow *)alertWindow
{
    if (s_alertWindow == nil) {
        s_alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [s_alertWindow setBackgroundColor:[UIColor clearColor]];
        s_alertWindow.windowLevel = UIWindowLevelAlert;
        
        UIViewController *rootVC = [[THEWindowRootViewController alloc] init];
        [rootVC.view setBackgroundColor:[UIColor blackColor]];
        [rootVC.view setAlpha:0];
        
        [s_alertWindow setRootViewController:[[THEWindowRootViewController alloc] init]];
    }
    return s_alertWindow;
}

+ (void)showAlertWindow
{
    if (s_alertWindowInShow) {
        return;
    }
    s_alertWindowInShow = YES;
    LogTrace(@"{ AlertWindow } show");
    UIWindow *alertWindow = [self alertWindow];
    [alertWindow makeKeyAndVisible];
}

+ (void)hideAlertWindow
{
    if (!s_alertWindowInShow) {
        return;
    }
    s_alertWindowInShow = NO;
    LogTrace(@"{ AlertWindow } hide");
    [s_alertWindow resignKeyWindow];
    [s_alertWindow setHidden:YES];
    s_alertWindow = nil;
}


#pragma mark - ShowAlert

+ (void)showAlertController:(UIAlertController *)alertVC
{
    if (s_arrAlerts == nil) {
        s_arrAlerts = [[NSMutableArray alloc] init];
    }
    
    // 添加alert
    [s_arrAlerts addObject:alertVC];
    
    UIViewController *rootVC = [[self alertWindow] rootViewController];
    if ([rootVC presentedViewController]) {
        [rootVC.presentedViewController dismissViewControllerAnimated:NO completion:^{
            [self showAlertWindow];
            [rootVC presentViewController:alertVC animated:YES completion:NULL];
        }];
    } else {
        [self showAlertWindow];
        [rootVC presentViewController:alertVC animated:YES completion:NULL];
    }
    
}

+ (void)dismissAlertController:(UIAlertController *)alertVC completion:(void (^)(void))completion
{
    [alertVC dismissViewControllerAnimated:NO completion:completion];
}

+ (void)alertControllerBeenDismissed:(UIAlertController *)alertVC
{
    if (s_arrAlerts == nil) {
        s_arrAlerts = [[NSMutableArray alloc] init];
    }
    
    [s_arrAlerts removeObject:alertVC];
    
    // 判断数组
    if ([s_arrAlerts count] == 0) {
        [self hideAlertWindow];
        return;
    }
    
    // 显示最后一个alert
    UIAlertController *lastAlert = [s_arrAlerts lastObject];
    UIViewController *rootVC = [[self alertWindow] rootViewController];
    if (rootVC.presentedViewController) {
        if (rootVC.presentedViewController == lastAlert) {
        } else {
            // 这种情况基本不存在
            [rootVC.presentedViewController dismissViewControllerAnimated:NO completion:^{
                [rootVC presentViewController:lastAlert animated:YES completion:NULL];
            }];
        }
        return;
    }
    [rootVC presentViewController:lastAlert animated:YES completion:NULL];
}


#pragma mark - Public

+ (void)clickAlert:(UIAlertController *)alertController atIndex:(NSInteger)buttonIndex
{
    if (![alertController isKindOfClass:[UIAlertController class]]) {
        return;
    }
    UIViewController *rootVC = [[self alertWindow] rootViewController];
    if (rootVC.presentedViewController == alertController) {
        [self dismissAlertController:alertController completion:^{
            // 这里这样处理是为了执行后面的代码
            [self clickAlert:alertController atIndex:buttonIndex];
        }];
        return;
    }
    if (alertController.actions.count == 0) {
        [self alertControllerBeenDismissed:alertController];
        return;
    }
    // 如果这个列表中已经不存在该alert了，可能已被用户点击，后面不需要执行
    if (![s_arrAlerts containsObject:alertController]) {
        return;
    }
    if (buttonIndex == -1) {
        // 读取最后一个
        MJAlertAction *action = (MJAlertAction *)[alertController.actions lastObject];
        if (action.style == UIAlertActionStyleDestructive) {
            [action executeHandle];
            return;
        }
    } else {
        // 判断取消
        NSInteger offset = 0;
        // 判断第一个
        MJAlertAction *firstAction = (MJAlertAction *)[alertController.actions firstObject];
        if (firstAction.style == UIAlertActionStyleCancel) {
            offset++;
        }
        NSInteger index = buttonIndex + offset;
        if (index >= 0 && index < alertController.actions.count) {
            MJAlertAction *clickAction = (MJAlertAction *)alertController.actions[index];
            [clickAction executeHandle];
            return;
        }
    }
    [self alertControllerBeenDismissed:alertController];
}


+ (void)refreshAlert:(UIAlertController *)alertController title:(NSString *)title message:(NSString *)message
{
    alertController.title = title;
    alertController.message = message;
}


#pragma mark - Alert

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    return [self showAlertWithTitle:title message:message cancel:nil confirm:locString(@"OK") completion:NULL];
}

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(NSInteger))completion
{
    return [self showAlertWithTitle:title message:message cancel:nil confirm:locString(@"OK") completion:completion];
}

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm completion:(void (^)(NSInteger))completion
{
    return [self showAlertWithTitle:title message:message cancel:cancel confirm:confirm destroy:nil otherButtons:nil completion:completion];
}

+ (UIAlertController *)showAlertWith:(NSDictionary *)alertInfo completion:(void (^)(NSInteger selectIndex))completion
{
#ifdef MODULE_LOCALIZE
    NSDictionary *dicLocalize = [alertInfo objectForKey:kLocalizable];
    NSString *tableId = nil;
    if (dicLocalize) {
        tableId = [self addThisLocalize:dicLocalize withAlertInfo:alertInfo];
    }
#endif
    NSString *title = [self displayStringFor:@"title" with:alertInfo];
    NSString *message = [self displayStringFor:@"message" with:alertInfo];
    NSString *cancel = [self displayStringFor:@"cancel" with:alertInfo];
    NSString *confirm = [self displayStringFor:@"confirm" with:alertInfo];
    NSString *destroy = [self displayStringFor:@"destroy" with:alertInfo];
    NSArray *arrBtns = alertInfo[@"btns"];
    
#ifdef MODULE_LOCALIZE
    [[MJLocalize sharedInstance] removeLocalizedWith:tableId];
#endif
    
    return [self showAlertWithTitle:title message:message cancel:cancel confirm:confirm destroy:destroy otherButtons:arrBtns completion:completion];
}

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm destroy:(NSString *)destroy otherButtons:(NSArray *)arrBtns completion:(void (^)(NSInteger))completion
{
    return [self showAlertWithTitle:title message:message cancel:cancel confirm:confirm destroy:destroy otherButtons:arrBtns style:UIAlertControllerStyleAlert completion:completion];;
}

+ (UIAlertController *)showAlertNoBtnsWithTitle:(id)title message:(id)message
{
    return [self showAlertWithTitle:title message:message cancel:nil confirm:nil completion:NULL];
}

#pragma mark - ActionSheet


+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title message:(NSString *)message
{
    return [self showActionSheetWithTitle:title message:message cancel:nil confirm:locString(@"OK") completion:NULL];
}

+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(NSInteger))completion
{
    return [self showActionSheetWithTitle:title message:message cancel:nil confirm:locString(@"OK") completion:completion];
}

+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm completion:(void (^)(NSInteger))completion
{
    return [self showActionSheetWithTitle:title message:message cancel:cancel confirm:confirm destroy:nil otherButtons:nil completion:completion];
}

+ (UIAlertController *)showActionSheetWith:(NSDictionary *)alertInfo completion:(void (^)(NSInteger selectIndex))completion
{
#ifdef MODULE_LOCALIZE
    NSDictionary *dicLocalize = [alertInfo objectForKey:kLocalizable];
    NSString *tableId = nil;
    if (dicLocalize) {
        tableId = [self addThisLocalize:dicLocalize withAlertInfo:alertInfo];
    }
#endif
    NSString *title = [self displayStringFor:@"title" with:alertInfo];
    NSString *message = [self displayStringFor:@"message" with:alertInfo];
    NSString *cancel = [self displayStringFor:@"cancel" with:alertInfo];
    NSString *confirm = [self displayStringFor:@"confirm" with:alertInfo];
    NSString *destroy = [self displayStringFor:@"destroy" with:alertInfo];
    NSArray *arrBtns = alertInfo[@"btns"];
    
#ifdef MODULE_LOCALIZE
    [[MJLocalize sharedInstance] removeLocalizedWith:tableId];
#endif
    
    return [self showActionSheetWithTitle:title message:message cancel:cancel confirm:confirm destroy:destroy otherButtons:arrBtns completion:completion];
}

+ (UIAlertController *)showActionSheetWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm destroy:(NSString *)destroy otherButtons:(NSArray *)arrBtns completion:(void (^)(NSInteger))completion
{
    return [self showAlertWithTitle:title message:message cancel:cancel confirm:confirm destroy:destroy otherButtons:arrBtns style:UIAlertControllerStyleActionSheet completion:completion];
}


#pragma mark - Private

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm destroy:(NSString *)destroy otherButtons:(NSArray *)arrBtns style:(UIAlertControllerStyle)style completion:(void (^)(NSInteger))completion
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    
    void (^alertClick)(NSInteger ) = ^(NSInteger selectIndex) {
        [self alertControllerBeenDismissed:alertVC];
        completion ? completion(selectIndex) : 0;
    };
    
    NSInteger offset = 1;
    // 取消
    if (cancel) {
        [alertVC addAction:[MJAlertAction actionWithTitle:cancel style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            alertClick(0);
        }]];
    }
    
    // 确定
    if (confirm) {
        [alertVC addAction:[MJAlertAction actionWithTitle:confirm style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            alertClick(1);
        }]];
        offset++;
    }
    
    if (arrBtns) {
        for (NSInteger i=0, len=arrBtns.count; i < len; i++) {
            id data = arrBtns[i];
            NSString *btnTitle = data;
            if ([data isKindOfClass:[NSDictionary class]]) {
                btnTitle = [self displayStringFor:@"title" with:data];
            }
            [alertVC addAction:[MJAlertAction actionWithTitle:btnTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                alertClick(i+offset);
            }]];
        }
    }
    
    // 销毁
    if (destroy) {
        [alertVC addAction:[MJAlertAction actionWithTitle:destroy style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            alertClick(-1);
        }]];
    }
    
    [self showAlertController:alertVC];
    return alertVC;
}


#ifdef MODULE_LOCALIZE
+ (NSString *)addThisLocalize:(NSDictionary *)dicLocalize withAlertInfo:(NSDictionary *)dicInfo
{
    if (![dicLocalize objectForKey:@"Base"] && dicInfo) {
        NSMutableDictionary *dicBase = [[NSMutableDictionary alloc] init];
        NSString *titleKey = [dicInfo objectForKey:@"titleKey"];
        if (titleKey.length > 0) {
            [dicBase setObject:dicInfo[@"title"] forKey:titleKey];
        }
        NSString *messageKey = [dicInfo objectForKey:@"messageKey"];
        if (messageKey.length > 0) {
            [dicBase setObject:dicInfo[@"message"] forKey:messageKey];
        }
        NSString *goKey = [dicInfo objectForKey:@"confirmKey"];
        NSString *go = [dicInfo objectForKey:@"confirm"];
        if (goKey.length > 0 && go.length > 0) {
            [dicBase setObject:go forKey:goKey];
        }
        NSString *cancelKey = [dicInfo objectForKey:@"cancelKey"];
        NSString *cancel = [dicInfo objectForKey:@"cancel"];
        if (cancelKey.length > 0 && go.length > 0) {
            [dicBase setObject:cancel forKey:cancelKey];
        }
        NSMutableDictionary *dicMutal = [dicLocalize mutableCopy];
        [dicMutal setObject:dicBase forKey:@"Base"];
        dicLocalize = dicMutal;
    }
    return [[MJLocalize sharedInstance] addLocalizedStringWith:dicLocalize];
}
#endif

#pragma mark -Display

+ (NSString *)displayStringFor:(NSString *)str with:(NSDictionary *)dic
{
    // 查找本地化字符串
    NSString *strKey = [str stringByAppendingString:@"Key"];
    NSString *strValue = [dic objectForKey:strKey];
    if (strValue) {
        NSString *displayStr = locString(strValue);
        if (![displayStr isEqualToString:strValue]) {
            return displayStr;
        }
    }
    return dic[str];
}


@end
