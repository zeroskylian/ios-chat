//
//  WFCCCompositeMessageContent.h
//  WFChatClient
//
//  Created by Tom Lee on 2020/10/4.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCCMediaMessageContent.h"
@class WFCCMessage;

NS_ASSUME_NONNULL_BEGIN

@interface WFCCCompositeMessageContent : WFCCMediaMessageContent

@property (nonatomic, strong)NSString *title;

@property (nonatomic, strong)NSArray<WFCCMessage *> *messages;

@property(nonatomic, assign)BOOL loaded;

/**
 提醒类型，1，提醒部分对象（mentinedTarget）。2，提醒全部。其他不提醒
 */
@property (nonatomic, assign)int mentionedType;

/**
 提醒对象，mentionedType 1时有效
 */
@property (nonatomic, nullable, strong)NSArray<NSString *> *mentionedTargets;
@end

NS_ASSUME_NONNULL_END
