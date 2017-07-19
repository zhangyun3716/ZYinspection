//
//  informationcell.h
//  saptest
//
//  Created by flexium on 2016/10/28.
//  Copyright © 2016年 FLEXium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface informationcell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *planname;
@property (strong, nonatomic) IBOutlet UILabel *placename;

@property (strong, nonatomic) IBOutlet UILabel *plantime;
@property (strong, nonatomic) IBOutlet UILabel *oktimes;
@property (strong, nonatomic) IBOutlet UILabel *ngtimes;


@end
