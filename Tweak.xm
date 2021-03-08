#import "SettingsNowPlaying.h"

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
        UIImageView *backgroundImageView = [[UIImageView alloc] init];
        [backgroundImageView setClipsToBounds:YES];
        [backgroundImageView setContentMode: UIViewContentModeScaleAspectFill];
        [self setBackgroundView: backgroundImageView];
        [backgroundImageView setImage:nowPlayingArtwork];
    });
}

-(void)didMoveToWindow {
    %orig;
    if(enabled) {
        //fixes in case already playing music
        if(!self.backgroundView)
            [self setBackground];
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setBackground) name:@"changeSettingsArtwork" object:nil];
    }
}
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.popsicletreehouse.settingsnowplaying.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}