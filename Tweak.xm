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
        UIImage *nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
        if(nowPlayingArtwork) {
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
            backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.backgroundView = backgroundImageView;
            [backgroundImageView setImage:nowPlayingArtwork];
        }
    });
}
-(void)layoutSubviews {
    %orig;
    [self setBackground];
    NSLog(@"settingsnowplaying moved to window");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBackground) name:@"changeSettingsArtwork" object:nil];
}
%end