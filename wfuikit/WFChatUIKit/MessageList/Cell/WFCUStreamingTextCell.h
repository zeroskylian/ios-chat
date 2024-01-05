//
//  TextCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUMessageCell.h"

@interface WFCUStreamingTextCell : WFCUMessageCell
@property (strong, nonatomic)UILabel *textLabel;
@property (strong, nonatomic)UIActivityIndicatorView *indicatorView;
@end
