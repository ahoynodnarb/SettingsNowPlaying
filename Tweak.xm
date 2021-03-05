// @TODO: Fix needing to scroll to update view
// Also find something other than layoutsubviews to use
// It's basically just a recursive function with no end condition

#import "SettingsNowPlaying.h"
%hook SBMediaController
- (void)setNowPlayingInfo:(id)arg1 {
    %orig;
    NSLog(@"settingsnowplaying song changed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSettingsArtwork" object:nil];
}
%end
%hook UITableView
%new
-(void)setBackground {
    NSLog(@"settingsnowplaying setting background...");
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary* dict = (__bridge NSDictionary *)information;
        nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
    });
}
-(void)layoutSubviews {
    %orig;
    NSLog(@"settingsnowplaying moved to window");
    [self setBackground];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundView = backgroundImageView;
        [backgroundImageView setImage:nowPlayingArtwork];
        NSLog(@"settingsnowplaying background set.");
    });
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBackground) name:@"changeSettingsArtwork" object:nil];
}
%end