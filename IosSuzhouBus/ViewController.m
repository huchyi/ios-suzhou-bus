//
//  ViewController.m
//  IosSuzhouBus
//
//  Created by 黄传一 on 9/18/16.
//  Copyright © 2016 黄传一. All rights reserved.
//

#import "ViewController.h"
#import "LineViewController.h"
#import "AFHTTPSessionManager.h"
#import "GKDatabase/GKDatabase.h"
#import "Car.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>{
    UIActivityIndicatorView *indicator;
    UITapGestureRecognizer *tapGr;
    UITextField *textField;
    UIButton *button;
    CGFloat width;
    CGFloat height;
    Boolean *isCanDelete;
    
}
@property (nonatomic, weak)  UITableView * yourTableView;

@end

@implementation ViewController
//@synthesize list = _list;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadingView];
    [self getScreeenData];
    [self addTextField];
    [self addUIButton];
    [self createUI];
    [self closeSoftView];
    
    [self db];
}

- (void)getScreeenData{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    width = size.width;
    height = size.height;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.list = nil;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeSoftView{
    tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view endEditing:YES];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [textField resignFirstResponder];
}



- (void)alertView:(NSString *)text{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleActionSheet];
    // 设置popover指向的item
    alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
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



//btn start
-(void) addUIButton{
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 90, width - 40, 30);
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [button.layer setBorderWidth:1.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 59, 202, 209, 1 });
    [button.layer setBorderColor:colorref];//边框颜色
    
    [button setTitle:@"搜索" forState:UIControlStateNormal];//title
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//title color
    button.backgroundColor = [UIColor whiteColor];
    
    [button addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)butClick{
    NSString *str = textField.text;
    [self getNetWorkData:(NSString *)str];
}


// text start

-(void) addTextField{
    
    textField = [[UITextField alloc]initWithFrame:
                 CGRectMake(20, 50, width - 40, 30)];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    //是否纠错
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    //内容对齐方式
    textField.textAlignment = UITextWritingDirectionLeftToRight; //从左到右
    //设置键盘的样式
    //    textField.keyboardType = UIKeyboardTypeNumberPad; //纯数字
    //return键变成什么键
    //    textField.returnKeyType = UIReturnKeyGo; //标有Go的蓝色按钮
    
    
    textField.placeholder = @"请输入线路号";
    [self.view addSubview:textField];
}



//UITableView start

- (void)createUI{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 130, width - 40, height - 130) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.allowsSelectionDuringEditing=YES;
    
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    
    [tableView addGestureRecognizer:longPressGr];
    
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


///长按删除代码

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.yourTableView];
        
        NSIndexPath * indexPath = [self.yourTableView indexPathForRowAtPoint:point];
        
        if(indexPath == nil) return ;
        
        //add your code here
        
        if(isCanDelete){
            NSDictionary *rowDict = [self.list objectAtIndex:[indexPath row]];
            [self actionSheet:rowDict[@"Guid"]: rowDict[@"LName"]];
        }
        
    }
}

- (void)actionSheet:(NSString *)guid : (NSString *)name{
    NSString *ss = [NSString stringWithFormat:@"你确定要删除公交车 [%@] 吗?",name];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:ss preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteRow:guid];
        [self loadCollection];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

///移动cell的item

//先把默认的删除的图标去掉
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

//返回当前Cell是否可以移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//执行移动操作
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)
sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSUInteger fromRow = [sourceIndexPath row];
    NSUInteger toRow = [destinationIndexPath row];
    
    id object = [self.list objectAtIndex:fromRow];
    
    [self.list removeObjectAtIndex:fromRow];
    [self.list insertObject:object atIndex:toRow];
    
    //清空表格
    [self clearTable];
    //重新插入
    for (NSDictionary *rowDict in self.list) {
        [self insertData:rowDict[@"LName"]:rowDict[@"LDirection"]:rowDict[@"Guid"]];
    }
}


///数据的处理

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TableSampleIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:TableSampleIdentifier];

    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *rowDict = [self.list objectAtIndex:row];
    
    cell.textLabel.text = rowDict[@"LName"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor blueColor];
    
    cell.detailTextLabel.text = rowDict[@"LDirection"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *rowDict = [self.list objectAtIndex:[indexPath row]];
    NSString *guidStr = rowDict[@"Guid"];
    textField.text = @"";
    [self insertData:rowDict[@"LName"]:rowDict[@"LDirection"]:guidStr];
    
    LineViewController *nextPage = [[LineViewController alloc] init];
    //所要跳转页面AloneSetPrizeViewController中有个属性dictionary1是个NSMutableDictionary类型的容器
    nextPage.lineNum = guidStr;
    //使用pushViewController跳转到下一页面
    [self.navigationController pushViewController:nextPage animated:YES];
    
    [self loadCollection];
}

//UITableView end





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





- (void)getNetWorkData: (NSString *)lineName {
    [indicator startAnimating];
    // get请求也可以直接将参数放在字典里，AFN会自己讲参数拼接在url的后面，不需要自己凭借
    NSDictionary *param = @{@"name":lineName};
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:@"http://content.2500city.com/api18/bus/searchLine" parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *ss = [NSString stringWithFormat:@"%@",[dict objectForKey:@"errorCode"]];
            NSLog(@"getNetWorkData... %@" , dict);
            if ([ss isEqualToString:@"0"]) {
                NSDictionary *dict2 = dict[@"data"];
                self.list = dict2[@"list"];
                [self.yourTableView reloadData];
                [_yourTableView setEditing:NO animated:YES];
                isCanDelete = FALSE;
            }else{
                [self alertView:@"暂无数据" ];
            }
        } else {
            [self alertView:@"暂无数据" ];
        }
        [indicator stopAnimating];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 请求失败
        [self alertView:@"请求失败" ];
        [indicator stopAnimating];
    }];
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


///*******************
///  下面为数据库操作
///*******************

-(void)db{
    [self openDatabase];
    [self createTabel];
    [self loadCollection];
    
}

-(void)loadCollection{
    
    NSArray *array =  [self selectAllData];
    if(array && [array count] >0){
        NSString *string = @"{\"list\":[";
        for (int i = 0; i < [array count]; i++) {
            
            string = [NSString stringWithFormat:@"%@{\"%@\":\"%@\",\"%@\":\"%@\",\"%@\":\"%@\"},",
                      string,
                      @"LName",[array[i] valueForKey:@"LName"],
                      @"LDirection",[array[i] valueForKey:@"LDirection"],
                      @"Guid",[array[i] valueForKey:@"Guid"]];
            
        }
        string = [string substringToIndex:([string length]-1)];
        string = [string stringByAppendingString:@"]}"];
        NSDictionary *dic = [self dictionaryWithJsonString: string];
        self.list = dic[@"list"];
        [self.yourTableView reloadData];
        isCanDelete = TRUE;
        [_yourTableView setEditing:YES animated:YES];
    }else{
        self.list = nil;
        [self.yourTableView reloadData];
        [_yourTableView setEditing:YES animated:YES];
    }
    
    
}

///打开数据库
- (void)openDatabase{
    if ([[GKDatabaseManager sharedManager]openDatabase]) {
        NSLog(@"数据库打开成功");
    }else {
        NSLog(@"数据库打开失败");
    }
}
/// 创建表格 默认表为为类名,主键为t_default_id
- (void)createTabel{
    if ([[GKDatabaseManager sharedManager] creatTableWithClassName:[Car class]]) {
        NSLog(@"创建Car表格成功");
    }else{
        NSLog(@"已经创建了表格");
    }
}
///插入数据
- (void)insertData: (NSString *)name : (NSString *)direction : (NSString *)guid {
    
    Car * c = [[Car alloc]init];
    c.LName = name;
    c.LDirection = direction;
    c.Guid = guid;
    // 向表格中插入数据
    NSArray *array =  [self singleConditionSearch:guid];
    if ([array count] <= 0 && [[GKDatabaseManager sharedManager] insertDataFromObject:c]) {
        NSLog(@"插入成功");
    };
}
/// 查询表内所有数据
- (NSArray *)selectAllData{
    NSArray * carList = [[GKDatabaseManager sharedManager] selecteDataWithClass:[Car class]];
    NSLog(@"查询表内所有数据:%lu",(unsigned long)[carList count]);
    return carList;
    
}
/// 单条件查询
- (NSArray *)singleConditionSearch:(NSString *)guid{
    NSArray * resultArr = [[GKDatabaseManager sharedManager] selectObject:[Car class] key:@"Guid" operate:@"=" value:guid];
    [resultArr enumerateObjectsUsingBlock:^(Car * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"单条件查询%@",obj.Guid);
    }];
    return resultArr;
}


/// 清空表格
- (void)clearTable{
    if ([[GKDatabaseManager sharedManager] clearTableWithName:[Car class]]) {
        NSLog(@"清空表格成功");
    }
}

/// 指定条件删除
- (void)deleteRow:(NSString *)guid {
    if ([[GKDatabaseManager sharedManager] deleteObject:[Car class] withString:[NSString stringWithFormat:@"Guid = '%@'",guid]]) {
        NSLog(@"删除成功");
    };
}


@end
