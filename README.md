
##JPSlideBar 2.3
----
**类似简书首页、网易云音乐、UC浏览器新闻界面的顶部滚动导航条**

![image](https://github.com/XiFengLang/JPSlideBar/raw/master/JPSlideBar/ExamplerImages/JPSlideBarGif01.gif)
![image](https://github.com/XiFengLang/JPSlideBar/raw/master/JPSlideBar/ExamplerImages/JPSlideBarGif02.gif)
![image](https://github.com/XiFengLang/JPSlideBar/raw/master/JPSlideBar/ExamplerImages/JPSlideBarGif03.gif)
![image](https://github.com/XiFengLang/JPSlideBar/raw/master/JPSlideBar/ExamplerImages/JPSlideBarGif04.gif)

----

###功能介绍
>暂时实现可变滚动条+字体颜色渐变+字体大小渐变效果。

>titles.count <= 5时只能点击SlideBar，并且等宽平铺处理，可以轻松应付切换2-5个内容页的界面。

>Demo里面的例子用了ScrollView/CollectionView添加SubViewController.view的模式，后续会模仿简书首页切换3个内容界面的效果。

>内部通过计算实现监测翻页，外部可以接收NSNotification做一些处理。

###升级简介
V2.3版
>少量修改，为年后大改做准备。

V2.2版
>新增大小渐变

V2.1版
>内部实现KVO以及翻页监测，使用更加灵活。

>解决内存泄露BUG。

>解决滑动过快而不调用scrollViewDidEndDecelerating的BUG。

>解决滑动条滚动到边缘后留有空隙的BUG。

###Usage

先导入JPSlideBar.h
```Object-C
#import "JPSlideBar.h"
```

内部带有强弱转换的宏，不用担心内存泄露。
```Object-C
    self.titleArray = @[@"简书",@"ONE",@"网易云音乐",@"腾讯百度",@"谷歌",@"特斯拉",@"阿里巴巴"];

    self.slideBar = [JPSlideNavigationBar slideBarWithObservableScrollView:self.scrollView
                                                            viewController:self
                                                              frameOriginY:64
                                                       slideBarSliderStyle:JPSlideBarStyleTransformationAndGradientColor];
    
    [self.view addSubview:self.slideBar];
    
    
    Weak(self); //避免循环引用
    [self.slideBar configureSlideBarWithTitles:titles
                                     titleFont:[UIFont systemFontOfSize:18]
                                     itemSpace:30
                           normalTitleRGBColor:JColor_RGB(0,0,0)
                         selectedTitleRGBColor:JColor_RGB(255,255,255)
                                 selectedBlock:^(NSInteger index) {
                                     Strong(self);
                                     CGFloat scrollX = CGRectGetWidth(self.scrollView.bounds) * index;
                                     [self.scrollView setContentOffset:CGPointMake(scrollX, 0)];
                                 }];
```

默认使用磨砂玻璃的效果，如果不需要，设置背景颜色即可
```Object-C
    [self.slideBar setSlideBarBackgroudColorIfNecessary:[UIColor whiteColor]];
```

如果你需要监测每次滚动翻页，进行数据刷新/复用处理，监听翻页的通知就行。
```Object-C
    [JPNotificationCenter addObserver:self selector:@selector(doSomeThingWhenScrollViewChangePage:) name:JPSlideBarChangePageNotification object:nil];
    
- (void)doSomeThingWhenScrollViewChangePage:(NSNotification *)notification{
    CGFloat offsetX = [notification.userInfo[JPSlideBarScrollViewContentOffsetX] floatValue];
    NSInteger index = [notification.userInfo[JPSlideBarCurrentIndex] integerValue];
    
    JKLog(@"offsetX:%f    index:%ld",offsetX,index);
}
```


```Object-C
```

