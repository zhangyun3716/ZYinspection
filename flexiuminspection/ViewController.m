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

#import "ViewController.h"
#import "ZYScannerView.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()<UIImagePickerControllerDelegate>
- (IBAction)Inspectionplan:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *plan;

- (IBAction)beginscan:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UILabel *inspectionplace;
@property (strong, nonatomic) IBOutlet UILabel *startime;
@property (strong, nonatomic) IBOutlet UILabel *endtime;
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *plantnametable;

//菊花界面
@property (strong,nonatomic)UIActivityIndicatorView *testview;
@property(nonatomic,strong)UIView *backview;
@property(nonatomic,strong) NSArray *typearr;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *inspectplantarray;
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
@property (nonatomic,strong)NSMutableArray*plantidarry;
@property (nonatomic,strong)NSMutableArray*plantnamearry;
@property (nonatomic,strong)NSMutableArray*plantstartdatearry;
@property (nonatomic,strong)NSMutableArray*plantenddatearry;

//用户卡号
@property (nonatomic,strong)NSString *userempno;
//计划ID int
@property (nonatomic,assign)int plantid;
//用户照片image1
@property (nonatomic,strong)NSString *image1;
//用户照片image2
@property (nonatomic,strong)NSString *image2;
//地区二维码
@property (nonatomic,strong)NSString *QRCODE;
//备注
@property (nonatomic,strong)NSString *beizhu;
//类型正常或异常
@property (nonatomic,strong)NSString *typess;
//用户名
@property (nonatomic,strong)NSString *username;
//问题ID
@property (nonatomic,assign)int  wentiid;

//问题idarray
@property (nonatomic,strong)NSMutableArray *wentiidarray;
//问题名称
@property (nonatomic,strong)NSMutableArray *wentiarray;
//问题总数组
@property(nonatomic,strong)NSArray *zhongwentiarray;
//第几次拍照；0为第一次拍照1为第二次拍照
@property (nonatomic,assign)int paizhaotimes;
//请求哪个数据
@property (nonatomic,assign) int qingqiutype;

@property (nonatomic,strong)NSArray *charufanhuoarray;

@property (strong, nonatomic) IBOutlet UIView *xianshibackview;

@property (nonatomic,strong)NSArray *jianchadiquarray;
@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated{
  self.navigationController.navigationBarHidden=YES;//上方标题栏
//   [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.tabBarController.tabBar.hidden = NO;//隐藏下方标签栏
    [self.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
    
}
- (void)viewDidLoad {
      [super viewDidLoad];
//    NSDate *  senddate=[NSDate date];
//    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//     NSString * locationString=[dateformatter stringFromDate:senddate];
//    NSLog(@"%@",locationString);
    self.xianshibackview.hidden=YES;
     _paizhaotimes=0;
     _userempno = [[NSUserDefaults standardUserDefaults] valueForKey:@"empno"];
     _username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSLog(@"%@,%@",_userempno,_username);
       [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(passInPut:) name:@"PassValueWithNotification" object:nil ];//设置观察者
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 168, self.view.bounds.size.width-10, self.view.bounds.size.height-214)];
    // _tableView.backgroundColor=[UIColor blackColor];
    self.tableView.bounces=NO;
    self.tableView.hidden=YES;
    [self.view addSubview:_tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc] init];
    //下列方法的作用也是隐藏分割线。
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    
}
#pragma mark 隐藏状态栏
//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
#pragma mark 巡檢計劃選擇隱藏或顯示的方法
- (IBAction)Inspectionplan:(UIButton *)sender {
    [self.backview removeFromSuperview];
    [self qingkongshuju];
    //请求计划为0
    _qingqiutype=0;
    sender.selected=!sender.selected;
    if (sender.selected==1) {
        self.tableView.hidden=NO;
        self.xianshibackview.hidden=NO;
        [self searchplant:_userempno];

    }else{
        self.tableView.hidden=YES;
    }
}

#pragma mark 開始掃描
- (IBAction)beginscan:(UIButton *)sender {
   
    if([self.plantnametable.text isEqualToString:@"選擇巡檢計劃"]){
            [self tixing:@"請先選擇巡檢計劃再掃描位置二維碼"];
        }
    else{
        [[NSUserDefaults standardUserDefaults] setValue:@"掃描位置二維碼" forKey: @"textlable"];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"textlable"]);
        [self qingkongshuju];
        _paizhaotimes=0;
        self.tabBarController.tabBar.hidden = YES;//隐藏下方标签栏
        
        [[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
            //里面写实现的方法。可以实现的功能
            // NSLog(@"str");
            _QRCODE=str;
            [self checkempnoandjihua:1];
            
        }];
    }
   
}
//#pragma mark 计划完成的操作
//-(void)nextmenu:(UIButton *)sender{
//    [self.backview removeFromSuperview];
//    self.plan.selected=0;
//}
//#pragma mark 计划完成的操作
//-(void)typesnextmenu:(UIButton *)sender{
//    [self.backview removeFromSuperview];
//    self.plan.selected=0;
//}
#pragma mark - 照片选择代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (_paizhaotimes==0) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        self.imageview.image = image;
        
        [picker dismissViewControllerAnimated:NO completion:nil];
     
        
        UIImage *originImage = self.imageview.image;
        
        originImage=[self imageWithImage:originImage scaledToSize:CGSizeMake( 320.2,426.667)];
        originImage=[self watermarkImage:originImage withName:@"2017-03-33 09:20:21"];
        
        NSData *data = UIImageJPEGRepresentation(originImage, 1.10f);
        
        NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        _image1=encodedImageStr;
           [self tanchukuang];
        
    }else{
    //第二次拍照的话就来这
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [picker dismissViewControllerAnimated:NO completion:nil];
        
        UIImage *originImage = image;
        
        originImage=[self imageWithImage:originImage scaledToSize:CGSizeMake( 320.2,426.667)];
        originImage=[self watermarkImage:originImage withName:@"2017-03-33 09:20:21"];
        
        NSData *data = UIImageJPEGRepresentation(originImage, 1.10f);
        
        NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        _image2=encodedImageStr;
        NSLog(@"打印異常");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"異常類型" message:@"填寫異常備註和選擇異常類型" preferredStyle:UIAlertControllerStyleAlert];
        
        //        NSArray *array=@[@"進水了",@"地面髒",@"合格票",@"話了",@"沒別的了"];
        if(_wentiarray.count>0){
            for(int i=0;i<_wentiarray.count;i++){
                [alertController addAction:[UIAlertAction actionWithTitle:_wentiarray[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"点击了：%@",_wentiarray[i]);
                    NSLog(@"備註了：%@",alertController.textFields[0].text);
                    
                    _beizhu=alertController.textFields[0].text;
                    
                    _wentiid=[_wentiidarray[i] intValue];
                    
                    [self scandidianwebserver:_image2];
                    
                }]];
            }
        }else{
            [alertController addAction:[UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _beizhu=alertController.textFields[0].text;
                _wentiid=-1;
                [self scandidianwebserver:_image2];
                
            }]];
        }
       
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.frame=CGRectMake(0, 0, 200, 80);
            textField.placeholder=@"異常類型備註";
            
        }];
        
        // 由于它是一个控制器 直接modal出来就好了
        
        [self presentViewController:alertController animated:YES completion:nil];


    }
    
 }
#pragma mark 图片压缩
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
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

#pragma mark 提醒界面
-(void)tixingjiemian:(NSString* )name{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:name message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:name];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 4)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
    
}
#pragma mark 處理點擊屏幕空白地方消失鍵盤并將按鈕屬性復位
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.plan.selected=0;
    self.tableView.hidden=YES;
    [self.backview removeFromSuperview];
    for(UIView *view in [self.view subviews])
    {
        if (view==self.backview) {
            [view removeFromSuperview];
        }
    }
}
#pragma mark 傳值
-(void)passInPut:(NSNotification *)notifacation{
    self.tabBarController.tabBar.hidden = NO;//隐藏下方标签栏
}
#pragma mark 彈出顯示正常異常的方法
-(void)tanchukuang{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"巡檢異常"message:@""preferredStyle:UIAlertControllerStyleAlert ];
    UIAlertAction *home1Action = [UIAlertAction actionWithTitle:@"正常" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"打印正常");
//        self.paizhaotimes=2;
         _wentiid=1;
         self.qingqiutype=2;
         self.typess=@"1";
        [self scandidianwebserver:_image1];
//        [self tixingjiemian:@"上传成功"];
        
    }];;
    [alertController addAction:home1Action];
    UIAlertAction *home2Action = [UIAlertAction actionWithTitle:@"異常" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.qingqiutype=2;
        _paizhaotimes=1;
        _typess=@"2";
        UIImagePickerController *pick = [[UIImagePickerController alloc]init];
        pick.sourceType = UIImagePickerControllerSourceTypeCamera;
        pick.delegate = self;
        //必须是用present方法模态推出
        [self presentViewController:pick animated:YES completion:nil];
        
       
        
        
    }];
    
    [alertController addAction:home2Action];
    
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"巡檢異常"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 4)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    [home2Action setValue:[UIColor redColor] forKey:@"titleTextColor"];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 返回分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
#pragma mark 返回表视图的分组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.plantnamearry.count;
}
#pragma mark tableviewcell的显示样式等东西
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    static NSString *cellIdentifier =@"cell_id";
    //重用机制有关系
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        //样式
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell.accessoryType =UITableViewCellAccessoryDetailDisclosureButton;//有箭头和感叹号
    }
   cell.textLabel.text= self.plantnamearry[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:21];
//    NSLog(@"%@",self.searchResult[indexPath.row]);
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}
# pragma mark 查找所有计划
-(void)searchplant:(NSString *)message{
    [self beginjuhua];
    NSString *urlStr = @"http://portal.flexium.com.cn:81/inspect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    
    NSString *dataStr = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'> <soap:Body><checkempno xmlns='http://tempuri.org/'> <message>%@</message></checkempno>  </soap:Body> </soap:Envelope>",message];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/checkempno" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
//            NSLog(@"请求数据出错!----%@",error.description);
            [self intenererror];
        } else {
            self.parser=[[NSXMLParser alloc]initWithData:data];
//            NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",result);
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
#pragma mark 最后的上传数据（扫描完地区二维码）上传数据和检查数据
-(void)scandidianwebserver:(NSString *)message{
    [self beginjuhua];
    //http://portal.flexium.com.cn:81/
    NSString *urlStr = @"http://portal.flexium.com.cn:81/inspect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    
    NSString *dataStr = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?> <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'> <soap:Body><checkplace xmlns='http://tempuri.org/'><plantid>%d</plantid>  <image1>%@</image1><image2>%@</image2><diquma>%@</diquma> <beizhu>%@</beizhu><type>%@</type><name>%@</name><empno>%@</empno><wentiid>%d</wentiid></checkplace></soap:Body></soap:Envelope>",_plantid,_image1,_image2,_QRCODE,_beizhu,_typess,_username,_userempno,_wentiid];
    NSLog(@"%d,%@,%@,%@,%@,%@,%d",_plantid,_QRCODE,_beizhu,_typess,_username,_userempno,_wentiid);
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/checkplace" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
//            NSLog(@"请求数据出错!----%@",error.description);
            [self endjuhua];
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
    if ([_currentElementName isEqualToString:@"checkempnoResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
    if ([_currentElementName isEqualToString:@"wentitypeResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
    if ([_currentElementName isEqualToString:@"checkplaceResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
    if ([_currentElementName isEqualToString:@"checkdiquResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
}

#pragma mark 把第一个代理中我们要找的信息存储在currentstring中并把要找的信息空格和换行符号去除
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([_currentElementName isEqualToString:@"checkempnoResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.inspectplantarray= [self.returnresult componentsSeparatedByString:@";"];
    }
    if ([_currentElementName isEqualToString:@"wentitypeResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.zhongwentiarray= [self.returnresult componentsSeparatedByString:@";"];
    }
    if ([_currentElementName isEqualToString:@"checkplaceResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.charufanhuoarray= [self.returnresult componentsSeparatedByString:@";"];
    }
    if ([_currentElementName isEqualToString:@"checkdiquResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.jianchadiquarray= [self.returnresult componentsSeparatedByString:@";"];
    }
}

#pragma mark 把上部的信息存储到数据中
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}
#pragma mark 解析结束数据
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
dispatch_async(dispatch_get_main_queue(), ^{
    [self endjuhua];
    if (_qingqiutype==0) {
            
            if ([self.inspectplantarray[0] isEqualToString:@"OK"]) {
                
                //解析数据
                [self huoqushuju];
                
            }else{
                
                [self tixing:@"今日無巡檢計劃"];
                
            }
    }else if(_qingqiutype==1){
        if ([self.zhongwentiarray[0] isEqualToString:@"OK"]) {
            //解析数据
            [self jiexishuju];
            
        }else{
            _wentiarray =[[NSMutableArray alloc]init];
            _wentiidarray=[[NSMutableArray alloc]init];
            [self tixing:@"未維護異常類型"];
            
        }
    
    }
    else if(_qingqiutype==2){
        if ([self.charufanhuoarray[0] isEqualToString:@"OK"]) {
            //解析数据
            NSLog(@"%@",self.charufanhuoarray);
             [self tixing:@"巡检成功"];
            self.inspectionplace.text=self.charufanhuoarray[4];
            self.startime.text=self.charufanhuoarray[2];
            self.endtime.text=self.charufanhuoarray[3];
        }
        else if([self.charufanhuoarray[0] isEqualToString:@"NG"]){
            NSLog(@"%@",self.charufanhuoarray);
            [self tixing:self.charufanhuoarray[1]];
            self.inspectionplace.text=@"无资料";
            self.startime.text=@"无资料";
            self.endtime.text=@"无资料";
        }
        else{
            
            NSLog(@"%@",self.charufanhuoarray);
             [self tixing:@"巡检失败"];
            self.inspectionplace.text=@"无资料";
            self.startime.text=@"无资料";
            self.endtime.text=@"无资料";

            
        }

        
    }
    else if(_qingqiutype==3){
        //检查地区码
        if ([self.jianchadiquarray[0] isEqualToString:@"OK"]) {
                    self.tabBarController.tabBar.hidden = NO;//隐藏下方标签栏
                    UIImagePickerController *pick = [[UIImagePickerController alloc]init];
                    pick.sourceType = UIImagePickerControllerSourceTypeCamera;
                    pick.delegate = self;
                    //必须是用present方法模态推出
                    [self presentViewController:pick animated:YES completion:nil];
            
        }else{
             self.tabBarController.tabBar.hidden = NO;
            [self tixing:[NSString stringWithFormat:@"计划未维护该地点，请维护系統后或重新選擇巡檢計劃后操作:%@",_QRCODE]];
        
        }
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
    //    [self action];
}
#pragma mark 提醒界面的方法
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

#pragma mark 获取地区和地点的数据
-(void)huoqushuju{
      if (_inspectplantarray.count>2) {
        _plantidarry =[[NSMutableArray alloc]init];
        _plantnamearry=[[NSMutableArray alloc]init];
       _plantstartdatearry=[[NSMutableArray alloc]init];
       _plantenddatearry=[[NSMutableArray alloc]init];
//          NSLog(@"%lu",(unsigned long)_inspectplantarray.count);
        for (int i=1; i<=_inspectplantarray.count-1; i++) {
            int a=i%9;
            if (a==1) {
                [_plantidarry addObject:_inspectplantarray[i]];
            }else if(a==2){
                [_plantnamearry addObject:_inspectplantarray[i]];
            }else if(a==3){
                [_plantstartdatearry addObject:_inspectplantarray[i]];
            }else if(a==4){
                [_plantenddatearry addObject:_inspectplantarray[i]];
            }
        }
        [self.tableView reloadData];

    }
  
}
#pragma mark 解析問題的方法和id
-(void)jiexishuju{
    if (_zhongwentiarray.count>2) {
        _wentiarray =[[NSMutableArray alloc]init];
        _wentiidarray=[[NSMutableArray alloc]init];
        for (int i=1; i<=_zhongwentiarray.count-1; i++) {
            int a=i%3;
            if (a==0) {
                [_wentiarray addObject:_zhongwentiarray[i]];
            }else if(a==1){
                [_wentiidarray addObject:_zhongwentiarray[i]];
            }
        }
    }
    
}
#pragma mark 点击選擇計劃出现的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //请求问题类型为1
    _qingqiutype=1;
//    NSLog(@"%@",self.plantidarry[indexPath.row]);
    _plantid=[self.plantidarry[indexPath.row] intValue];
    NSLog(@"%d",_plantid);
    self.plantnametable.text=self.plantnamearry[indexPath.row];
    self.tableView.hidden=YES;
    self.plan.selected=0;
    //去访问问题稽核id错误类型有哪些
    [self findwentitype:_plantid];
}
#pragma mark 选择完巡检计划根据id去请求对应问题的id和问题名字
#pragma mark 查找问题类型和id
-(void)findwentitype:(int )message{
    [self beginjuhua];
    NSString *urlStr = @"http://portal.flexium.com.cn:81/inspect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    
    NSString *dataStr = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?> <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'> <soap:Body><wentitype xmlns='http://tempuri.org/'> <message>%d</message> </wentitype> </soap:Body></soap:Envelope>",message];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/wentitype" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            //            NSLog(@"请求数据出错!----%@",error.description);
            [self endjuhua];
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
#pragma mark 服务器检查计划和地点是否有对应的
-(void)checkempnoandjihua:(int )message{
    [self beginjuhua];
    _qingqiutype=3;
    NSString *urlStr = @"http://portal.flexium.com.cn:81/inspect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    
    NSString *dataStr = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>  <soap:Body>     <checkdiqu xmlns='http://tempuri.org/'><plantid>%d</plantid>  <diquma>%@</diquma></checkdiqu></soap:Body></soap:Envelope>",_plantid,_QRCODE];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/checkdiqu" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            //            NSLog(@"请求数据出错!----%@",error.description);
            [self endjuhua];
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
#pragma mark 清空數據的方法
-(void)qingkongshuju{
    self.inspectionplace.text=nil;
    self.startime.text=nil;
    self.endtime.text=nil;
    self.imageview.image=nil;
}
#pragma mark 图片的水印
-(UIImage *)watermarkImage:(UIImage *)img withName:(NSString *)name

{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString * locationString=[dateformatter stringFromDate:senddate];
    NSString* mark = name;
    mark=locationString;
    NSLog(@"%@",mark);
    int w = img.size.width;
    
    int h = img.size.height;
    
    UIGraphicsBeginImageContext(img.size);
    
    [img drawInRect:CGRectMake(0,0 , w, h)];
    
    NSDictionary *attr = @{
                    NSFontAttributeName: [UIFont boldSystemFontOfSize:14],  //设置字体
                           
                    NSForegroundColorAttributeName : [UIColor redColor]   //设置字体颜色
                           };
    
    [mark drawInRect:CGRectMake(w -160, 10, 160, 30) withAttributes:attr];      //右上角
    
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return aimg;
    
}
@end
