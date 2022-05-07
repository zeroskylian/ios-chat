//
//  WFCCTextMessageContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/8/16.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCCallStartMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"


@implementation WFCCCallStartMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    payload.content = self.callId;
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.connectTime) {
        [dataDict setObject:@(self.connectTime) forKey:@"c"];
    }
    if (self.endTime) {
        [dataDict setObject:@(self.endTime) forKey:@"e"];
    }
    if (self.status) {
        [dataDict setObject:@(self.status) forKey:@"s"];
    }
    if (self.pin) {
        [dataDict setObject:self.pin forKey:@"p"];
    }
    
    [dataDict setObject:self.targetIds forKey:@"ts"];
    //多人音视频与单人音视频兼容
    [dataDict setObject:self.targetIds[0] forKey:@"t"];
    [dataDict setValue:@(self.audioOnly?1:0) forKey:@"a"];
    
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                            options:kNilOptions
                                                              error:nil];
    
    NSDictionary *pd;
    if(self.targetIds.count) {
        pd = @{@"callId":self.callId, @"audioOnly":@(self.audioOnly), @"participants":self.targetIds};
    } else {
        pd = @{@"callId":self.callId, @"audioOnly":@(self.audioOnly)};
    }
    
    payload.pushData = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:pd options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    self.callId = payload.content;
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.connectTime = dictionary[@"c"] ? [dictionary[@"c"] longLongValue] : 0;
        self.endTime = dictionary[@"e"] ? [dictionary[@"e"] longLongValue] : 0;
        self.status = dictionary[@"s"] ? [dictionary[@"s"] intValue] : 0;
        self.audioOnly = [dictionary[@"a"] intValue] ? YES : NO;
        self.targetIds = dictionary[@"ts"];
        self.pin = dictionary[@"p"];
        if (self.targetIds.count == 0) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            NSString *target = dictionary[@"t"];
            if(target) {
                [arr addObject:target];
            }
            self.targetIds = arr;
        }
    }
}

+ (int)getContentType {
    return VOIP_CONTENT_TYPE_START;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    if (_audioOnly) {
        return @"[语音通话]";
    } else {
        return @"[视频通话]";
    }
}
@end
