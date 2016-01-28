//
//  JPSlideBar.h
//  JPSlideBar
//
//  Created by apple on 16/1/28.
//  Copyright © 2016年 XiFengLang. All rights reserved.
//

#ifndef JPSlideBar_h
#define JPSlideBar_h

#import "JPSlideNavigationBar.h"
#import "UIColor+JPExtension.h"

#define JColor_RGB_Float(R,G,B)   ([UIColor colorWithRed:(R) green:(G) blue:(B) alpha:1])
#define JColor_RGB(R,G,B)         ([UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0])


#define JPSlider_Item_Space 20.0
#define JPSlider_Height     42.0
#define JPScreen_Width      [UIScreen mainScreen].bounds.size.width
#define JPScreen_Height     [UIScreen mainScreen].bounds.size.height
#define JPSlider_Font       [UIFont systemFontOfSize:18]


#define JPNotificationCenter                    [NSNotificationCenter defaultCenter]
#define JPScrollViewDidChangePageNotification   @"didChangePageNotification"
#define JPScrollViewContentOffsetX              @"contentOffsetX"
#define JPSlideBarCurrentIndex                  @"currentIndex"


#ifdef  DEBUG
#define JKLog(...) NSLog(__VA_ARGS__)
#else
#define JKLog(...)
#endif


// 转弱转换的宏，主要用于Self强弱转换，不支持点语法
#ifndef    Weak
#if __has_feature(objc_arc)
#define Weak(object) __weak __typeof__(object) weak##object = object;
#else
#define Weak(object) autoreleasepool{} __block __typeof__(object) block##object = object;
#endif
#endif
#ifndef    Strong
#if __has_feature(objc_arc)
#define Strong(object) __typeof__(object) object = weak##object;
#else
#define Strong(object) try{} @finally{} __typeof__(object) object = block##object;
#endif
#endif


#endif /* JPSlideBar_h */
