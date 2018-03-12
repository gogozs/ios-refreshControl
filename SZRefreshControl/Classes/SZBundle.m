//
//  SZBundle.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/9.
//

#import "SZBundle.h"

static NSString *BUNDLE_NAME = @"SZRefreshControlBundle";

@implementation SZBundle

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSBundle *bundle = [self sz_bundle];
    
    NSString *language = [NSLocale preferredLanguages].firstObject;
    
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans"; // 简体中文
        } else { // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant"; // 繁體中文
        }
    } else {
        language = @"en";
    }
    
    NSBundle *b = [NSBundle bundleWithPath:[bundle pathForResource:language ofType:@"lproj"]];
    
    
    return [b localizedStringForKey:key value:nil table:nil];
}

+ (NSBundle *)sz_bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:self] pathForResource:BUNDLE_NAME ofType:@"bundle"]];
    });
    
    return bundle;
}
@end
