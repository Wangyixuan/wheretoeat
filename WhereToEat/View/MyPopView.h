//
//  MyPopView.h
//  Where to eat
//
//  Created by 王磊 on 16/4/12.
//  Copyright © 2016年 WLtech. All rights reserved.
// 用于展示店面基本信息

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>


@interface MyPopView : UIView

//详细结果数据
@property (nonatomic, strong) BMKPoiDetailResult *detailResult;
//跳转详情页面
@property (nonatomic, copy) void(^detailBlock)(NSString *detailURL);
//导航
@property (nonatomic, copy) void(^poisionBlock)(CLLocationCoordinate2D coord,NSString *name);
//上传收藏
@property (nonatomic, copy) void (^uploadBlock)(BMKPoiDetailResult *detailResult);

+(instancetype)loadMyPopView;
@end
