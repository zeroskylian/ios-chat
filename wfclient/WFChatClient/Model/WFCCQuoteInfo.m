//
//  WFCCQuoteInfo.m
//  WFChatClient
//
//  Created by dali on 2020/10/4.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCCQuoteInfo.h"
#import "WFCCUserInfo.h"
#import "WFCCMessage.h"
#import "WFCCIMService.h"


@implementation WFCCQuoteInfo
- (instancetype)initWithMessage:(WFCCMessage *)msg {
    self = [super init];
    if (self) {
        if (msg.messageUid) {
            self.messageUid = msg.messageUid;
            self.userId = msg.fromUser;
            NSString *groupId = msg.conversation.type == Group_Type ? msg.conversation.target : nil;
            WFCCUserInfo *user = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.fromUser inGroup:groupId refresh:NO];
            self.userDisplayName = user.displayName;
            if (user.groupAlias.length) {
                self.userDisplayName = user.groupAlias;
            }
            self.messageDigest = [msg.content digest:msg];
            NSUInteger maxBytes = 120;
            if (self.messageDigest.length > 48) {
                __block NSUInteger seenBytes = 0;
                __block NSUInteger truncLength = 0;
                NSRange fullLength = (NSRange){0, [self.messageDigest length]};
                [self.messageDigest enumerateSubstringsInRange:fullLength
                                      options:NSStringEnumerationByComposedCharacterSequences
                                   usingBlock:
                    ^(NSString *substring, NSRange substringRange,
                      NSRange _, BOOL *stop)
                    {
                        seenBytes += [substring lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                        if( seenBytes > maxBytes ){
                            *stop = YES;
                            return;
                        }
                        else {
                            truncLength += substringRange.length;
                        }
                }];

                self.messageDigest = [self.messageDigest substringToIndex:truncLength];
            }
        } else {
            return nil;
        }
    }
    return self;
}

- (NSDictionary *)encode {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(self.messageUid) forKey:@"u"];
    if (self.userId.length) {
        [dict setObject:self.userId forKey:@"i"];
    }
    if (self.userDisplayName.length) {
        [dict setObject:self.userDisplayName forKey:@"n"];
    }
    if (self.messageDigest.length) {
        [dict setObject:self.messageDigest forKey:@"d"];
    }
    return [dict copy];
}

- (void)decode:(NSDictionary *)dictData {
    if(dictData[@"messageUid"]) {
        self.messageUid = [dictData[@"messageUid"] longLongValue];
        self.userId = dictData[@"userId"];
        self.userDisplayName = dictData[@"userDisplayName"];
        id messageDigest = dictData[@"messageDigest"];
        if([messageDigest isKindOfClass:NSString.class]) {
            self.messageDigest = messageDigest;
        }
    } else {
        self.messageUid = [dictData[@"u"] longLongValue];
        self.userId = dictData[@"i"];
        self.userDisplayName = dictData[@"n"];
        id messageDigest = dictData[@"d"];
        if([messageDigest isKindOfClass:NSString.class]) {
            self.messageDigest = messageDigest;
        }
    }
}

-(id)toJsonObj {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"userId"] = self.userId;
    dict[@"userDisplayName"] = self.userDisplayName;
    dict[@"messageDigest"] = self.messageDigest;
    [self setDict:dict key:@"messageUid" longlongValue:self.messageUid];
    return dict;
}

@end
