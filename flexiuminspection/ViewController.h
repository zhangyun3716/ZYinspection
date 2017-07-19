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

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate>

@property(nonatomic,strong)NSString *emp_no;

@end

