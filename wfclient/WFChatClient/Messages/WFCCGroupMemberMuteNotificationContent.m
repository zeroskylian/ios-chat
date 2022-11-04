//
//  WFCCCreateGroupNotificationContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/9/19.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCGroupMemberMuteNotificationContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"

@implementation WFCCGroupMemberMuteNotificationContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.creator) {
        [dataDict setObject:self.creator forKey:@"o"];
    }
    if (self.type) {
        [dataDict setObject:self.type forKey:@"n"];
    }
    
    if (self.groupId) {
        [dataDict setObject:self.groupId forKey:@"g"];
    }
    
    if (self.targetIds) {
        [dataDict setObject:self.targetIds forKey:@"ms"];
    }
    
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                                           options:kNilOptions
                                                                             error:nil];
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.creator = dictionary[@"o"];
        self.type = dictionary[@"n"];
        self.groupId = dictionary[@"g"];
        self.targetIds = dictionary[@"ms"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_MUTE_MEMBER;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_NOT_PERSIST;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return [self formatNotification:message];
}

- (NSString *)formatNotification:(WFCCMessage *)message {
    NSString *formatMsg;

    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.creator]) {
        formatMsg = @"你";
    } else {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.creator refresh:NO];
        if (userInfo.displayName.length > 0) {
            formatMsg = [NSString stringWithFormat:@"%@", userInfo.displayName];
        } else {
            formatMsg = [NSString stringWithFormat:@"%@", self.creator];
        }
    }
    
    if ([self.type isEqualToString:@"1"]) {
        formatMsg = [NSString stringWithFormat:@"%@ 禁言了", formatMsg];
    } else {
        formatMsg = [NSString stringWithFormat:@"%@ 取消禁言了", formatMsg];
    }
    
    int count = 0;
    if([self.targetIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
        formatMsg = [formatMsg stringByAppendingString:@" 你"];
        count++;
    }
    
    for (NSString *member in self.targetIds) {
        if ([member isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            continue;
        } else {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:member refresh:NO];
            if (userInfo.displayName.length > 0) {
                formatMsg = [formatMsg stringByAppendingFormat:@" %@", userInfo.displayName];
            } else {
                formatMsg = [formatMsg stringByAppendingFormat:@" %@", member];
            }
            count++;
            if(count >= 4) {
                break;
            }
        }
    }
    
    if(self.targetIds.count > count) {
        formatMsg = [formatMsg stringByAppendingFormat:@" 等%ld名成员", self.targetIds.count];
    }

    return formatMsg;
}
@end
