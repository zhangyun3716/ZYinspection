
/*
 *	_________         __       __
 * |______  /         \ \     / /
 *       / /           \ \   / /
 *      / /             \ \ / /
 *     / /               \   /
 *    / /                 | |
 *   / /                  | |
 *  / /_________          | |
 * /____________|         |_|
 *
 Copyright (c) 2011 ~ 2016 zhangyun. All rights reserved.
 */

#import <UIKit/UIKit.h>

typedef void(^BackBlock)(NSString *str);

@interface ZYScannerView : UIView

@property (nonatomic, copy) BackBlock back;

+ (ZYScannerView *)sharedScannerView;

- (void)showOnView:(UIView *)view block:(BackBlock)block;

- (void)dismiss;

@end
