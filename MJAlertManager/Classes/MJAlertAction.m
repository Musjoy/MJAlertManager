//
//  MJAlertAction.m
//  Common
//
//  Created by 黄磊 on 2017/10/18.
//

#import "MJAlertAction.h"

@interface MJAlertAction ()

@property (nonatomic, strong) void (^handlerBak)(UIAlertAction *) ;

@end

@implementation MJAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler
{
    MJAlertAction *alertAction = [super actionWithTitle:title style:style handler:handler];
    alertAction.handlerBak = handler;
    return alertAction;
}

- (void)executeHandle
{
    self.handlerBak(self);
}

@end

