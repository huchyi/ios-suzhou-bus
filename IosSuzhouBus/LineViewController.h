//
//  LineController.h
//  IosSuzhouBus
//
//  Created by 黄传一 on 11/8/16.
//  Copyright © 2016 黄传一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *list;
@property (strong, nonatomic) NSString *lineNum;
@end

