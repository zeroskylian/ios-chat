//
//  TypingMessageContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/8/16.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCLeaveChannelChatMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"


@implementation WFCCLeaveChannelChatMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_LEAVE_CHANNEL_CHAT;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_TRANSPARENT;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
  return nil;
}
@end
