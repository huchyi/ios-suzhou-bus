//
//  LineController.m
//  IosSuzhouBus
//
//  Created by 黄传一 on 11/8/16.
//  Copyright © 2016 黄传一. All rights reserved.
//



#import "LineViewController.h"
#import "StationViewController.h"
#import "AFHTTPSessionManager.h"
#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define PHOTO_LINE_TAG 3
#define PHOTO_LINE2_TAG 32
#define PHOTO_STATION_NUM_TAG 4
#define PHOTO_STATION_TAG 42
#define PHOTO_CAR_TAG 5

@interface LineViewController ()<UITableViewDataSource, UITableViewDelegate>{
    //loading
    UIActivityIndicatorView *indicator;
    //title
    UITextField *titleTF;
    //方向
    UITextField *tipsDirectionTF;
    UITextField *directionTF;
    //早晚时间
    UITextField *tipsTimeTF;
    UITextField *timeTF;
    BOOL isFirst;
    
    
    NSMutableArray *mutablearray;
    CGFloat width;
    CGFloat height;
    
}
@property (nonatomic, weak)  UITableView * yourTableView;

@end

@implementation LineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    isFirst = YES;
    [self getScreeenData];
    
    [self createTabViewUI];
    // 集成刷新控件
    [self setupRefresh];
    [self loadingView];
    
    [self finish];
}


- (void)viewDidUnload{
    [super viewDidUnload];
    self.list = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getScreeenData{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    width = size.width;
    height = size.height;
}

-(void)loadingView{
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
    indicator.tag = 103;
    
    //设置显示样式,见UIActivityIndicatorViewStyle的定义
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    
    //设置背景色
    indicator.backgroundColor = [UIColor blackColor];
    
    //设置背景透明
    indicator.alpha = 0.5;
    
    //设置背景为圆角矩形
    indicator.layer.cornerRadius = 6;
    indicator.layer.masksToBounds = YES;
    //设置显示位置
    [indicator setCenter:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0)];
    
    //开始显示Loading动画
    [indicator startAnimating];
    
    [self.view addSubview:indicator];
}


//右滑动返回上一界面
-(void) finish{
    // 获取系统自带滑动手势的target对象
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    // 设置手势代理，拦截手势触发
    pan.delegate = self;
    // 给导航控制器的view添加全屏滑动手势
    [self.view addGestureRecognizer:pan];
    // 禁止使用系统自带的滑动手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    if(self.navigationController.childViewControllers.count == 1){
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    return YES;
}

-(void)handleNavigationTransition:(UIPanGestureRecognizer *)g{
    
}



-(void) addTileTextField: (NSString *)lineNum : (NSString *)direction : (NSString *)time{
    //title
    titleTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 20, width - 40, 50)];
    titleTF.borderStyle = UITextBorderStyleNone;
    titleTF.backgroundColor = [UIColor whiteColor];
    titleTF.textColor = [UIColor blackColor];
    titleTF.font = [UIFont fontWithName:@"title" size:20.0f];
    titleTF.text = lineNum;
    titleTF.textAlignment = NSTextAlignmentCenter;
    titleTF.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter; //水平居中对齐
    titleTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //垂直居中
    
    [self.view addSubview:titleTF];
    
    
    //方向tips
    tipsDirectionTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 70, 80, 20)];
    tipsDirectionTF.borderStyle = UITextBorderStyleNone;
    tipsDirectionTF.backgroundColor = [UIColor whiteColor];
    tipsDirectionTF.textColor = [UIColor grayColor];
    tipsDirectionTF.font = [UIFont systemFontOfSize:14.0];
    tipsDirectionTF.text = @"开往：";
    tipsDirectionTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //垂直居中
    [self.view addSubview:tipsDirectionTF];
    
    
    //方向
    directionTF = [[UITextField alloc]initWithFrame:CGRectMake(100, 70, width - 100, 20)];
    directionTF.borderStyle = UITextBorderStyleNone;
    directionTF.backgroundColor = [UIColor whiteColor];
    directionTF.textColor = [UIColor blueColor];
    directionTF.font = [UIFont systemFontOfSize:14.0];
    directionTF.text = direction;
    directionTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //垂直居中
    [self.view addSubview:directionTF];
    
    
    //时间tips
    tipsTimeTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 90, 80, 20)];
    tipsTimeTF.borderStyle = UITextBorderStyleNone;
    tipsTimeTF.backgroundColor = [UIColor whiteColor];
    tipsTimeTF.textColor = [UIColor grayColor];
    tipsTimeTF.font = [UIFont systemFontOfSize:10.0];
    tipsTimeTF.text = @"首末班：";
    tipsTimeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //垂直居中
    [self.view addSubview:tipsTimeTF];
    
    
    //时间
    timeTF = [[UITextField alloc]initWithFrame:CGRectMake(100, 90, width - 100, 20)];
    timeTF.borderStyle = UITextBorderStyleNone;
    timeTF.backgroundColor = [UIColor whiteColor];
    timeTF.textColor = [UIColor grayColor];
    timeTF.font = [UIFont systemFontOfSize:10.0];
    timeTF.text = time;
    timeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //垂直居中
    [self.view addSubview:timeTF];
    
}


/**
 *  集成下拉刷新
 */
-(void)setupRefresh
{
    UIRefreshControl *control =[[UIRefreshControl alloc]init];
    [control addTarget:self action:@selector(getNetWorkData:) forControlEvents:UIControlEventValueChanged];
    [self.yourTableView addSubview:control];
    
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    [control beginRefreshing];
    
    [self getNetWorkData:control];
}


//UITableView start
- (void)createTabViewUI{
    mutablearray =[[NSMutableArray alloc] initWithObjects: @"",nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 100, width - 20, height - 100) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.yourTableView = tableView;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /**
     {
     InTime = "";
     SCode = CZF;
     SName = "\U552f\U4ead\U87f9\U5e02\U573a";
     "is_vicinity" = 0;
     "s_num" = 8;
     "s_num_str" = "";
     },
     {
     InTime = "15:05:11";
     SCode = ABS;
     SName = "\U6d45\U6c34\U6e7e";
     "is_vicinity" = 0;
     "s_num" = "-1";
     "s_num_str" = "\U82cfE-3E277  \U5df2\U7ecf\U8fdb\U7ad9 15:05:11";
     },
     
     */
    
    static NSString *CellIdentifier = @"Cell";
    UILabel *stationNumUL,*stationNameUL, *inTimeUL;
    UIImageView *stationUV,*line1UV,*line2UV,*carUV;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        
        stationUV = [[UIImageView alloc] initWithFrame:CGRectMake(-23, 5.0, 16.0, 16.0)];
        stationUV.tag = PHOTO_STATION_TAG;
        stationUV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stationUV];
        
        line1UV = [[UIImageView alloc] initWithFrame:CGRectMake(-20, 0.0, 10.0, 5.0)];
        line1UV.tag = PHOTO_LINE_TAG;
        line1UV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:line1UV];
        
        line2UV = [[UIImageView alloc] initWithFrame:CGRectMake(-20, 21, 10.0, 28)];
        line2UV.tag = PHOTO_LINE2_TAG;
        line2UV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:line2UV];
        
        stationNumUL = [[UILabel alloc] initWithFrame:CGRectMake(-23, 5.0, 16, 16)];
        stationNumUL.tag = PHOTO_STATION_NUM_TAG;
        stationNumUL.font = [UIFont systemFontOfSize:8.0];
        stationNumUL.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        stationNumUL.textColor = [UIColor blackColor];
        stationNumUL.textAlignment = NSTextAlignmentCenter;
        stationNumUL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stationNumUL];
        
        stationNameUL = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width - 40, 25.0)];
        stationNameUL.tag = MAINLABEL_TAG;
        stationNameUL.font = [UIFont systemFontOfSize:14.0];
        stationNameUL.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        stationNameUL.textColor = [UIColor blackColor];
        stationNameUL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stationNameUL];
        
        inTimeUL = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width - 80, 25.0)];
        inTimeUL.tag = SECONDLABEL_TAG;
        inTimeUL.font = [UIFont systemFontOfSize:12.0];
        inTimeUL.textAlignment = NSTextAlignmentRight;
        inTimeUL.textColor = [UIColor darkGrayColor];
        inTimeUL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:inTimeUL];
        
        carUV = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 25.0, 20.0, 20.0)];
        carUV.tag = PHOTO_CAR_TAG;
        carUV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:carUV];
        
        
    } else {
        stationUV = (UIImageView *)[cell.contentView viewWithTag:PHOTO_STATION_TAG];
        line1UV = (UIImageView *)[cell.contentView viewWithTag:PHOTO_LINE_TAG];
        line2UV = (UIImageView *)[cell.contentView viewWithTag:PHOTO_LINE2_TAG];
        carUV = (UIImageView *)[cell.contentView viewWithTag:PHOTO_CAR_TAG];
        stationNumUL = (UILabel *)[cell.contentView viewWithTag:PHOTO_STATION_NUM_TAG];
        stationNameUL = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
        inTimeUL = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *rowDict = [self.list objectAtIndex:row];
    UIImage *imageStation = [UIImage imageNamed:@"line_station_new_icon"];
    UIImage *imageStation2 = [UIImage imageNamed:@"line_station_end_new_icon"];
    stationUV.image = row == 0 || row == [self.list count] - 1 ? imageStation2:imageStation ;
    UIImage *image = [UIImage imageNamed:@"transfer_detail_line"];
    UIImage *image2 = [UIImage imageNamed:@"transfer_detail_line"];
    line1UV.image = image;
    line2UV.image = image2;
    if(row == 0){
        line1UV.hidden = YES;
    }else if(row == [self.list count] - 1){
        line2UV.hidden = YES;
    }
    stationNumUL.text = [NSString stringWithFormat:@"%lu",(unsigned long)(row + 1)]; ;
    stationNameUL.text = rowDict[@"SName"];
    NSString *inTime = rowDict[@"InTime"];
    if(![self isBlankString:inTime]){
        if(row == 0){
            inTimeUL.text = @"即将发车";
        }else if(row == [self.list count] - 1){
            inTimeUL.text = [inTime stringByAppendingFormat:@"%@",@"到达终点"];
        }else{
            inTimeUL.text = [inTime stringByAppendingFormat:@"%@",@"进站"];
            UIImage *imageCar = [UIImage imageNamed:@"transfer_car"];
            carUV.image = imageCar;
        }
        
    }
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *rowDict = [self.list objectAtIndex:[indexPath row]];
    
    StationViewController *nextPage = [[StationViewController alloc] init];
    //所要跳转页面AloneSetPrizeViewController中有个属性dictionary1是个NSMutableDictionary类型的容器
    nextPage.stationName = rowDict[@"SName"];
    nextPage.stationGuid = rowDict[@"SCode"];
    //使用pushViewController跳转到下一页面
    [self.navigationController pushViewController:nextPage animated:YES];
}


//UITableView end


- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}





#pragma mark - 创建请求者
-(AFHTTPSessionManager *)manager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 超时时间
    manager.requestSerializer.timeoutInterval = 10 * 1000;
    
    // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 上传JSON格式
    
    // 声明获取到的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFN不会解析,数据是data，需要自己解析
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // AFN会JSON解析返回的数据
    // 个人建议还是自己解析的比较好，有时接口返回的数据不合格会报3840错误，大致是AFN无法解析返回来的数据
    return manager;
}


- (void)getNetWorkData:(UIRefreshControl *)control{
    NSLog(@"getLineInfo input:%@",_lineNum);
    
    if(isFirst){
        isFirst = NO;
        [indicator startAnimating];
    }
    // get请求也可以直接将参数放在字典里，AFN会自己讲参数拼接在url的后面，不需要自己凭借
    NSDictionary *param = @{@"Guid":_lineNum,@"uid":@"0",@"DeviceID":@"8745663",@"sign":@"539f272911d2bb23117ea6211cce1bb5"};
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:@"http://content.2500city.com/api18/bus/getLineInfo" parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"getLineInfo dict:%@",dict);

            
            NSString *ss = [NSString stringWithFormat:@"%@",[dict objectForKey:@"errorCode"]];
            if ([ss isEqualToString:@"0"]) {
                NSDictionary *dict2 = dict[@"data"];
                
                NSString *LDirection =dict2[@"LDirection"]; //方向
                NSString *LFStdETime =dict2[@"LFStdETime"]; //晚
                NSString *LFStdFTime =dict2[@"LFStdFTime"];//早
                NSString *LName =dict2[@"LName"]; //名字
                [self addTileTextField:LName:LDirection: [LFStdFTime stringByAppendingFormat:@"--%@",LFStdETime]];
                
                
                mutablearray = dict2[@"StandInfo"];
                self.list = mutablearray;
                [self.yourTableView reloadData];
            }
            
        }
        
        if([indicator isAnimating]){
            [indicator stopAnimating];
        }
        
        // 3. 结束刷新
        [control endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 请求失败
        if([indicator isAnimating]){
            [indicator stopAnimating];
        }
        
        // 3. 结束刷新
        [control endRefreshing];
    }];
}


@end
