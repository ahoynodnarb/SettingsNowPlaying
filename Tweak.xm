// @TODO: Fix needing to scroll to update view
// Also find something other than layoutsubviews to use
// It's basically just a recursive function with no end condition
#import <Foundation/NSDistributedNotificationCenter.h>
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
        if(nowPlayingArtwork) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
                backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
                self.backgroundView = backgroundImageView;
                [backgroundImageView setImage:nowPlayingArtwork];
            });
        }
    });
}
-(void)didMoveToWindow {
    //fixes in case already playing music
    [self setBackground];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setBackground) name:@"changeSettingsArtwork" object:nil];
    %orig;
}
%end