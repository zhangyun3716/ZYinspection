//  recordViewController.m
//  flexiuminspection
//  Created by flexium on 2017/2/28.
//  Copyright © 2017年 FLEXium. All rights reserved.

#import "recordViewController.h"
#import "LoginViewController.h"
#import "informationcell.h"
#import "MJRefresh.h"
@interface recordViewController ()

#define CEll1 @"CELL1"

@property (nonatomic, copy)  NSString *currentElement;

@property (nonatomic,strong) NSString *currentElementName;

@property (nonatomic,assign) BOOL isCheck;

@property (nonatomic,strong) NSString *returnresult;

@property (nonatomic,strong) NSString *userempno;

//添加属性(数据类型xml解析)
@property (nonatomic, strong) NSXMLParser *parser;

//存放我解析出来的数据
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, strong) NSArray *arraylist;
//菊花界面
@property (strong,nonatomic) UIActivityIndicatorView *testview;

@property(nonatomic,strong)  UIView *backview;

@property(nonatomic,strong)  NSArray *typearr;

@property(nonatomic,strong)  NSArray *jiluarray;

- (IBAction)back:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) IBOutlet UIButton *backbtnset;

- (IBAction)dianjisuaxing:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *shuxingbtn;


@end

@implementation recordViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;//上方标题栏
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _userempno = [[NSUserDefaults standardUserDefaults] valueForKey:@"empno"];
    NSLog(@"%@",_userempno);
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.backgroundColor=[UIColor whiteColor];
    //隐藏下方多余的分割线。
    self.tableview.tableFooterView=[[UIView alloc] init];
    //下列方法的作用也是隐藏分割线。
    [self.tableview setSeparatorInset:UIEdgeInsetsZero];
    [self.tableview setLayoutMargins:UIEdgeInsetsZero];
    [self setupRefresh:self.tableview];
    //头部不可选择
    self.tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    self.backbtnset.layer.cornerRadius=10;
    self.backbtnset.layer.masksToBounds=YES;/*隐藏裁剪掉的部分*/
    self.shuxingbtn.layer.cornerRadius=10;
    self.shuxingbtn.layer.masksToBounds=YES;//隐藏裁剪掉的部分
    [self checkjilu];
    

}

-(void)setupRefresh:(UITableView*)tableView{
    if (tableView == self.tableview) {
        tableView.mj_header = [MJRefreshNormalHeader  headerWithRefreshingBlock:^{
            [self shuxing];
        }];
    }
}

-(void)shuxing{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableview.mj_header endRefreshing];
        self.jiluarray=nil;
        [self checkjilu];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(UIButton *)sender {
    self.view.window.rootViewController =[[UINavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
    [self.view.window makeKeyAndVisible];

}

#pragma mark 查询记录（网络请求）
-(void)checkjilu{
    NSString *urlStr = @"http://portal.flexium.com.cn:81/inspect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    
    NSString *dataStr = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?> <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body>  <chckjilu xmlns='http://tempuri.org/'><empno>%@</empno></chckjilu></soap:Body> </soap:Envelope>",_userempno];
   
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/chckjilu" forHTTPHeaderField:@"Action"];
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self intenererror];
        } else {
            self.parser=[[NSXMLParser alloc]initWithData:data];
            NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
            NSLog(@"%@",result);
            //添加代理
            self.parser.delegate=self;
            //self.list = [NSMutableArray arrayWithCapacity:9];
            //这一步不能少！
            self.parser.shouldResolveExternalEntities=true;
            //开始解析
            [self.parser parse];
            
        }
    }];
    // 6.开启请求数据
    [dataTask resume];
}

#pragma mark 遍历查找xml中文件的元素
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    
    _currentElementName = elementName;
    [self endjuhua];
    if ([_currentElementName isEqualToString:@"chckjiluResult"]) {
        
        _isCheck = true;
        _returnresult = @"";
        
    }
   }

#pragma mark 把第一个代理中我们要找的信息存储在currentstring中并把要找的信息空格和换行符号去除
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([_currentElementName isEqualToString:@"chckjiluResult"]) {
        
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.jiluarray= [self.returnresult componentsSeparatedByString:@";"];
        
    }
}

#pragma mark 把上部的信息存储到数据中
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}

#pragma mark 解析结束数据
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
        NSLog(@"%@",self.jiluarray);
        if ([self.jiluarray[0] isEqualToString:@"OK"]) {
            [self.tableview reloadData];
        }else if([self.jiluarray[0] isEqualToString:@"NG"]){
            [self tixing:@"當前時間無巡檢計劃"];
        }else{
            [self tixing:@"異常錯誤，從新操作"];
            }
          });
    
}

#pragma mark 網絡錯誤提示界面
-(void)intenererror{
    [self endjuhua];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"網絡錯誤" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"網絡錯誤"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 4)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
}

#pragma mark 提醒界面的方法
-(void)tixing:(NSString *)str{
    NSUInteger len = [str length];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:str message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:str];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, len)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, len)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
}

#pragma mark 建立并开始菊花界面请求
-(void)beginjuhua{
    
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    testActivityIndicator.center = CGPointMake(100.0f, 100.0f);//只能设置中心，不能设置大小
    [testActivityIndicator setFrame :CGRectMake(100, 200, 100, 100)];//不建议这样设置，因为
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor greenColor]; // 改变圈圈的颜色为红色； iOS5引入
    [testActivityIndicator startAnimating]; // 开始旋转
    self.testview=testActivityIndicator;
    
}

#pragma mark 结束并移除菊花界面
-(void)endjuhua{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_testview stopAnimating]; // 结束旋转
        [_testview removeFromSuperview]; //当旋转结束时移除
    });
    
}
#pragma 下列方法为tableview方法实现

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark 有多少行cell
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.jiluarray.count>0) {
         return (self.jiluarray.count-1)/6;
    }else{
        return 0;
    }
   
}

#pragma mark cell顯示內容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    informationcell *cell1=[tableView dequeueReusableCellWithIdentifier:CEll1];
    if (cell1 ==nil) {
        cell1=[[[NSBundle mainBundle]loadNibNamed:@"informationcell" owner:nil options:nil]objectAtIndex:0];
        cell1.contentView.backgroundColor=[UIColor whiteColor];
        cell1.backgroundColor=[UIColor whiteColor];
    }
    cell1.planname.text=self.jiluarray[indexPath.row*6+2]; ;
    cell1.planname.layer.borderWidth=0.5f;
    cell1.planname.numberOfLines=0;
    
    cell1.planname.layer.borderColor=[[UIColor blackColor] CGColor];
    cell1.placename.text=self.jiluarray[indexPath.row*6+1];
    cell1.placename.numberOfLines=0;
    cell1.placename.layer.borderWidth=0.5f;
    
    cell1.plantime.layer.borderColor=[[UIColor blackColor] CGColor];
    cell1.plantime.text=self.jiluarray[indexPath.row*6+4];
    cell1.plantime.layer.borderWidth=0.5f;
    cell1.plantime.layer.borderColor=[[UIColor blackColor] CGColor];
    cell1.plantime.numberOfLines=0;
    
    cell1.oktimes.text=self.jiluarray[indexPath.row*6+5];
    cell1.oktimes.layer.borderWidth=0.5f;
    cell1.oktimes.numberOfLines=0;
    cell1.oktimes.layer.borderColor=[[UIColor blackColor] CGColor];
    
    cell1.ngtimes.text=self.jiluarray[indexPath.row*6+6];
    cell1.ngtimes.numberOfLines=0;
    cell1.ngtimes.layer.borderWidth=0.5f;
    cell1.ngtimes.layer.borderColor=[[UIColor blackColor] CGColor];
    
    return cell1;
    
}

#pragma mark 分組頭界面
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    UILabel *lable1=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 50)];
    UILabel *lable2=[[UILabel alloc]initWithFrame:CGRectMake(64, 0, 64, 50)];
    UILabel *lable3=[[UILabel alloc]initWithFrame:CGRectMake(128, 0, 64, 50)];
    UILabel *lable4=[[UILabel alloc]initWithFrame:CGRectMake(192, 0, 64, 50)];
    UILabel *lable5=[[UILabel alloc]initWithFrame:CGRectMake(256, 0, 64, 50)];
    [view addSubview:lable1];
    [view addSubview:lable2];
    [view addSubview:lable3];
    [view addSubview:lable4];
    [view addSubview:lable5];
    
    lable1.layer.borderWidth=0.5f;
    lable1.layer.borderColor=[[UIColor blackColor] CGColor];
    lable2.layer.borderWidth=0.5f;
    lable2.layer.borderColor=[[UIColor blackColor] CGColor];
    lable3.layer.borderWidth=0.5f;
    lable3.layer.borderColor=[[UIColor blackColor] CGColor];
    lable4.layer.borderWidth=0.5f;
    lable4.layer.borderColor=[[UIColor blackColor] CGColor];
    lable5.layer.borderWidth=0.5f;
    lable5.layer.borderColor=[[UIColor blackColor] CGColor];
    
    lable1.text=@"巡檢計劃";
    [lable1 setTextAlignment:NSTextAlignmentCenter];
    lable1.textColor=[UIColor blackColor];
    lable2.text=@"計劃地點";
    [lable2 setTextAlignment:NSTextAlignmentCenter];
    lable2.textColor=[UIColor blackColor];
    lable3.text=@"計劃巡檢數";
    [lable3 setTextAlignment:NSTextAlignmentCenter];
    lable3.textColor=[UIColor blackColor];
    lable4.text=@"巡檢OK数";
    [lable4 setTextAlignment:NSTextAlignmentCenter];
    lable4.textColor=[UIColor blackColor];
    lable5.text=@"巡檢NG数";
    [lable5 setTextAlignment:NSTextAlignmentCenter];
    lable5.textColor=[UIColor blackColor];
    
    
    lable1.font=[UIFont systemFontOfSize:12];
    lable2.font=[UIFont systemFontOfSize:12];
    lable3.font=[UIFont systemFontOfSize:12];
    lable4.font=[UIFont systemFontOfSize:12];
    lable5.font=[UIFont systemFontOfSize:12];
    view.backgroundColor=[UIColor whiteColor];
    return view;
}

#pragma mark 返回分組的頭高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 48;
}

- (IBAction)dianjisuaxing:(id)sender {
    
    [self checkjilu];
}

@end
