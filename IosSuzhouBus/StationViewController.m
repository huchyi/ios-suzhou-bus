//
//  StationViewController.m
//  IosSuzhouBus
//
//  Created by 黄传一 on 11/14/16.
//  Copyright © 2016 黄传一. All rights reserved.
//


#import "StationViewController.h"
#import "AFHTTPSessionManager.h"
#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define THIRDLABEL_TAG 3
#define FOURLABEL_TAG 4

@interface StationViewController ()<UITableViewDataSource, UITableViewDelegate>{
    //loading
    UIActivityIndicatorView *indicator;
    //title
    UITextField *titleTF;
    BOOL isFirst;
    
    
    NSMutableArray *mutablearray;
    CGFloat width;
    CGFloat height;
    
}
@property (nonatomic, weak)  UITableView * yourTableView;

@end

@implementation StationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    isFirst = YES;
    [self getScreeenData];
    
    [self addTileTextField:_stationName];
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



-(void) addTileTextField: (NSString *)name{
    //title
    titleTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 20, width - 40, 50)];
    titleTF.borderStyle = UITextBorderStyleNone;
    titleTF.backgroundColor = [UIColor whiteColor];
    titleTF.textColor = [UIColor blackColor];
    titleTF.font = [UIFont fontWithName:@"title" size:20.0f];
    titleTF.text = name;
    titleTF.textAlignment = NSTextAlignmentCenter;
    titleTF.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter; //水平居中对齐
    titleTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //垂直居中
    
    [self.view addSubview:titleTF];
    
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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 80, width - 20, height - 80) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.allowsSelection = false;
    //    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
     "errorCode": 0,
     "errorMsg": "",
     "data": {
     "is_favorite": 0,
     "info": {
     "SCode": "HYF",
     "SName": "\u6c7d\u8f66\u5317\u7ad9\u5317",
     "baidu_lat": 31.337307,
     "baidu_lng": 120.630023,
     "address": "\u5317\u73af\u4e1c\u8def\u5317",
     "long_info": "\u7ea6112.15\u5343\u7c73"
     },
     "list": [{
     "Guid": "192EA3E1-2058-45E7-A90B-4B87B74EEB95",
     "LName": "812\u8def",
     "LDirection": "\u72ec\u5885\u6e56\u9ad8\u6559\u533a\u9996\u672b\u7ad9=>\u91c7\u83b2\u6362\u4e58\u4e2d\u5fc3\uff08\u5546\u4e1a\u8857\uff09",
     "SName": "\u6c7d\u8f66\u5317\u7ad9\u5317",
     "Distince": 12,
     "Distince_str": "12\u7ad9"
     }]
     
     */
    
    static NSString *CellIdentifier = @"Cell";
    UILabel *stationNameUL, *inNumUL, *LDirection;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        
        stationNameUL = [[UILabel alloc] initWithFrame:CGRectMake(-20, 0.0, width - 40, 26)];
        stationNameUL.tag = MAINLABEL_TAG;
        stationNameUL.font = [UIFont systemFontOfSize:14.0];
        stationNameUL.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        stationNameUL.textColor = [UIColor blueColor];
        stationNameUL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stationNameUL];
        
        inNumUL = [[UILabel alloc] initWithFrame:CGRectMake(-20, 0.0, width - 80, 26)];
        inNumUL.tag = SECONDLABEL_TAG;
        inNumUL.font = [UIFont systemFontOfSize:14.0];
        inNumUL.textAlignment = NSTextAlignmentRight;
        inNumUL.textColor = [UIColor darkGrayColor];
        inNumUL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:inNumUL];
        
        LDirection = [[UILabel alloc] initWithFrame:CGRectMake(-20, 18, width - 80, 25)];
        LDirection.tag = THIRDLABEL_TAG;
        LDirection.font = [UIFont systemFontOfSize:12.0];
        LDirection.textColor = [UIColor lightGrayColor];
        LDirection.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:LDirection];

        
    } else {
        stationNameUL = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
        inNumUL = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
        LDirection = (UILabel *)[cell.contentView viewWithTag:THIRDLABEL_TAG];
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *rowDict = [self.list objectAtIndex:row];
    
    NSString *name = rowDict[@"LName"];
    stationNameUL.text = name;
    
    NSString *distince_str = [NSString stringWithFormat:@"%@",rowDict[@"Distince"]];
    if(![self isBlankString:distince_str]){
        if([distince_str isEqualToString:@"-1"]){
            inNumUL.text = @"等待发车";
        }else if([distince_str isEqualToString:@"0"]){
            inNumUL.text = @"已经到站";
        }else{
            inNumUL.textColor = [UIColor colorWithRed:0.800 green:0.400 blue:0.000 alpha:1.00];
            inNumUL.text = [NSString stringWithFormat:@"还有 %@ 站",distince_str];
        //inNumUL.text = [NSString stringWithFormat:@"还有<%@>站",distince_str];
        }
    }
    LDirection.text = [NSString stringWithFormat:@"开往：%@",rowDict[@"LDirection"]];
    
    
    
    
    return cell;
    
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *rowDict = [self.list objectAtIndex:[indexPath row]];
//    NSString *guidStr = rowDict[@"Guid"];
//}

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
    NSLog(@"getStationInfo input:%@",_stationGuid);
    
    if(isFirst){
        isFirst = NO;
        [indicator startAnimating];
    }
    // get请求也可以直接将参数放在字典里，AFN会自己讲参数拼接在url的后面，不需要自己凭借
    NSDictionary *param = @{@"NoteGuid":_stationGuid,@"uid":@"0",@"DeviceID":@"8745663",@"sign":@"539f272911d2bb23117ea6211cce1bb5",@"lat":@"30.33",@"lng":@"120.61"};
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:@"http://content.2500city.com/api18/bus/getStationInfo" parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"getStationInfo dict:%@",dict);
            
            NSString *ss = [NSString stringWithFormat:@"%@",[dict objectForKey:@"errorCode"]];
            if ([ss isEqualToString:@"0"]) {
                NSDictionary *dict2 = dict[@"data"];
                
                mutablearray = dict2[@"list"];
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
