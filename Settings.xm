#import <MediaRemote/MediaRemote.h>
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
            UIImageView *backgroundImage = [[UIImageView alloc] init];
            backgroundImage.frame = [[UIApplication sharedApplication]keyWindow].frame;
            [backgroundImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
            [backgroundImage setHidden:NO];
            [backgroundImage setClipsToBounds:YES];
            [backgroundImage setAlpha:1];
            self.backgroundView = backgroundImage;
            [backgroundImage setImage: nowPlayingArtwork];
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