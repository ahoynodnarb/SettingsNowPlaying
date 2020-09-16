#import <MediaRemote/MediaRemote.h>
#import <QuartzCore/QuartzCore.h>
//changed backgroundimageview to static to stop memory leaks
static UIImage *nowPlayingArtwork = [[UIImage alloc]init];
static BOOL artworkChanged = YES;
static UIImageView *backgroundImageView = [[UIImageView alloc]init];
static void changeImage() {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary* dict = (__bridge NSDictionary *)information;
        if(dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
            nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
        }
    });
}
%hook UITableView
-(void)layoutSubviews {
    %orig;
    [self addObserver:self forKeyPath:@"nowPlayingArtwork" options:NSKeyValueObservingOptionNew context:nil];
    changeImage();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(artworkChanged) {
            backgroundImageView.frame = [[UIApplication sharedApplication]keyWindow].frame;
            [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
            [backgroundImageView setHidden:NO];
            [backgroundImageView setClipsToBounds:YES];
            [backgroundImageView setAlpha:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundView = backgroundImageView;
                [backgroundImageView setImage:nowPlayingArtwork];
            });
        }
    });
}
//Could be causing a memory leak
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