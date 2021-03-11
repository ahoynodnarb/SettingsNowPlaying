#import "SettingsNowPlaying.h"

static void refreshPrefs()
{
    NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.popsicletreehouse.settingsnowplayingprefs"];
    enabled = [bundleDefaults objectForKey:@"isEnabled"] ? [[bundleDefaults objectForKey:@"isEnabled"] boolValue] : YES;
    blur = [bundleDefaults objectForKey:@"isBlur"] ? [[bundleDefaults objectForKey:@"isBlur"]boolValue] : YES;
    intensity = [bundleDefaults objectForKey:@"blurIntensity"] ? [[bundleDefaults objectForKey:@"blurIntensity"]floatValue] : 1.0f;
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    refreshPrefs();
}

%hook SBMediaController
- (void)setNowPlayingInfo:(id)arg1 {
    %orig;
    NSLog(@"settingsnowplaying info updated");
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"changeSettingsArtwork" object:nil];
}
%end

%hook UITableView
%new
-(void)setBackground {
    NSLog(@"settingsnowplaying setBackground called");
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary* dict = (__bridge NSDictionary *)information;
        nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
        if(nowPlayingArtwork) {
            backgroundImageView = [[UIImageView alloc] initWithImage:nowPlayingArtwork];
            [backgroundImageView setClipsToBounds:YES];
            [backgroundImageView setContentMode: UIViewContentModeScaleAspectFill];
            [self setBackgroundView: backgroundImageView];
            if(blur) {
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                blurEffectView.frame = self.backgroundView.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.alpha = intensity;
                [self.backgroundView addSubview:blurEffectView];
            }
        } else
            self.backgroundView = nil;
    });
}

-(void)didMoveToSuperview {
    NSLog(@"settingsnowplaying moved to superview");
    %orig;
    if(enabled) {
        // fixes in case already playing music
        if(!nowPlayingArtwork || !self.backgroundView)
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