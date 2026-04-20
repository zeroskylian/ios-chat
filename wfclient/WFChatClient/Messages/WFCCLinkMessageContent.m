//
//  WFCCTextMessageContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/8/16.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCLinkMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"
#import "WFCCDictionary.h"

@implementation WFCCLinkMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSMutableString *searchableContent = [NSMutableString string];
    
    if (self.title) {
        dataDict[@"tt"] = self.title;
        [searchableContent appendString:self.title];
    }
    
    if (self.contentDigest) {
        dataDict[@"d"] = self.contentDigest;
        [searchableContent appendString:self.contentDigest];
    }
    if (self.url) {
        dataDict[@"u"] = self.url;
        [searchableContent appendString:self.url];
    }
    
    if (self.thumbnailUrl) {
        [dataDict setObject:self.thumbnailUrl forKey:@"t"];
    }
    
    payload.searchableContent = searchableContent;
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                                           options:kNilOptions
                                                                             error:nil];
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    NSError *__error = nil;
    WFCCDictionary *dictionary = [WFCCDictionary fromData:payload.binaryContent error:&__error];
    if (!__error) {
        self.contentDigest = dictionary[@"d"];
        self.url = dictionary[@"u"];
        self.thumbnailUrl = dictionary[@"t"];
        NSString *title = dictionary[@"tt"];
        if (title) {
            self.title = title;
        } else {
            self.title = payload.searchableContent;
        }
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_LINK;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
  return [NSString stringWithFormat:WFCCString(@"LinkMessageDigest"), self.title];
}
@end
