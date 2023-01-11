//
//  WFCUUserSectionKeySupport.m
//  WFChatUIKit
//
//  Created by Zack Zhang on 2020/4/4.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCUUserSectionKeySupport.h"
#import "pinyin.h"
#import "WFCUSelectModel.h"
#import <WFChatClient/WFCChatClient.h>

static NSMutableDictionary *hanziStringDictory = nil;

@implementation WFCUUserSectionKeySupport
+ (NSMutableDictionary *)userSectionKeys:(NSArray *)userList {
    if (!userList)
        return nil;
    NSArray *_keys = @[
                       @"☆",
                       @"A",
                       @"B",
                       @"C",
                       @"D",
                       @"E",
                       @"F",
                       @"G",
                       @"H",
                       @"I",
                       @"J",
                       @"K",
                       @"L",
                       @"M",
                       @"N",
                       @"O",
                       @"P",
                       @"Q",
                       @"R",
                       @"S",
                       @"T",
                       @"U",
                       @"V",
                       @"W",
                       @"X",
                       @"Y",
                       @"Z",
                       @"#"
                       ];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary new];
    NSMutableArray *_tempOtherArr = [NSMutableArray new];
    
    NSArray<NSString *> *favUsers = [[WFCCIMService sharedWFCIMService] getFavUsers];
    
    NSMutableArray *favArrays = [[NSMutableArray alloc] init];
    for (NSString *favUser in favUsers) {
        for (WFCUSelectModel *userInfo in userList) {
            if ([userInfo.userInfo.userId isEqualToString:favUser]) {
                [favArrays addObject:userInfo];
                break;
            }
        }
        
    }
    
    if (favArrays.count) {
        [infoDic setObject:favArrays forKey:@"☆"];
    }
    
    BOOL isReturn = NO;
    NSMutableDictionary *firstLetterDict = [[NSMutableDictionary alloc] init];
    for (NSString *key in _keys) {
        if ([key isEqualToString:@"☆"]) {
            continue;
        }
        
        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        NSMutableArray *tempArr = [NSMutableArray new];
        for (id user in userList) {
            NSString *firstLetter;

            WFCUSelectModel *model = (WFCUSelectModel *)user;
            NSString *userName = model.userInfo.displayName;
            if (model.userInfo.friendAlias.length) {
                userName = model.userInfo.friendAlias;
            }
            if (userName.length == 0) {
                model.userInfo.displayName = [NSString stringWithFormat:@"<%@>", model.userInfo.userId];
                userName = model.userInfo.displayName;
            }
            
            firstLetter = [firstLetterDict objectForKey:userName];
            if (!firstLetter) {
                firstLetter = [self getFirstUpperLetter:userName];
                [firstLetterDict setObject:firstLetter forKey:userName];
            }
            
            
        
            if ([firstLetter isEqualToString:key]) {
                [tempArr addObject:user];
            }
            
            if (isReturn)
                continue;
            char c = [firstLetter characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if (![tempArr count])
            continue;
        [infoDic setObject:tempArr forKey:key];
    }
    if ([_tempOtherArr count])
        [infoDic setObject:_tempOtherArr forKey:@"#"];
    
    NSArray *keys = [[infoDic allKeys]
                     sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                         
                         return [obj1 compare:obj2 options:NSNumericSearch];
                     }];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];
    if ([allKeys containsObject:@"#"]) {
        [allKeys removeObject:@"#"];
        [allKeys insertObject:@"#" atIndex:allKeys.count];
    }
    if ([allKeys containsObject:@"☆"]) {
        [allKeys removeObject:@"☆"];
        [allKeys insertObject:@"☆" atIndex:0];
    }
    
    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    [resultDic setObject:infoDic forKey:@"infoDic"];
    [resultDic setObject:allKeys forKey:@"allKeys"];
    [infoDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableArray *_tempOtherArr = (NSMutableArray *)obj;
        [_tempOtherArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            WFCUSelectModel *user1 = (WFCUSelectModel *)obj1;
            WFCUSelectModel *user2 = (WFCUSelectModel *)obj2;
            NSString *user1Pinyin = [[self class] hanZiToPinYinWithString:user1.userInfo.displayName];
            NSString *user2Pinyin = [[self class] hanZiToPinYinWithString:user2.userInfo.displayName];
            return [user1Pinyin compare:user2Pinyin];
        }];
    }];
    return resultDic;
}

+ (NSString *)getFirstUpperLetter:(NSString *)hanzi {
    NSString *pinyin = [self hanZiToPinYinWithString:hanzi];
    NSString *firstUpperLetter = [[pinyin substringToIndex:1] uppercaseString];
    if ([firstUpperLetter compare:@"A"] != NSOrderedAscending &&
        [firstUpperLetter compare:@"Z"] != NSOrderedDescending) {
        return firstUpperLetter;
    } else {
        return @"#";
    }
}

+ (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
    if (!hanZi) {
        return nil;
    }
    if (!hanziStringDictory) {
        hanziStringDictory = [[NSMutableDictionary alloc] init];
    }
    
    NSString *pinYinResult = [hanziStringDictory objectForKey:hanZi];
    if (pinYinResult) {
        return pinYinResult;
    }
    pinYinResult = [NSString string];
    for (int j = 0; j < hanZi.length; j++) {
        NSString *singlePinyinLetter = nil;
        if ([self isChinese:[hanZi substringWithRange:NSMakeRange(j, 1)]]) {
            singlePinyinLetter = [[NSString
                                   stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])]
                                  uppercaseString];
        }else{
            singlePinyinLetter = [hanZi substringWithRange:NSMakeRange(j, 1)];
        }
        
        pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    [hanziStringDictory setObject:pinYinResult forKey:hanZi];
    return pinYinResult;
}

+ (BOOL)isChinese:(NSString *)text
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:text];
}
@end
