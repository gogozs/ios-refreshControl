//
//  SZBundle.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/9.
//

#import "SZBundle.h"

static NSString *BUNDLE_NAME = @"SZRefreshControlBundle";
static NSString *ASSETS_BUNDLE_NAME = @"SZRefreshControlImagesBundle";

@implementation SZBundle

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSBundle *bundle = [self sz_bundle];
    
    return [bundle localizedStringForKey:key value:nil table:nil];
}

+ (NSBundle *)sz_bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:self] pathForResource:BUNDLE_NAME ofType:@"bundle"]];
    });
    
    return bundle;
}

+ (NSBundle *)imageBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:self] pathForResource:ASSETS_BUNDLE_NAME ofType:@"bundle"]];
    });
    
    return bundle;
}
@end
