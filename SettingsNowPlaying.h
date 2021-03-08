#import <MediaRemote/MediaRemote.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>
@interface SBApplication
- (NSString *)bundleIdentifier;
@end
@interface UITableView ()
- (void)setBackground;
@end
@interface SBMediaController
+ (id)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end
static UIImage *nowPlayingArtwork;
static BOOL enabled = YES;
static void refreshPrefs()
{
    NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.popsicletreehouse.settingsnowplayingprefs"];
    enabled = [[bundleDefaults objectForKey:@"isEnabled"] boolValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    refreshPrefs();
}