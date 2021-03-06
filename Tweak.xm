#import <Foundation/NSDistributedNotificationCenter.h>
#import "SettingsNowPlaying.h"

static void refreshPrefs() {
	NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults]persistentDomainForName:@"com.popsicletreehouse.settingsnowplayingprefs"];
	enabled = [[bundleDefaults objectForKey:@"isEnabled"]boolValue];
    NSLog(@"settingsnowplaying enabled: %d", enabled);
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    refreshPrefs();
}

%hook SBMediaController
- (void)setNowPlayingInfo:(id)arg1 {
    %orig;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"changeSettingsArtwork" object:nil];
}
%end

%hook UITableView

%new
-(void)setBackground {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary* dict = (__bridge NSDictionary *)information;
        nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
        if(nowPlayingArtwork) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[self.backgroundView bounds]];
                [backgroundImageView setClipsToBounds:YES];
                [backgroundImageView setContentMode: UIViewContentModeScaleAspectFill];
                [self setBackgroundView: backgroundImageView];
                [backgroundImageView setImage:nowPlayingArtwork];
            });
        }
    });
}

-(void)didMoveToWindow {
    //fixes in case already playing music
    if(enabled) {
        [self setBackground];
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setBackground) name:@"changeSettingsArtwork" object:nil];
    }
    %orig;
}
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.popsicletreehouse.imtrynavibe.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}