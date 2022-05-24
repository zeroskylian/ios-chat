//
//  WFCCRichNotificationMessageContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/8/16.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCRichNotificationMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"


@implementation WFCCRichNotificationMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    payload.pushContent = self.title;
    payload.content = self.desc;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if(self.remark.length)
        [dict setObject:self.remark forKey:@"remark"];
    if(self.exName.length)
        [dict setObject:self.exName forKey:@"exName"];
    if(self.exPortrait.length)
        [dict setObject:self.exPortrait forKey:@"exPortrait"];
    if(self.exUrl.length)
        [dict setObject:self.exUrl forKey:@"exUrl"];
    if(self.appId.length)
        [dict setObject:self.appId forKey:@"appId"];
    
    if(self.datas.count) {
        [dict setObject:self.datas forKey:@"datas"];
    }
    
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:kNilOptions
                                                     error:nil];
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    self.title = payload.pushContent;
    self.desc = payload.content;
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.remark = [self getString:dictionary ofKey:@"remark"];
        self.exName = [self getString:dictionary ofKey:@"exName"];
        self.exPortrait = [self getString:dictionary ofKey:@"exProtrait"];
        self.exUrl = [self getString:dictionary ofKey:@"exUrl"];
        self.appId = [self getString:dictionary ofKey:@"appId"];
        
        self.datas = [self getArray:dictionary ofKey:@"datas"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_RICH_NOTIFICATION;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return self.title;
}
@end
