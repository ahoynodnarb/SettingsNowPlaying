#import <MediaRemote/MediaRemote.h>
UIImageView *backgroundImageView = [[UIImageView alloc]init];
static UIImage *nowPlayingArtwork = [[UIImage alloc]init];
static BOOL artworkChanged = YES;
static void changeImage() {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary* dict = (__bridge NSDictionary *)information;
        if(dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) {
            nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
        }
    });
}
%hook UITableView
-(void)layoutSubviews {
    %orig;
    [self addObserver:self forKeyPath:@"nowPlayingArtwork" options:NSKeyValueObservingOptionNew context:nil];
    changeImage();
    dispatch_async(dispatch_get_main_queue(), ^{
        if(artworkChanged) {
            [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
            [backgroundImageView setHidden:NO];
            [backgroundImageView setClipsToBounds:YES];
            [backgroundImageView setAlpha:1];
            self.backgroundView = backgroundImageView;
            [backgroundImageView setImage:nowPlayingArtwork];
        }
    });
}
-(void)dealloc {
    [self removeObserver:self forKeyPath:@"nowPlayingArtwork"];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqual:@"nowPlayingArtwork"]) {
        artworkChanged = YES;
    } else {
        artworkChanged = NO;
    }
}
%end