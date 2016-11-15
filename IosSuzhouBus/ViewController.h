//
//  ViewController.h
//  IosSuzhouBus
//
//  Created by 黄传一 on 9/18/16.
//  Copyright © 2016 黄传一. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
 @property (strong, nonatomic) NSMutableArray *list;

@end

