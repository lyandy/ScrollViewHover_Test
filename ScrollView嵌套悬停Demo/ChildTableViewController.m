//
//  ChildTableViewController.m
//  ScrollView嵌套悬停Demo
//
//  Created by 谭高丰 on 2017/5/9.
//  Copyright © 2017年 谭高丰. All rights reserved.
//

#import "ChildTableViewController.h"

extern BOOL isNowTop;
extern BOOL isNowBottom;

@interface ChildTableViewController ()<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation ChildTableViewController
{
    CGFloat _lastOffsetY;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _canScroll = self.tableView.contentOffset.y != 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.directionalLockEnabled = YES;
//    self.tableView.exclusiveTouch = YES;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
//    self.tableView.bounces = NO;
    // add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kHomeGoTopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kHomeLeaveTopNotification object:nil];//其中一个TAB离开顶部的时候，如果其他几个偏移量不为0的时候，要把他们都置为0
}

#pragma mark - notification

-(void)acceptMsg:(NSNotification *)notification {
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:kHomeGoTopNotification]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;   // 如果滑动到了顶部TableView就能滑动了
            self.tableView.showsVerticalScrollIndicator = YES;
        } else {
            self.canScroll = NO;
        }
    }else if([notificationName isEqualToString:kHomeLeaveTopNotification]){
        _lastOffsetY = self.tableView.contentOffset.y;
        self.canScroll = NO;    // 如果没有滑动到了顶部TableView就不能滑动了
        self.tableView.showsVerticalScrollIndicator = NO;
    }
}

- (void)setCanScroll:(BOOL)canScroll
{
    _canScroll = canScroll;
}

int _lastPosition; //A variable define in headfile
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (self.canScroll == NO) {
//        if (_lastOffsetY <= 0) _lastOffsetY = 0;
        scrollView.contentOffset = CGPointMake(0, 0);
    } 
    
    CGFloat offsetY = scrollView.contentOffset.y;
    _lastOffsetY = offsetY;
    NSLog(@"TableView的偏移量：%f", offsetY);
    if (offsetY < 0) {
        _lastOffsetY = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeLeaveTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
    }
    
//    if(isNowBottom == YES && _lastOffsetY > 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeLeaveTopNotification object:nil userInfo:@{@"canScroll":@"0"}];
//    } else if (_lastOffsetY == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeLeaveTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
//    }
    
//    if (_lastOffsetY == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeLeaveTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
//    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row];
    return cell;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
