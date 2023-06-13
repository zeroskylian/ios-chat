//
//  WFCCCompositeMessageContent.m
//  WFChatClient
//
//  Created by Tom Lee on 2020/10/4.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCCCompositeMessageContent.h"
#import "Common.h"
#import "WFCCIMService.h"
#import "WFCCMessage.h"
#import "WFCCUtilities.h"

@implementation WFCCCompositeMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMediaMessagePayload *payload = (WFCCMediaMessagePayload *)[super encode];
    payload.content = self.title;
    if(self.mentionedType > 0) {
        payload.mentionedType = self.mentionedType;
        payload.mentionedTargets = self.mentionedTargets;
    }
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSMutableArray *arrays = [[NSMutableArray alloc] init];
    int size = 0;
    NSMutableArray *binArrays = nil;
    for (WFCCMessage *msg in self.messages) {
        NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
        if (msg.messageUid) {
            [msgDict setValue:@(msg.messageUid) forKey:@"uid"];
        }
        [msgDict setValue:@(msg.conversation.type) forKey:@"type"];
        [msgDict setValue:msg.conversation.target forKey:@"target"];
        if (msg.conversation.line) {
            [msgDict setValue:@(msg.conversation.line) forKey:@"line"];
        }
        if (msg.fromUser) {
            [msgDict setValue:msg.fromUser forKey:@"from"];
        }
        if([msg.toUsers isKindOfClass:[NSArray class]]) {
            if (msg.toUsers.count) {
                [msgDict setValue:msg.toUsers forKey:@"tos"];
            }
        }
        if (msg.direction) {
            [msgDict setValue:@(msg.direction) forKey:@"direction"];
        }
        if (msg.status) {
            [msgDict setValue:@(msg.status) forKey:@"status"];
        }
        if (msg.serverTime) {
            [msgDict setValue:@(msg.serverTime) forKey:@"serverTime"];
        }
        if(msg.localExtra) {
            [msgDict setValue:msg.localExtra forKey:@"le"];
        }
        
        WFCCMessagePayload *msgPayload = [msg.content encode];
        if (msgPayload.contentType) {
            [msgDict setValue:@(msgPayload.contentType) forKey:@"ctype"];
        }
        if (msgPayload.searchableContent.length) {
            [msgDict setObject:msgPayload.searchableContent forKey:@"csc"];
            payload.searchableContent = [NSString stringWithFormat:@"%@%@ ", payload.searchableContent, msgPayload.searchableContent];   
        }
        if (msgPayload.pushContent.length) {
            [msgDict setObject:msgPayload.pushContent forKey:@"cpc"];
        }
        if (msgPayload.pushData.length) {
            [msgDict setObject:msgPayload.pushData forKey:@"cpd"];
        }
        if (msgPayload.content.length) {
            [msgDict setObject:msgPayload.content forKey:@"cc"];
        }
        if (msgPayload.binaryContent.length) {
            [msgDict setObject:[msgPayload.binaryContent base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] forKey:@"cbc"];
        }
        if (msgPayload.mentionedType) {
            [msgDict setObject:@(msgPayload.mentionedType) forKey:@"cmt"];
        }
        if (msgPayload.mentionedTargets.count) {
            [msgDict setObject:msgPayload.mentionedTargets forKey:@"cmts"];
        }
        if (msgPayload.extra.length) {
            [msgDict setObject:msgPayload.extra forKey:@"ce"];
        }
        if ([msgPayload isKindOfClass:WFCCMediaMessagePayload.class]) {
            WFCCMediaMessagePayload *mediaPayload = (WFCCMediaMessagePayload *)msgPayload;
            if (mediaPayload.mediaType) {
                [msgDict setObject:@(mediaPayload.mediaType) forKey:@"mt"];
            }
            if (mediaPayload.remoteMediaUrl) {
                [msgDict setObject:mediaPayload.remoteMediaUrl forKey:@"mru"];
            }
        }

        if (!binArrays) {
            NSData *msgData =  [NSJSONSerialization dataWithJSONObject:msgDict
                                                               options:kNilOptions
                                                                 error:nil];
            size += msgData.length;
            if (size > 20480 && arrays.count) {
                binArrays = [arrays copy];
            }
        }
        [arrays addObject:msgDict];
    }
    if (binArrays && !self.localPath.length) {
        [dataDict setObject:binArrays forKey:@"ms"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"ms":arrays}
                                                                options:kNilOptions
                                                                  error:nil];
        CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
        CFRelease(uuidObject);
        
        NSString *path = [[WFCCUtilities getDocumentPathWithComponent:@"/COMPOSITE_MESSAGE"] stringByAppendingPathComponent:uuid];
        [data writeToFile:path atomically:YES];
        payload.localMediaPath = path;
        payload.mediaType = Media_Type_FILE;
    } else {
        if (binArrays) {
            [dataDict setObject:binArrays forKey:@"ms"];
        } else {
            [dataDict setObject:arrays forKey:@"ms"];
        }
    }
    
    if(self.remoteUrl.length) {
        payload.remoteMediaUrl = self.remoteUrl;
    }
    

    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                            options:kNilOptions
                                                              error:nil];

    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    self.title = payload.content;
    self.loaded = YES;
    if(payload.mentionedType > 0) {
        self.mentionedType = payload.mentionedType;
        self.mentionedTargets = payload.mentionedTargets;
    }
    if ([payload isKindOfClass:WFCCMediaMessagePayload.class]) {
        WFCCMediaMessagePayload *mediaPayload = (WFCCMediaMessagePayload *)payload;
        if (mediaPayload.localMediaPath.length) {
            NSData *data = [NSData dataWithContentsOfFile:[WFCCUtilities getSendBoxFilePath:mediaPayload.localMediaPath]];
            if(data) {
                payload.binaryContent = data;
            }
        } else if(mediaPayload.remoteMediaUrl.length) {
            self.loaded = NO;
        }
        self.localPath = mediaPayload.localMediaPath;
        self.remoteUrl = mediaPayload.remoteMediaUrl;
    }

    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    
    NSMutableArray<WFCCMessage *> *messages = [[NSMutableArray alloc] init];
    if (!__error && dictionary && [dictionary[@"ms"] isKindOfClass:[NSArray class]]) {
        NSArray *arrays = (NSArray *)dictionary[@"ms"];
        for (NSDictionary *msgDict in arrays) {
            WFCCMessage *msg = [[WFCCMessage alloc] init];
            msg.messageUid = [msgDict[@"uid"] longLongValue];
            
            msg.conversation = [[WFCCConversation alloc] init];
            msg.conversation.type = [msgDict[@"type"] intValue];
            msg.conversation.target = msgDict[@"target"];
            msg.conversation.line = [msgDict[@"line"] intValue];
            
            msg.fromUser = msgDict[@"from"];
            msg.toUsers = msgDict[@"tos"];
            msg.direction = [msgDict[@"direction"] intValue];
            msg.status = [msgDict[@"status"] intValue];
            if([msgDict[@"serverTime"] isKindOfClass:NSDictionary.class]) {
                NSDictionary *timeDict = msgDict[@"serverTime"];
                long long high = [timeDict[@"high"] longLongValue];
                long long low = [timeDict[@"low"] longLongValue];
                msg.serverTime = (high << 32) + low;
            } else {
                msg.serverTime = [msgDict[@"serverTime"] longLongValue];
            }
            
            msg.localExtra = msgDict[@"le"];
            
            WFCCMediaMessagePayload *payload = [[WFCCMediaMessagePayload alloc] init];
            payload.contentType = [msgDict[@"ctype"] intValue];
            payload.searchableContent = msgDict[@"csc"];
            payload.pushContent = msgDict[@"cpc"];
            payload.pushData = msgDict[@"cpd"];
            payload.content = msgDict[@"cc"];
            if (msgDict[@"cbc"]) {
                payload.binaryContent = [[NSData alloc] initWithBase64EncodedString:msgDict[@"cbc"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            }
            
            payload.mentionedType = [msgDict[@"cmt"] intValue];
            payload.mentionedTargets = msgDict[@"cmts"];
            payload.extra = msgDict[@"ce"];
            payload.mediaType = [msgDict[@"mt"] intValue];
            payload.remoteMediaUrl = msgDict[@"mru"];
            
            msg.content = [[WFCCIMService sharedWFCIMService] messageContentFromPayload:payload];
            [messages addObject:msg];
        }
        self.messages = [messages copy];
    }
    
}

- (void)setLocalPath:(NSString *)localPath {
    [super setLocalPath:localPath];
    if (localPath.length) {
        if (!self.loaded) {
            [self decode:[self encode]];
        }
    }
    
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_COMPOSITE_MESSAGE;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return [NSString stringWithFormat:@"[聊天记录]:%@", self.title];
}
@end
