//
//  ViewController.m
//  ScrollView嵌套悬停Demo
//
//  Created by 谭高丰 on 2017/5/9.
//  Copyright © 2017年 谭高丰. All rights reserved.
//

#import "ViewController.h"
#import "WMPageController.h"
#import "ArtScrollView.h"
#import "ChildTableViewController.h"

BOOL isNowTop = NO;
BOOL isNowBottom = YES;

@interface ViewController ()<UIScrollViewDelegate>
{
    CGFloat _bannerHeight;
}
@property (nonatomic, strong) WMPageController *pageController;
@property (nonatomic, strong) ArtScrollView *containerScrollView;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign) BOOL canScroll;   // 最底部的scrollView是否能滚动的标志
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标题";
    _bannerHeight = 200;
    _canScroll = NO;
    self.automaticallyAdjustsScrollViewInsets = YES;
    // 接收底部视图离开顶端的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kHomeLeaveTopNotification object:nil];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.alpha = 1;
}

- (void)setupView {
    [self.view addSubview:self.containerScrollView];
    self.containerScrollView.backgroundColor = [UIColor redColor];
    [self.containerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 添加上方视图
    [self.containerScrollView addSubview:self.bannerView];
    self.bannerView.backgroundColor = [UIColor greenColor];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.containerScrollView);
        make.height.mas_equalTo(_bannerHeight);
    }];
    
    // 添加底部视图
    [self.containerScrollView addSubview:self.contentView];
//    self.contentView.backgroundColor = [UIColor grayColor];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.containerScrollView);
        make.height.mas_equalTo(kScreenHeight-kStatusBarHeight-kNavigationBarHeight);
        make.left.right.bottom.equalTo(self.containerScrollView);
        make.top.equalTo(self.bannerView.mas_bottom);
    }];
    
    // 添加底部内容视图
    [self.contentView addSubview:self.pageController.view];
    self.pageController.viewFrame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kStatusBarHeight-kNavigationBarHeight);
}

#pragma mark - getter
// 最底层的scrollView
- (ArtScrollView *)containerScrollView {
    if (!_containerScrollView) {
        _containerScrollView = [[ArtScrollView alloc] init];
        _containerScrollView.delegate = self;
        _containerScrollView.bounces = NO;
        _containerScrollView.scrollsToTop = NO;
        _containerScrollView.showsVerticalScrollIndicator = YES;
    }
    return _containerScrollView;
}
// 顶部视图
- (UIView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[UIView alloc] init];
//        _bannerView.backgroundColor = [UIColor blueColor];
    }
    return _bannerView;
}
// 底部视图
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor yellowColor];
    }
    return _contentView;
}
// 底部内容视图
- (WMPageController *)pageController {
    if (!_pageController) {
        // ChildTableViewController子视图
        _pageController = [[WMPageController alloc] initWithViewControllerClasses:@[[ChildTableViewController class],[ChildTableViewController class],[ChildTableViewController class]] andTheirTitles:@[@"tab1",@"tab2",@"tab3"]];
        _pageController.menuViewStyle      = WMMenuViewStyleLine;
        _pageController.menuHeight         = 44;
        _pageController.progressWidth      = 20;
        _pageController.titleSizeNormal    = 15;
        _pageController.titleSizeSelected  = 15;
        _pageController.titleColorNormal   = [UIColor grayColor];
        _pageController.titleColorSelected = [UIColor blueColor];
    }
    return _pageController;
}

#pragma mark - notification

-(void)acceptMsg : (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    } else {
        _canScroll = NO;
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    return;
    CGFloat maxOffsetY = _bannerHeight - kStatusBarHeight - kNavigationBarHeight;
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"偏移量:===%f", offsetY);
//    self.navigationController.navigationBar.alpha = offsetY/136;
    if (offsetY>=maxOffsetY) {
        scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        NSLog(@"滑动到顶端");
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeGoTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
        _canScroll = NO;
    } else {
        NSLog(@"离开顶端");
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeGoTopNotification object:nil userInfo:@{@"canScroll":@"0"}];
        if (_canScroll == NO && isNowTop == YES) {
            NSLog(@"_canScroll:===%d", _canScroll);
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        }
        
        if (isNowBottom == YES && _canScroll == NO) {
            scrollView.contentOffset = CGPointMake(0, -(kStatusBarHeight + kNavigationBarHeight));
        }
    }
    
    if (offsetY <= -(kStatusBarHeight + kNavigationBarHeight)) {
        isNowBottom = YES;
    } else {
        isNowBottom = NO;
    }
    
    if (offsetY>=maxOffsetY) {
        isNowTop = YES;
    } else {
        isNowTop = NO;
    }
}


@end
