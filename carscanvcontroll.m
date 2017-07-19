//
//  carscanvcontroll.m
//  flexiuminspection
//
//  Created by flexium on 2017/6/23.
//  Copyright © 2017年 FLEXium. All rights reserved.
//

#import "carscanvcontroll.h"
#import "ZYScannerView.h"
#import "UIImageView+WebCache.h"
@interface carscanvcontroll ()<NSXMLParserDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
//添加属性(数据类型xml解析)
@property (nonatomic, strong) NSXMLParser *parser;

//进出厂开关
- (IBAction)Cargoout:(UIButton *)sender;
//车辆进出
@property (strong, nonatomic) IBOutlet UIButton *Cargoout;
//区域名
@property (strong, nonatomic) IBOutlet UIButton *quyuming;
//进出类型
@property (strong, nonatomic) IBOutlet UIButton *intOrOut;

//开始扫描
- (IBAction)Scanning:(UIButton *)sender;
//工号
@property (strong, nonatomic) IBOutlet UILabel *Jobnumber;
//姓名
@property (weak, nonatomic) IBOutlet UILabel *Name;
//部门
@property (weak, nonatomic) IBOutlet UILabel *Department;
@property (strong, nonatomic) IBOutlet UILabel *Daytype;

//头像
@property (weak, nonatomic) IBOutlet UIImageView *NameImage;
//选择区域
- (IBAction)SelectArea:(UIButton *)sender;
//地区数组
@property (strong,nonatomic) NSArray *AreaArray;
//还是地区名稱
@property (strong, nonatomic) IBOutlet UIButton *selectareadd;

//存放我解析出来的数据
@property (nonatomic, strong) NSArray *list;
//标记当前标签，以索引找到XML文件内容
@property (nonatomic, copy) NSString *currentElement;

@property (nonatomic,strong)NSString *currentElementName;

@property (nonatomic,assign)BOOL isCheck;

@property (nonatomic,strong)NSString *returnresult;

@property (nonatomic,strong)UIView *Areaview;
//进出厂标记
@property (assign ,nonatomic) int A;
@property (assign ,nonatomic) int B;

//pickerView的定义显示
@property (nonatomic,strong) UIView * secondview;
@property (nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic,copy)NSString *arestr;
@end

@implementation carscanvcontroll



-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;//上方标题栏
    //   [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.tabBarController.tabBar.hidden = NO;//隐藏下方标签栏
    [self.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.A=1;
    [self.Cargoout setBackgroundImage:[UIImage imageNamed:@"入库.png"] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
//开始扫描工号
- (IBAction)Scanning:(UIButton *)sender {
    __weak typeof(_Jobnumber) weakLabel = _Jobnumber;
    [[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
        //     NSLog(@"%@",_selectareadd.titleLabel.text);
        __strong typeof(weakLabel) strongLabel = weakLabel;
        strongLabel.text = str;
        NSString * type=@"0";
        if (_A==1) {
            type=@"in";
        }
        if (_B==1) {
            type=@"out";
        }
        NSString *message= [type stringByAppendingFormat:@";%@;%@",str,_quyuming.titleLabel.text];
        [self websever:message];
        
    }];
    //    }
}

//现在进行网络请求
-(void)websever:(NSString *)message{
    NSString *urlStr = @"http://portal.flexium.com.cn:81/APPConnect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    NSString *str1=@"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><APPMethod xmlns='http://tempuri.org/'><message>";
    NSString *str2=@"</message></APPMethod></soap:Body></soap:Envelope>";
    NSString *dataStr = [NSString stringWithFormat:@"%@%@%@",str1,message,str2];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/APPMethod" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求数据出错!----%@",error.description);
        } else {
            self.parser=[[NSXMLParser alloc]initWithData:data];
            NSLog(@"%@",data);
            //添加代理
            self.parser.delegate=self;
            self.list = [NSMutableArray arrayWithCapacity:5];
            //这一步不能少！
            self.parser.shouldResolveExternalEntities=true;
            //开始解析
            [self.parser parse];
            
        }
    }];
    // 6.开启请求数据
    [dataTask resume];
}

//遍历查找xml中文件的元素
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    _currentElementName = elementName;
    if ([_currentElementName isEqualToString:@"APPMethodResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
}

//把第一个代理中我们要找的信息存储在currentstring中并把要找的信息空格和换行符号去除

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([_currentElementName isEqualToString:@"APPMethodResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        NSLog(@"%@",_returnresult);
        self.list= [self.returnresult componentsSeparatedByString:@";"];
    }
}

//把上部的信息存储到数据中
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    __weak typeof(_Name) nameLabel = _Name;
    __weak typeof(_Department) deparmentLabel = _Department;
    __weak typeof(_NameImage) nameimageview = _NameImage;
    __weak typeof(_Daytype) daytype = _Daytype;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.list[0] isEqualToString:@"OK" ]) {
            _selectareadd.titleLabel.text=_arestr;
            nameLabel.text=self.list[2];
            nameLabel.textColor=[UIColor blackColor];
            deparmentLabel.text=self.list[3];
            daytype.text=self.list[4];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *image_name= [self.list[1]stringByAppendingString:@".JPG"];
                NSString *image_str=[NSString stringWithFormat:@"http://hr-server.flexium.com.cn:81/image/%@",image_name];
                
                [nameimageview sd_setImageWithURL:[NSURL URLWithString:image_str]];
                //                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:image_str]];
                //                nameimageview.image=[UIImage imageWithData:data];
                
            });
            
        }else{
            nameLabel.text=self.list[1];
            deparmentLabel.text=@"";
            daytype.text=@"";
            nameLabel.textColor=[UIColor redColor];
            //            NSString *image_name= [UIImage imageNamed:@"空白.png"];//@"http://newportal.flexium.com.cn:81/image/null.JPG";
            //            //http://hr-server.flexium.com.cn:81/image
            //            NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:image_name]];
            nameimageview.image=[UIImage imageNamed:@"空白.png"];//imageWithData:data];
            
        }
        
    });
}
-(NSArray *)AreaArray{
    if (_AreaArray==nil) {
        _AreaArray=[[NSArray alloc]init];
        _AreaArray=@[@"西門區域",@"東門區域",@"城北廠"];
    }
    return _AreaArray;
}


- (IBAction)SelectArea:(UIButton *)sender {
    
    self.secondview =[[UIView alloc]initWithFrame:self.view.frame];
    self.pickerView =[[UIPickerView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 500)];
    self.pickerView.dataSource=self;
    self.pickerView.delegate=self;
    [self.pickerView selectRow:3 inComponent:0 animated:YES];
    [self.secondview addSubview:self.pickerView];
    [self.view addSubview:self.secondview];
    self.secondview.backgroundColor=[UIColor whiteColor];
    UIButton *btn1=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-35, self.view.bounds.size.height-100, 70, 40)];
    //[btn1 setBackgroundColor:[UIColor lightGrayColor]];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"normal1.png"] forState:UIControlStateNormal];
    [btn1 setTitle:@"確認" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn1.layer.cornerRadius=7;//self.imageView.frame.size.width/2+5;//裁成圆角
    btn1.layer.masksToBounds=YES;//隐藏裁剪掉的部分
    [self.secondview addSubview:btn1];
    [btn1 addTarget:self action:@selector(SureChoose) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)SureChoose{
    self.secondview.hidden=YES;
    [self.secondview removeFromSuperview];
}

#pragma mark  看看有多少行
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//控件部分有多少行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.AreaArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0f;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 200;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString  *str=self.AreaArray[row];
    return str;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *mycom1 = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 30.0f)];
    [mycom1 setTextAlignment:NSTextAlignmentCenter];
    mycom1.textColor=[UIColor blackColor];
    NSString *imgstr1 = self.AreaArray[row];
    mycom1.text = imgstr1;
    [mycom1 setFont:[UIFont systemFontOfSize: 18]];
    mycom1.backgroundColor = [UIColor whiteColor];
    return mycom1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_quyuming setTitle:self.AreaArray[row] forState:UIControlStateNormal];
    _arestr=self.AreaArray[row];
}

- (IBAction)Cargoout:(UIButton *)sender {
    sender.selected=!sender.selected;
    if (sender.selected==1) {
        [self.Cargoout setBackgroundImage:[UIImage imageNamed:@"出库.png"] forState:UIControlStateNormal];
        [self.intOrOut setTitle:@"車輛出廠" forState:UIControlStateNormal];
        self.A=0;
        self.B=1;
        NSLog(@"出厂");
    }
    else{
        [self.Cargoout setBackgroundImage:[UIImage imageNamed:@"入库.png"] forState:UIControlStateNormal];
        self.A=1;
        self.B=0;
        [self.intOrOut setTitle:@"車輛進廠" forState:UIControlStateNormal];
        NSLog(@"进厂");
    }
}

@end
