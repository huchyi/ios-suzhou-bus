//
//  StationViewController.h
//  IosSuzhouBus
//
//  Created by 黄传一 on 11/14/16.
//  Copyright © 2016 黄传一. All rights reserved.
//
//
//  LineController.h
//  IosSuzhouBus
//
//  Created by 黄传一 on 11/8/16.
//  Copyright © 2016 黄传一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *list;
@property (strong, nonatomic) NSString *stationName;
@property (strong, nonatomic) NSString *stationGuid;
@end


