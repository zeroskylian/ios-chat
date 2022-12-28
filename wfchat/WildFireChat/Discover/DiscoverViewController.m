//
//  DiscoverViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "DiscoverViewController.h"
#import "ChatroomListViewController.h"
#import "DeviceTableViewController.h"
#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatClient/WFCCIMService.h>
#import "DiscoverMomentsTableViewCell.h"
#ifdef WFC_MOMENTS
#import <WFMomentClient/WFMomentClient.h>
#import <WFMomentUIKit/WFMomentUIKit.h>
#endif
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "WFCConfig.h"

@interface DiscoverViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)BOOL hasMoments;
@property (nonatomic, strong)NSMutableArray *dataSource;
@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray arrayWithArray:@[
                       @{@"title":LocalizedString(@"Chatroom"),@"image":@"discover_chatroom",@"des":@"chatroom"},
                       @{@"title":LocalizedString(@"Robot"),@"image":@"robot",@"des":@"robot"},
                       @{@"title":LocalizedString(@"Channel"), @"image":@"chat_channel",@"des":@"channel"},
                       @{@"title":LocalizedString(@"DevDocs"), @"image":@"dev_docs",@"des":@"Dev"}
//                     @{@"title":@"Things", @"image":@"discover_things",@"des":@"Things"}
    ]];
    
    if(NSClassFromString(@"SDTimeLineTableViewController")) {
        [self.dataSource insertObject:@{@"title":LocalizedString(@"Moments"),@"image":@"AlbumReflashIcon",@"des":@"moment"} atIndex:0];
        self.hasMoments = YES;
    } else {
        self.hasMoments = NO;
    }
#if WFCU_SUPPORT_VOIP
    if ([WFAVEngineKit sharedEngineKit].supportConference) {
        [self.dataSource addObject:@{@"title":LocalizedString(@"Conference"),@"image":@"discover_conference",@"des":@"Conference"}];
    }
#endif
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    [self.tableView reloadData];
    self.tableView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
#ifdef WFC_MOMENTS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadCommentStatusChanged:) name:kReceiveComments object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadCommentStatusChanged:) name:kClearUnreadComments object:nil];
    
#endif
}

- (void)onUnreadCommentStatusChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUnreadStatus];
}

- (void)updateUnreadStatus {
    [self.tableView reloadData];
#ifdef WFC_MOMENTS
    int momentIndex = 2;
    if(WORK_PLATFORM_URL.length)
        momentIndex = 3;
    [self.tabBarController.tabBar showBadgeOnItemIndex:momentIndex badgeValue:[[WFMomentService sharedService] getUnreadCount]];
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 9)];
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 9;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *des = self.dataSource[indexPath.section][@"des"];
    if ([des isEqualToString:@"moment"]) {
         UIViewController *vc = [[NSClassFromString(@"SDTimeLineTableViewController") alloc] init];
                   vc.hidesBottomBarWhenPushed = YES;
                   [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([des isEqualToString:@"chatroom"]) {
        ChatroomListViewController *vc = [[ChatroomListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
                  [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([des isEqualToString:@"channel"]) {
        WFCUFavChannelTableViewController *channelVC = [[WFCUFavChannelTableViewController alloc] init];;
        channelVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:channelVC animated:YES];
    }
    
    if ([des isEqualToString:@"robot"]) {
            WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
            mvc.conversation = [[WFCCConversation alloc] init];
            mvc.conversation.type = Single_Type;
            mvc.conversation.target = @"FireRobot";
            mvc.conversation.line = 0;
        
            mvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mvc animated:YES];
        
    }
    

    if ([des isEqualToString:@"Dev"]) {
        WFCUBrowserViewController *vc = [[WFCUBrowserViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.url = @"http://docs.wildfirechat.cn";
        [self.navigationController pushViewController:vc animated:YES];
    }
//
//    if ([des isEqualToString:@"Things"]) {
//        DeviceTableViewController *vc = [[DeviceTableViewController alloc] init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    if ([des isEqualToString:@"Conference"]) {
        WFZHomeViewController *vc = [[WFZHomeViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0 && self.hasMoments) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"momentsCell"];
        if (cell == nil) {
            cell = [[DiscoverMomentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"momentsCell"];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    cell.textLabel.text = self.dataSource[indexPath.section][@"title"];
    cell.imageView.image = [UIImage imageNamed:self.dataSource[indexPath.section][@"image"]];
    if (indexPath.section == 0 && self.hasMoments) {
            DiscoverMomentsTableViewCell *momentsCell = (DiscoverMomentsTableViewCell *)cell;
            __weak typeof(self)ws = self;
#ifdef WFC_MOMENTS
            int unread = [[WFMomentService sharedService] getUnreadCount];
            if (unread) {
                momentsCell.bubbleView.hidden = NO;
                [momentsCell.bubbleView setBubbleTipNumber:unread];
            } else {
                momentsCell.bubbleView.hidden = YES;
            }
            NSMutableArray<WFMFeed *> *feeds = [[WFMomentService sharedService] restoreCache:nil];
            if (feeds.count > 0) {
                momentsCell.lastFeed = [feeds objectAtIndex:0];
            } else {
                [[WFMomentService sharedService] getFeeds:0 count:10 fromUser:nil success:^(NSArray<WFMFeed *> * _Nonnull feeds) {
                    if (feeds.count) {
                        [[WFMomentService sharedService] storeCache:feeds forUser:nil];
                        [ws.tableView reloadData];
                    }
                } error:^(int error_code) {
                    
                }];
            }
#endif
        }
    return cell;
}

@end
