//
//  Utilities.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUUtilities.h"
#import "WFCUImage.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#define kIs_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812.0f ||[UIScreen mainScreen].bounds.size.height == 896.0f ||[UIScreen mainScreen].bounds.size.height == 844.0f ||[UIScreen mainScreen].bounds.size.height == 926.0f ||[UIScreen mainScreen].bounds.size.height == 932.0f)

#define  kTabbarSafeBottomMargin        (kIs_iPhoneX ? 34.f : 0.f)

@implementation WFCUUtilities
+ (CGSize)getTextDrawingSize:(NSString *)text
                        font:(UIFont *)font
             constrainedSize:(CGSize)constrainedSize {
  if (text.length <= 0) {
    return CGSizeZero;
  }
  
  if ([text respondsToSelector:@selector(boundingRectWithSize:
                                         options:
                                         attributes:
                                         context:)]) {
    return [text boundingRectWithSize:constrainedSize
                              options:(NSStringDrawingTruncatesLastVisibleLine |
                                       NSStringDrawingUsesLineFragmentOrigin |
                                       NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName : font
                                        }
                              context:nil]
    .size;
  } else {
    return [text sizeWithFont:font
            constrainedToSize:constrainedSize
                lineBreakMode:NSLineBreakByTruncatingTail];
  }
}

+ (NSString *)formatTimeLabel:(int64_t)timestamp {
    if (timestamp == 0) {
        return nil;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    NSDate *current = [[NSDate alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger years = [calendar component:NSCalendarUnitYear fromDate:date];
    NSInteger curYears = [calendar component:NSCalendarUnitYear fromDate:current];

    if ([calendar isDateInToday:date]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        return [formatter stringFromDate:date];
    } else if([calendar isDateInYesterday:date]) {
        return @"昨天";
    } else {
        if (years == curYears) {
            NSInteger weeks = [calendar component:NSCalendarUnitWeekOfYear fromDate:date];
            NSInteger curWeeks = [calendar component:NSCalendarUnitWeekOfYear fromDate:current];
            
            NSInteger weekDays = [calendar component:NSCalendarUnitWeekday fromDate:date];
            if (weeks == curWeeks) {
                switch (weekDays) {
                    case 1:
                        return @"周日";
                        break;
                    case 2:
                        return @"周一";
                        break;
                    case 3:
                        return @"周二";
                        break;
                    case 4:
                        return @"周三";
                        break;
                    case 5:
                        return @"周四";
                        break;
                    case 6:
                        return @"周五";
                        break;
                    case 7:
                        return @"周六";
                        break;
                        
                    default:
                        break;
                }
                return [NSString stringWithFormat:@"周%ld", (long)weekDays];
            } else {
                NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:date];
                NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
                return [NSString stringWithFormat:@"%d月%d号", (int)month, (int)day];
            }
        } else {
            NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:date];
            NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
            return [NSString stringWithFormat:@"%d年%d月%d号",(int)years,(int)month, (int)day];
        }
        
    }
}

+ (NSString *)formatTimeDetailLabel:(int64_t)timestamp {
    if (timestamp == 0) {
        return nil;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    
    NSDate *current = [[NSDate alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger months = [calendar component:NSCalendarUnitMonth fromDate:date];
    NSInteger curMonths = [calendar component:NSCalendarUnitMonth fromDate:current];
    NSInteger years = [calendar component:NSCalendarUnitYear fromDate:date];
    NSInteger curYears = [calendar component:NSCalendarUnitYear fromDate:current];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *hourTimeStr =  [formatter stringFromDate:date];
    
    NSInteger weeks = [calendar component:NSCalendarUnitWeekOfYear fromDate:date];
    NSInteger curWeeks = [calendar component:NSCalendarUnitWeekOfYear fromDate:current];
    
    
    NSInteger weekDays = [calendar component:NSCalendarUnitWeekday fromDate:date];
    if ([calendar isDateInToday:date]) {
        return hourTimeStr;
    } else if([calendar isDateInYesterday:date]) {
        return [NSString stringWithFormat:@"昨天 %@", hourTimeStr];
    } else if (years != curYears) {
        [formatter setDateFormat:@"yyyy'年'MM'月'dd'日 'HH':'mm"];
        return [formatter stringFromDate:date];
    } else if(months != curMonths) {
        if(weeks == curWeeks) {
            return [NSString stringWithFormat:@"%@ %@", [WFCUUtilities formatWeek:weekDays], hourTimeStr];
        }
        
        [formatter setDateFormat:@"MM'月'dd'日 'HH':'mm"];
        return [formatter stringFromDate:date];
    } else {
        if(weeks == curWeeks) {
            return [NSString stringWithFormat:@"%@ %@", [WFCUUtilities formatWeek:weekDays], hourTimeStr];
        }
        [formatter setDateFormat:@"dd'日 'HH':'mm"];
        return [formatter stringFromDate:date];
    }
}
+ (NSString *)formatWeek:(NSUInteger)weekDays {
    weekDays = weekDays % 7;
    switch (weekDays) {
        case 2:
            return @"周一";
        case 3:
            return @"周二";
        case 4:
            return @"周三";
        case 5:
            return @"周四";
        case 6:
            return @"周五";
        case 0:
            return @"周六";
        case 1:
            return @"周日";
            
        default:
            break;
    }
    return nil;
}
+ (UIImage *)thumbnailWithImage:(UIImage *)originalImage maxSize:(CGSize)size {
    CGSize originalsize = [originalImage size];
    //原图长宽均小于标准长宽的，不作处理返回原图
    if (originalsize.width<size.width && originalsize.height<size.height){
        return originalImage;
    }
    //原图长宽均大于标准长宽的，按比例缩小至最大适应值
    else if(originalsize.width>size.width && originalsize.height>size.height){
        CGFloat rate = 1.0;
        CGFloat widthRate = originalsize.width/size.width;
        CGFloat heightRate = originalsize.height/size.height;
        rate = widthRate>heightRate?heightRate:widthRate;
        CGImageRef imageRef = nil;
        if (heightRate>widthRate){
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-size.height*rate/2, originalsize.width, size.height*rate));//获取图片整体部分
        }else{
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-size.width*rate/2, 0, size.width*rate, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        return standardImage;
    }
    //原图长宽有一项大于标准长宽的，对大于标准的那一项进行裁剪，另一项保持不变
    else if(originalsize.height>size.height || originalsize.width>size.width){
        CGImageRef imageRef = nil;
        if(originalsize.height>size.height){
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-originalsize.width/2, originalsize.width, originalsize.width));//获取图片整体部分
        }
        else if (originalsize.width>size.width){
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-originalsize.height/2, 0, originalsize.height, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        return standardImage;
    }
    //原图为标准长宽的，不做处理
    else{
        return originalImage;
    }
}

+ (NSString *)formatSizeLable:(int64_t)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%lldB", size];
    } else if(size < 1024*1024) {
        return [NSString stringWithFormat:@"%lldK", size/1024];
    } else {
        return [NSString stringWithFormat:@"%.2fM", size/1024.f/1024];
    }
}
+ (UIImage *)imageForExt:(NSString *)extName {
    NSString *fileImage = nil;
    if ([extName isEqualToString:@"doc"] || [extName isEqualToString:@"docx"] || [extName isEqualToString:@"pages"]) {
        fileImage = @"file_type_word";
    } else if ([extName isEqualToString:@"xls"] || [extName isEqualToString:@"xlsx"] || [extName isEqualToString:@"numbers"]) {
        fileImage = @"file_type_xls";
    } else if ([extName isEqualToString:@"ppt"] || [extName isEqualToString:@"pptx"] || [extName isEqualToString:@"keynote"]) {
        fileImage = @"file_type_ppt";
    } else if ([extName isEqualToString:@"pdf"]) {
        fileImage = @"file_type_pdf";
    } else if([extName isEqualToString:@"html"] || [extName isEqualToString:@"htm"]) {
        fileImage = @"file_type_html";
    } else if([extName isEqualToString:@"txt"]) {
        fileImage = @"file_type_text";
    } else if([extName isEqualToString:@"jpg"] || [extName isEqualToString:@"png"] || [extName isEqualToString:@"jpeg"]) {
        fileImage = @"file_type_image";
    } else if([extName isEqualToString:@"mp3"] || [extName isEqualToString:@"amr"] || [extName isEqualToString:@"acm"] || [extName isEqualToString:@"aif"]) {
        fileImage = @"file_type_audio";
    } else if([extName isEqualToString:@"mp4"] || [extName isEqualToString:@"avi"]
              || [extName isEqualToString:@"mov"] || [extName isEqualToString:@"asf"]
              || [extName isEqualToString:@"wmv"] || [extName isEqualToString:@"mpeg"]
              || [extName isEqualToString:@"ogg"] || [extName isEqualToString:@"mkv"]
              || [extName isEqualToString:@"rmvb"] || [extName isEqualToString:@"f4v"]) {
        fileImage = @"file_type_video";
    } else if([extName isEqualToString:@"exe"]) {
        fileImage = @"file_type_exe";
    } else if([extName isEqualToString:@"xml"]) {
        fileImage = @"file_type_xml";
    } else if([extName isEqualToString:@"zip"] || [extName isEqualToString:@"rar"]
              || [extName isEqualToString:@"gzip"] || [extName isEqualToString:@"gz"]) {
        fileImage = @"file_type_zip";
    } else {
        fileImage = @"file_type_unknown";
    }
    return [WFCUImage imageNamed:fileImage];
}

+ (NSString *)getUnduplicatedPath:(NSString *)path {
    int count = 1;
    NSString *fileName = [path stringByDeletingPathExtension];
    NSString *fileExt = [path pathExtension];
    while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSString stringWithFormat:@"%@(%d)", fileName, count++] stringByAppendingPathExtension:fileExt];
    }
    
    return path;
}

+ (BOOL)isFileExist:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (CGFloat)wf_navigationHeight {
    return 44.f;
}

+ (CGFloat)wf_statusBarHeight {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        return statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

+ (CGFloat)wf_navigationFullHeight {
    return [WFCUUtilities wf_statusBarHeight] + 44;
}
 
+ (CGFloat)wf_safeDistanceBottom {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.bottom;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    
    return kTabbarSafeBottomMargin;
}

+ (BOOL)checkRecordOrCameraPermission:(BOOL)isAudio complete:(void (^)(BOOL granted))complete viewController:(UIViewController *)controller {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:isAudio?AVMediaTypeAudio:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted) {
        [WFCUUtilities showPermissionAlertWithMessage:isAudio?@"没有麦克风权限，无法完成语音通话或者录音功能":@"没有录像权限，无法完成视频通话" withSettingAction:NO withController:controller];
        if(complete) complete(NO);
    } else if (authStatus == AVAuthorizationStatusDenied) {
        [WFCUUtilities showPermissionAlertWithMessage:isAudio?@"通话或者录音需要麦克风权限，请开启麦克风权限":@"视频通话需要摄像头权限，请开启摄像头权限" withSettingAction:YES withController:controller];
        if(complete) complete(NO);
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice
         requestAccessForMediaType:isAudio?AVMediaTypeAudio:AVMediaTypeVideo
         completionHandler:^(BOOL granted) {
            if(!granted) {
                [WFCUUtilities showPermissionAlertWithMessage:isAudio?@"通话需要麦克风权限，请开启麦克风权限":@"视频通话需要摄像头权限，请开启摄像头权限" withSettingAction:YES withController:controller];
            }
            if(complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(granted);
                });
            }
         }];
    } else {
        if(complete) complete(YES);
        return YES;
    }
    
    return NO;
}

+ (void)showPermissionAlertWithMessage:(NSString *)message withSettingAction:(BOOL)goSetting withController:(UIViewController *)controller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"权限请求"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    if(goSetting) {
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"前往设置"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }
        }];
        [alertController addAction:settingsAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
    [alertController addAction:cancelAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}
@end
