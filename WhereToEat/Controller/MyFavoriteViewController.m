//
//  MyFavoriteViewController.m
//  WhereToEat
//
//  Created by 王磊 on 2017/9/19.
//  Copyright © 2017年 WLtech. All rights reserved.
//

#import "MyFavoriteViewController.h"
#import "XLSphereView.h"
#import "DetailViewController.h"
#import "NewViewController.h"
#import "PushMessageListViewController.h"
#import "MyFavoriteView.h"

@interface MyFavoriteViewController ()<BMKPoiSearchDelegate>//GADInterstitialDelegate,
//@property (strong, nonatomic) GADBannerView *bannerView;
@property (nonatomic, strong) UIButton *showADBtn;
//@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic,strong) XLSphereView *sphereView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) MyPopView *popView;
@property (nonatomic, strong) BMKPoiSearch *search;
@property (nonatomic, strong) BMKPoiDetailSearchOption *detailSearch;
@property (nonatomic, strong) UIButton *annBtn;
@property (nonatomic, strong) UIButton *randomBtn;
@property (nonatomic, strong) UIButton *pushMesBtn;

@end

@implementation MyFavoriteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.array = [NSMutableArray array];
    //创建球形标签
    [self createBallView];
    //创建其他子控件
//    [self createSubViews];
    //POI搜索
    self.search = [[BMKPoiSearch alloc]init];
    self.detailSearch = [[BMKPoiDetailSearchOption alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createBallView) name:@"updatePlist" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newPushMessage) name:@"newPushMessage" object:nil];
    
    UIButton *pushMesBtn = [[UIButton alloc]initWithFrame:CGRectMake(WLScreenW-WLScreenW*0.15, 20, WLScreenW*0.15, WLScreenW*0.1)];
    [pushMesBtn setImage:[UIImage imageNamed:@"Button_pushMes"] forState:UIControlStateNormal];
    [pushMesBtn addTarget:self action:@selector(pushMessageList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushMesBtn];
    self.pushMesBtn = pushMesBtn;
    
//    MyPopView *popView = [MyPopView loadMyPopView];
//    popView.frame = CGRectMake(0, self.sphereView.frame.origin.y+self.sphereView.frame.size.height+self.view.frame.size.width*0.05, self.view.bounds.size.width, 150);
//    [self.view addSubview:popView];
//    self.popView = popView;
//    WLWEAKSELF
//    self.popView.detailBlock = ^(NSString *detailURL){
//        WLLog(@"详情");
//        DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
//        detailVC.detailURL = detailURL;
//        UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:detailVC];
//        [weakself presentViewController:navController animated:YES completion:nil];
//    };
    
    MyFavoriteView *favView = [MyFavoriteView loadMyFavoriteView];
    favView.frame = CGRectMake(0, self.view.frame.size.height-WLScreenW*(246/320.0),WLScreenW, WLScreenW*(246/320.0));
    [self.view addSubview:favView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.search.delegate = self;
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.search.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BMKPoiSearchDelegate
/**
 *返回POI详情搜索结果
 *@param searcher 搜索对象
 *@param poiDetailResult 详情搜索结果
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiDetailResult:(BMKPoiSearch*)searcher result:(BMKPoiDetailResult*)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode{
    //    WLLog(@"resultDetail %@",poiDetailResult);
    WLLog(@"error %u",errorCode);
    [self createPopViewWithDetailResult:poiDetailResult];
}

#pragma mark - selector

-(void)createBallView{
    [self.sphereView removeFromSuperview];
    _sphereView = [[XLSphereView alloc] initWithFrame:CGRectMake((WLScreenW-sphereViewW)*0.5, WLScreenW*0.15, sphereViewW, sphereViewH)];
    _sphereView.backgroundColor = [UIColor blueColor];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    //获取所以收藏的店面
    NSArray *keyArray = [KKSharedLocalManager.plistDataDic allKeys];
    UIImage *btnBG = [UIImage imageNamed:@"p1_btn_bg"];
    CGFloat top = 0; // 顶端盖高度
    CGFloat bottom = 0 ; // 底端盖高度
    CGFloat left = 100; // 左端盖宽度
    CGFloat right = 100; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    btnBG = [btnBG resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    //如果已有收藏 显示收藏店面
    if (keyArray.count>0) {
        [self.showADBtn removeFromSuperview];
        for (int i = 0; i < keyArray.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            NSString *name = [keyArray objectAtIndex:i];
            NSString *nameStr = [NSString stringWithFormat:@"%@",name];
            
            
            [btn setTitle:nameStr forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:btnBG forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:24.];
            CGSize textSize = [nameStr sizeWithAttributes:@{ NSFontAttributeName :btn.titleLabel.font}];
            btn.frame = CGRectMake(0, 0, textSize.width+20, textSize.height+15);
            //            [btn sizeToFit];
            btn.layer.cornerRadius = 5;
            btn.clipsToBounds = YES;
            [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [array addObject:btn];
            [_sphereView addSubview:btn];
        }
        self.array = array;
    }
    //如果还没有收藏 显示提示
    else{
        if (self.array.count>0) {
            [self.array removeAllObjects];
        }
        NSArray *hitArray = [NSArray arrayWithObjects:@" 还没有收藏 ",@" 快去添加 ",@" 吧 ! ! ! ",@" 还没有收藏 ",@" 快去添加 ",@" 吧 ! ! ! ",@" 还没有收藏 ",@" 快去添加 ",@" 吧 ! ! ! ",@" 重要的事情说三遍 ",nil];
        for (int i = 0; i < hitArray.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            NSString *hit = [hitArray objectAtIndex:i];
            [btn setTitle:hit forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:btnBG forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:24.];
            CGSize textSize = [hit sizeWithAttributes:@{ NSFontAttributeName :btn.titleLabel.font}];
            btn.frame = CGRectMake(0, 0, textSize.width+10, textSize.height+10);
            //            [btn sizeToFit];
            btn.layer.cornerRadius = 5;
            btn.clipsToBounds = YES;
            [array addObject:btn];
            [_sphereView addSubview:btn];
        }
    }
    [_sphereView setItems:array];
    [self.view addSubview:_sphereView];
}

//点击店面 获取详细信息
- (void)buttonPressed:(UIButton *)btn
{
    [_sphereView timerStop];
    //点击按钮变大
    [UIView animateWithDuration:0.3 animations:^{
        btn.transform = CGAffineTransformMakeScale(2., 2.);
        //点击按钮 通过key 获取uid 请求数据展示
        NSString *uidStr = [KKSharedLocalManager kkValueForKey:btn.titleLabel.text];
        if (self.search.delegate==nil) {
            self.search.delegate = self;
        }
        self.detailSearch.poiUid = uidStr;
        BOOL resultCode = [self.search poiDetailSearch:self.detailSearch];
        if (resultCode) {
            WLLog(@"成功");
        }else{
            WLLog(@"失败");
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            btn.transform = CGAffineTransformMakeScale(1., 1.);
        } completion:^(BOOL finished) {
            [_sphereView timerStart];
        }];
    }];
}

//选出随机结果
-(void)randomBtnClick{
    WLLog(@"随机");
    //    WLLog(@"%@",self.array);
    if (self.array.count>0) {
        int x = arc4random() % self.array.count;
        if (self.array.count>x) {
            UIButton *result = [self.array objectAtIndex:x];
            [self buttonPressed:result];
        }
    }else{
        self.tabBarController.selectedIndex=1;
    }
}
//根据搜索结果 弹出相应popView
-(void)createPopViewWithDetailResult:(BMKPoiDetailResult*)poiDetailResult{
    
//    MyPopView *popView = [MyPopView loadMyPopView];
//    popView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 150);
     self.popView.detailResult = poiDetailResult;
//    popView.bottomView.hidden = NO;
//    [self.view addSubview:popView];
//    self.popView = popView;
//
//    [UIView animateWithDuration:0.5 animations:^{
//        popView.frame = CGRectMake(0, self.view.bounds.size.height-150, self.view.bounds.size.width, 150);
//    }];
    

}

//跳转到推送消息列表
-(void)pushMessageList{
    [_pushMesBtn setImage:[UIImage imageNamed:@"Button_pushMes"] forState:UIControlStateNormal];
    PushMessageListViewController *pushList = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PushMessageListViewController"];
    [self.navigationController pushViewController:pushList animated:YES];
}

-(void)newPushMessage{
    [_pushMesBtn setImage:[UIImage imageNamed:@"Button_pushMes_new"] forState:UIControlStateNormal];
}

@end
