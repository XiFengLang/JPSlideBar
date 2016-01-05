//
//  JPSlideBar.m
//  JPSlideBar
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 XiFengLang. All rights reserved.
//

#import "JPSlideBar.h"
@interface JPSlideBar ()

@property (nonatomic, copy)JPSlideBarSelectedBlock selectedBlock;
// collectionView会复用，采用scrollView+Label+Tap更适合
@property (nonatomic, strong)UIScrollView * scrollView;
// 存放title
@property (nonatomic, strong)NSMutableArray * titleArray;
// 存放label
@property (nonatomic, strong)NSMutableArray * labelArray;
// 存放label.center.x坐标
@property (nonatomic, strong)NSMutableArray * labelCenterXArray;
// 存放Label的宽度
@property (nonatomic, strong)NSMutableArray * sliderWidthArray;
// 存放相邻Label的center.x差值
@property (nonatomic, strong)NSMutableArray * labelCenterDValueArray;
// 存放相邻Label的宽度差值
@property (nonatomic, strong)NSMutableArray * labelWidthDValueArray;

@property (nonatomic, assign)JPSlideBarStyle  slideBarStyle;

@property (nonatomic, strong)UIFont  * font;

@property (nonatomic, strong)UIColor * normalColor;
@property (nonatomic, strong)UIColor * selectedColor;
@property (nonatomic, strong)UILabel * selectedLabel;

//@property (nonatomic, strong)CALayer * sliderLine;    // 容易跳帧，略卡
@property (nonatomic, strong)UIView * sliderLine;
@property (nonatomic, assign)CGFloat sliderFrameY;
@property (nonatomic, assign)CGFloat itemSpace;
@property (nonatomic, assign)CGFloat screenWidth;

//  记录被观察scrollView实时X轴偏移量
@property (nonatomic, assign)CGFloat offestXKVO;
//  被观察scrollView减去上一次减速后的偏移X的差值 与屏宽的比例
//  (offsetX - self.currentOffsetX)/self.screenWidth;
@property (nonatomic, assign)CGFloat scale;
//  被观察scrollView上一次减速后的X轴偏移量
@property (nonatomic, assign)CGFloat currentOffsetX;
//  被观察scrollView上一次减速后的中心X坐标
@property (nonatomic, assign)CGFloat currentCenterX;

//  currentIndex相对selectedIndex而言是全局可改变、可利用的，记录当前的index，两者难以替换
@property (nonatomic, assign)NSInteger currentIndex;
//  selectedIndex是修改颜色后的Index，只在修改颜色的方法中修改，防止主线程重复刷新颜色（尽量只刷新一次）
@property (nonatomic, assign)NSInteger selectedIndex;
@end

@implementation JPSlideBar

+ (instancetype)showInViewController:(UIViewController *)viewController
                        frameOriginY:(CGFloat)frameOriginY
                           itemSpace:(CGFloat)space
                 slideBarSliderStyle:(JPSlideBarStyle)slideBarStyle{
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    JPSlideBar   * slideBar   = [[JPSlideBar  alloc]initWithEffect:blurEffect];
    slideBar.frame = CGRectMake(0, frameOriginY, JPSCREEN_WIDTH, JPSLIDER_HEIGHT);
    
    slideBar.itemSpace    = space > JPSLIDER_ITEM_SPACE ? space : JPSLIDER_ITEM_SPACE;
    slideBar.sliderFrameY = CGRectGetHeight(slideBar.bounds)-2;
    slideBar.screenWidth  = [UIScreen mainScreen].bounds.size.width;
    slideBar.slideBarStyle = slideBarStyle;
    
    [viewController.view  addSubview:slideBar];
    [viewController setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [JPNotificationCenter addObserver:slideBar selector:@selector(jp_scrollViewDidEndDecelerating:) name:JPScrollViewDidEndDeceleratingNotification object:nil];
    return slideBar;
}

- (void)configureSlideBarWithTitles:(NSArray *)titleArray
                          titleFont:(UIFont *)font
                   normalTitleRGBColor:(UIColor *)normalColor
                 selectedTitleRGBColor:(UIColor *)selectedColor
                      selectedBlock:(JPSlideBarSelectedBlock)selectedBlock{
    
    self.titleArray = [titleArray mutableCopy];
    self.normalColor   = normalColor;
    self.selectedColor = selectedColor;
    if (selectedBlock) self.selectedBlock = selectedBlock;
    self.font = font;
    
    [self initializeAndConfigureSlideBarItems];
    
    self.currentIndex = 0;
    self.selectedIndex = 0;
    self.scale = 0;
    self.currentOffsetX = 0;
    self.offestXKVO = 0;
        
    switch (self.slideBarStyle) {
        case JPSlideBarStyleChangeColorOnly:
            break;
            
        case JPSlideBarStyleGradientColorOnly:
            [self.normalColor   jp_decomposeColorObjectIntoRGBValue];
            [self.selectedColor jp_decomposeColorObjectIntoRGBValue];
            break;
            
        case JPSlideBarStyleShowSliderAndChangeColor:
            [self displaySliderLine];
            break;
            
        case JPSlideBarStyleShowSliderAndGradientColor:
            [self.normalColor   jp_decomposeColorObjectIntoRGBValue];
            [self.selectedColor jp_decomposeColorObjectIntoRGBValue];
            [self displaySliderLine];
            break;
            
        default:
            break;
    }
}



- (void)initializeAndConfigureSlideBarItems{
    CGFloat itemsTotalWidth = 0;
    CGFloat width = 0;
    
    for (NSInteger index = 0; index < self.titleArray.count; index++) {
        CGRect rect;
        
        if (self.titleArray.count <= 5) {   // 等宽处理
            width = self.screenWidth/self.titleArray.count;
            rect = CGRectMake(index * width, 0, width, JPSLIDER_HEIGHT);
            itemsTotalWidth += width;
            
        }else{
            width = [self widthOfString:self.titleArray[index]];
            width += self.itemSpace;
            rect = CGRectMake(itemsTotalWidth, 0, width, JPSLIDER_HEIGHT);
            itemsTotalWidth += width;
        }
        [self.sliderWidthArray addObject:@(width)];
        [self.labelCenterXArray addObject:@(itemsTotalWidth - width/2.0)];
        
        UILabel * label = [self initializeLabelItemWithFrame:rect atIndex:index];
        if (index == 0) {
            self.selectedLabel = label;
            self.currentCenterX = itemsTotalWidth - width/2.0;
            label.textColor = self.selectedColor;
            
        }else{
            // 计算相邻Label的width和center.x的偏差
            label.textColor = self.normalColor;
            CGFloat centerDValue = itemsTotalWidth - width/2.0 - [self.labelCenterXArray[index-1] floatValue];
            CGFloat widthDValue  = width - [self.sliderWidthArray[index-1] floatValue];
            
            [self.labelCenterDValueArray addObject:@(centerDValue)];
            [self.labelWidthDValueArray addObject:@(widthDValue)];
        }
        
        [self.scrollView addSubview:label];
        [self.labelArray addObject :label];
    }
    
    
    if (self.titleArray.count <= 5) {
        self.scrollView.contentSize = CGSizeMake(self.screenWidth, JPSLIDER_HEIGHT);
    }else {
        self.scrollView.contentSize = CGSizeMake(itemsTotalWidth, JPSLIDER_HEIGHT);
    }
}

- (void)displaySliderLine{
    self.sliderLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.scrollView.bounds)-2, [[self.sliderWidthArray firstObject]floatValue], 2)];
    self.sliderLine.backgroundColor = self.selectedColor;
    [self.scrollView addSubview:self.sliderLine];
}

- (UILabel *)initializeLabelItemWithFrame:(CGRect)frame atIndex:(NSInteger)index{
    UILabel * label = [[UILabel alloc]initWithFrame:frame];
    label.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0];
    label.text = self.titleArray[index];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = self.font;
    label.tag  = 777+ index;
    
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollViewLabelDidSelected:)];
    [label addGestureRecognizer:tap];
    
    return label;
}

#if 0
- (void)addMaskLayer{   // 头尾添加模糊遮罩，留着以后用
    CAGradientLayer * layer = [CAGradientLayer layer];
    layer.bounds = self.scrollView.bounds;
    layer.anchorPoint = CGPointMake(0.5, 0.5);
    layer.position = self.scrollView.center;
    layer.startPoint = CGPointMake(1, 0);
    
    layer.endPoint = CGPointMake(0, 0);
    layer.colors = @[(__bridge id)[UIColor darkGrayColor].CGColor,(__bridge id)[[UIColor darkGrayColor]colorWithAlphaComponent:0.3].CGColor,(__bridge id)[UIColor clearColor].CGColor];
    layer.locations = @[@(0.9),@(0.95),@(1.0)];
    self.contentView.layer.mask = layer;
}
#endif

#pragma mark - publicMethod
- (void)setSlideBarBackgroudColorIfNecessary:(UIColor *)color{
    self.scrollView.backgroundColor = color;
    for (UILabel * label in self.labelArray) {
        label.backgroundColor = color;
    }
}

- (NSInteger)indexOfSlideBarItemDidSelected{
    return self.selectedIndex;
}

#pragma mark - KVO && NSNotification

//  接收结束减速的通知
- (void)jp_scrollViewDidEndDecelerating:(NSNotification *)notification{
    CGFloat offsetX = [notification.userInfo[JPScrollViewContentOffsetX] floatValue];
    [self scrollViewObservedDidChangePageWithOffsetX:offsetX];
}


- (void)scrollViewObservedDidChangePageWithOffsetX:(CGFloat)offsetX{
    self.currentOffsetX = offsetX;
    self.currentCenterX = [self.labelCenterXArray[self.selectedIndex] floatValue];
    self.currentIndex   = (NSInteger)(offsetX / self.screenWidth);
    [self resetSlideBarContentOffsetWithIndex:self.currentIndex];
}

//  KVO的回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offsetX = [change[@"new"] CGPointValue].x;
        [self updateSlideBarWhenScrollViewDidScrollWithOffsetX:offsetX];
   
    }
}



/** 滑动页面的时候更新整个SliderBar，模拟器上略有卡顿，待优化。
 *
 *  宽度、centerX、宽度差、centerX差值 存放在数组中，避免一直计算
 *
 *  多线程处理不尽人意，暂时未被采用
 */

- (void)updateSlideBarWhenScrollViewDidScrollWithOffsetX:(CGFloat)offsetX{
    @autoreleasepool {
        if (offsetX == self.offestXKVO || offsetX < 0 || offsetX > self.screenWidth * (self.titleArray.count -1)) {
            return;  // scrollView.bounces = YES时生效，或者为NO时到边上了还一直侧滑时生效,
        }
        
        NSInteger destinationIndex = (NSInteger)((self.screenWidth/2.0 + offsetX)/self.screenWidth);
        [self didSelectedSlideBarItemAtIndex:destinationIndex isLabelClicked:NO];
        
        if (self.slideBarStyle == JPSlideBarStyleChangeColorOnly) {
            return;
        }
        
        CGFloat centerSpace = 0;
        CGFloat widthSpace = 0;
        CGFloat scale = (offsetX - self.currentOffsetX)/self.screenWidth;
        if (scale == self.scale) {
            return;   // 点击选中产生的非动态偏移时生效，scrollView.bounces = NO
        }
        
        self.scale = scale;
        NSInteger leftIndex = 0;
        NSInteger rightIndex = 0;
        
        if (scale > 0) {
            leftIndex = self.currentIndex;
            rightIndex = self.currentIndex+1;
            
            if (self.slideBarStyle == JPSlideBarStyleShowSliderAndGradientColor ||
                self.slideBarStyle == JPSlideBarStyleShowSliderAndChangeColor) {
                centerSpace = scale * [self.labelCenterDValueArray[self.currentIndex] floatValue];
                widthSpace  = scale * [self.labelWidthDValueArray[self.currentIndex]  floatValue];
            }
            
        }else if (scale < 0){
            leftIndex = self.currentIndex-1;
            rightIndex = self.currentIndex;
            
            if (self.slideBarStyle == JPSlideBarStyleShowSliderAndGradientColor ||
                self.slideBarStyle == JPSlideBarStyleShowSliderAndChangeColor) {
                centerSpace = scale * [self.labelCenterDValueArray[self.currentIndex-1] floatValue];
                widthSpace  = scale * [self.labelWidthDValueArray[self.currentIndex-1]  floatValue];
            }
        }
        
        if (self.slideBarStyle == JPSlideBarStyleShowSliderAndGradientColor ||
            self.slideBarStyle == JPSlideBarStyleGradientColorOnly) {
            [self displayGradientColorWithLeftIndex:leftIndex andRightIndex:rightIndex scale:scale];
        }
        
        
        if (self.slideBarStyle == JPSlideBarStyleShowSliderAndGradientColor ||
            self.slideBarStyle == JPSlideBarStyleShowSliderAndChangeColor) {
            CGPoint center = self.sliderLine.center;
            center.x = self.currentCenterX + centerSpace;
            self.sliderLine.center = center;
            if (widthSpace != 0) {
                // 已经在最右侧还一直左滑时生效,scrollView.bounces = NO
                self.sliderLine.bounds = CGRectMake(0, 0, [self.sliderWidthArray[self.currentIndex] floatValue] + widthSpace, 2);
            }
        }
    }
}

#pragma mark - LabelDidSelected
- (void)scrollViewLabelDidSelected:(UITapGestureRecognizer *)tapGesture{
    UILabel * label = (UILabel *)tapGesture.view;
    NSInteger index = label.tag - 777;
    [self resetSlideBarContentOffsetWithIndex:index];
    [self didSelectedSlideBarItemAtIndex:index isLabelClicked:YES];
    [self movesliderLineToDestinationIndex:index];
    
    self.currentOffsetX = index * self.screenWidth;
    self.currentIndex   = index;
    self.currentCenterX = [self.labelCenterXArray[index] floatValue];
    
    if (self.selectedBlock) self.selectedBlock(index);
}

//  设置字体颜色
- (void)didSelectedSlideBarItemAtIndex:(NSInteger)index isLabelClicked:(BOOL)isLabelClicked{
    if (self.selectedIndex != index) {
        UILabel * label   = self.labelArray[index];
        
        if (isLabelClicked) {
            self.selectedLabel.textColor = self.normalColor;
            label.textColor   = self.selectedColor;
            
        }else if (self.slideBarStyle != JPSlideBarStyleShowSliderAndGradientColor){
            self.selectedLabel.textColor = self.normalColor;
            label.textColor   = self.selectedColor;
        }
        
        self.selectedLabel = label;
        self.selectedIndex= index;
    }
}

//  颜色渐变
- (void)displayGradientColorWithLeftIndex:(NSInteger)leftIndex andRightIndex:(NSInteger)rightIndex scale:(CGFloat)scale{
    UILabel * leftLabel = self.labelArray[leftIndex];
    UILabel * rightLabel = self.labelArray[rightIndex];
   
    
    
    CGFloat RDValur = self.normalColor.RValue- self.selectedColor.RValue;
    CGFloat GDValur = self.normalColor.GValue- self.selectedColor.GValue;
    CGFloat BDValur = self.normalColor.BValue- self.selectedColor.BValue;
    
    if (scale > 0) {
        leftLabel.textColor =JColor_RGB_Float(self.selectedColor.RValue + scale * RDValur,
                                              self.selectedColor.GValue + scale * GDValur,
                                              self.selectedColor.BValue + scale * BDValur);
        
        rightLabel.textColor = JColor_RGB_Float(self.normalColor.RValue - scale * RDValur,
                                                self.normalColor.GValue - scale * GDValur,
                                                self.normalColor.BValue - scale * BDValur);
        
    }else if (scale < 0){
        leftLabel.textColor =JColor_RGB_Float(self.normalColor.RValue + scale * RDValur,
                                              self.normalColor.GValue + scale * GDValur,
                                              self.normalColor.BValue + scale * BDValur);
        
        rightLabel.textColor = JColor_RGB_Float(self.selectedColor.RValue - scale * RDValur,
                                                self.selectedColor.GValue - scale * GDValur,
                                                self.selectedColor.BValue - scale * BDValur);
    }
    
}


//  滚动条偏移，将选择的Label居中显示
- (void)resetSlideBarContentOffsetWithIndex:(NSInteger)index{
    
    CGFloat offsetX = [self.labelCenterXArray[index] floatValue] - self.screenWidth / 2.0;
    if (offsetX >= 0) {
        
        if (offsetX + self.screenWidth < self.scrollView.contentSize.width) {
            [self.scrollView setContentOffset:CGPointMake([self.labelCenterXArray[index] floatValue] - self.screenWidth / 2.0, 0) animated:YES];
        }else{
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width-self.screenWidth,0) animated:YES];
        }
    }else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

//  选中后slider滑动条偏移
- (void)movesliderLineToDestinationIndex:(NSInteger)index{
    if (self.slideBarStyle != JPSlideBarStyleChangeColorOnly &&
        self.slideBarStyle != JPSlideBarStyleGradientColorOnly) {
        CGRect rect = self.sliderLine.frame;
        rect.origin.x = [self.labelCenterXArray[index] floatValue]-[self.sliderWidthArray[index] floatValue]/2.0;
        rect.size.width = [self.sliderWidthArray[index] floatValue];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.sliderLine.frame = rect;
        } completion:nil];
        
    }
}

#pragma mark - ToolMethod

//  计算字符串宽度
- (CGFloat)widthOfString:(NSString *)string{
    NSDictionary *attributes = @{NSFontAttributeName : self.font};
    CGSize maxSize = CGSizeMake(MAXFLOAT, JPSLIDER_HEIGHT);
    CGSize size = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size.width;
}


#pragma mark - lazyLoad

- (NSMutableArray *)sliderWidthArray{
    if (!_sliderWidthArray) {
        _sliderWidthArray = [[NSMutableArray alloc]init];
    }return _sliderWidthArray;
}

- (NSMutableArray *)titleArray{
    if (!_titleArray) {
        _titleArray = [[NSMutableArray alloc]init];
    }return _titleArray;
}

- (NSMutableArray *)labelCenterXArray{
    if (!_labelCenterXArray) {
        _labelCenterXArray = [[NSMutableArray alloc]init];
    }return _labelCenterXArray;
}

- (UIFont *)font{
    if (!_font) {
        _font = JPSLIDER_FONT;
    }return _font;
}

- (UIColor *)normalColor{
    if (!_normalColor) {
        _normalColor = JCWHITE_COLOR;
        _selectedColor = JCYELLOW_COLOR;
    }return _normalColor;
}

- (NSMutableArray *)labelArray{
    if (!_labelArray) {
        _labelArray = [[NSMutableArray alloc]init];
    }return _labelArray;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, JPSCREEN_WIDTH, JPSLIDER_HEIGHT)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator  = NO;
        _scrollView.bounces  = YES;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0];
        [self.contentView addSubview:_scrollView];
    }return _scrollView;
}


- (NSMutableArray *)labelWidthDValueArray{
    if (!_labelWidthDValueArray) {
        _labelWidthDValueArray = [[NSMutableArray alloc]init];
    }return _labelWidthDValueArray;
}

- (NSMutableArray *)labelCenterDValueArray{
    if (!_labelCenterDValueArray) {
        _labelCenterDValueArray =[[NSMutableArray alloc]init];
    }return _labelCenterDValueArray;
}

- (void)dealloc{
    [self.sliderLine removeFromSuperview];
    [JPNotificationCenter removeObserver:self];
     JKLog(@"%@被释放",[self class]);
}

@end
