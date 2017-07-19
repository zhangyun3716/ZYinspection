//  Created by flexium on 2016/11/10.
//  Copyright © 2016年 FLEXium. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "ZYScannerView.h"
#import "ViewController.h"
#import "recordViewController.h"
#import "carscanvcontroll.h"
@interface LoginViewController ()<NSXMLParserDelegate>

- (IBAction)beginscan:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *scanbtn;

@property (strong, nonatomic) NSString *usertype;
//标记当前标签，以索引找到XML文件内容
@property (nonatomic, copy) NSString *currentElement;

@property (nonatomic,strong)NSString *currentElementName;

@property (nonatomic,assign)BOOL isCheck;

@property (nonatomic,strong)NSString *returnresult;

//添加属性(数据类型xml解析)
@property (nonatomic, strong) NSXMLParser *parser;

//存放我解析出来的数据
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, strong) NSArray *arraylist;

//菊花界面
@property (strong,nonatomic)UIActivityIndicatorView *testview;

@property (strong,nonatomic)NSString *userempno;

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;//上方标题栏
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];


}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.scanbtn.layer.cornerRadius=8;//裁成圆角
    self.scanbtn.layer.masksToBounds=YES;//隐藏裁剪掉的部分
  
}

#pragma mark 隐藏状态栏
//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}
#pragma mark 开始扫描
- (IBAction)beginscan:(UIButton *)sender {
       [[NSUserDefaults standardUserDefaults] setValue:@"掃描工卡" forKey: @"textlable"];
 
    [[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
        _userempno=str;
        NSString *message=str;
        [self scanordes:message];
        
    }];
    
}
#pragma mark 掃描物流員
-(void)scanordes:(NSString *)message{
    [self beginjuhua];
    NSString *urlStr = @"http://portal.flexium.com.cn:81/OrderNoCheckPreservationEmpno.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    
    NSString *dataStr = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body> <yuangongempno xmlns='http://tempuri.org/'><message>%@</message> </yuangongempno></soap:Body></soap:Envelope>",message];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/yuangongempno" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求数据出错!----%@",error.description);
            [self intenererror];
            [self endjuhua];
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
    if ([_currentElementName isEqualToString:@"yuangongempnoResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
    
    
}

#pragma mark 把第一个代理中我们要找的信息存储在currentstring中并把要找的信息空格和换行符号去除
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([_currentElementName isEqualToString:@"yuangongempnoResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.list= [self.returnresult componentsSeparatedByString:@";"];
    }
       
}

#pragma mark 把上部的信息存储到数据中
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}
#pragma mark 解析结束数据
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endjuhua];
        NSLog(@"%@",self.list);
        if ([self.list[0] isEqualToString:@"OK"]) {
            [[NSUserDefaults standardUserDefaults] setValue:_userempno forKey: @"empno"];
             [[NSUserDefaults standardUserDefaults] setValue:self.list[2] forKey: @"username"];
           [self goindex];
        }else{
            [self tixing:self.list[1]];
        }
        
    });
    
}

-(void)goindex{
    UIStoryboard *sb =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *mevc=[sb instantiateInitialViewController];
    mevc.title=@"巡检";
    UINavigationController *cnc=[[UINavigationController alloc]initWithRootViewController:mevc];
    cnc.tabBarItem.image = [UIImage imageNamed:@"xunjian"];
    cnc.tabBarItem.selectedImage = [UIImage imageNamed:@"xunjian_height"];
    
    recordViewController *svc=[[recordViewController alloc]init];
    svc.title=@"记录";
    UINavigationController *snc=[[UINavigationController alloc]initWithRootViewController:svc];
    snc.tabBarItem.image = [UIImage imageNamed:@"jilu"];
    snc.tabBarItem.selectedImage = [UIImage imageNamed:@"jilu_height"];
   
    
//    carscanvcontroll *cvc=[[carscanvcontroll alloc]init];
//    cvc.title=@"车辆";
//    UINavigationController *cnsc=[[UINavigationController alloc]initWithRootViewController:cvc];
//    cnsc.tabBarItem.image = [UIImage imageNamed:@"car1"];
//    cnsc.tabBarItem.selectedImage = [UIImage imageNamed:@"car2"];

    
    
    //添加到界面
    UITabBarController *tbc=[[UITabBarController alloc]init];
    [[UITabBar appearance]setTintColor:[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1]];
    //这个地方可以隐藏上面的状态栏
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateDisabled ];
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]} forState:UIControlStateHighlighted ];
    
//    tbc.viewControllers =@[cnc,cnsc,snc];
    tbc.viewControllers =@[cnc,snc];
    tbc.selectedIndex=0;
    [self.navigationController pushViewController:tbc animated:YES];
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
    //    [self action];
}
-(void)tixing:(NSString *)str{
    NSUInteger len = [str length];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:str message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:str];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, len)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, len)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];

}

#pragma mark 建立并开始菊花界面请求
-(void)beginjuhua{
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];//UIActivityIndicatorViewStyleWhite];
    //testActivityIndicator.backgroundColor=[UIColor whiteColor];
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

@end
