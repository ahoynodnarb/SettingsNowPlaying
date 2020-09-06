#import <MediaRemote/MediaRemote.h>
static UIImageView *backgroundImage = [[UIImageView alloc]init];
static UIImage *nowPlayingArtwork = [[UIImage alloc]init];

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
    if(!([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)) {
        changeImage();
        UIImageView *backgroundImage = [[UIImageView alloc] init];
        backgroundImage.frame = [[UIApplication sharedApplication]keyWindow].frame;
        [backgroundImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [backgroundImage setHidden:NO];
        [backgroundImage setClipsToBounds:NO];
        [backgroundImage setAlpha:1];
        self.backgroundView = backgroundImage;
        [backgroundImage setImage: nowPlayingArtwork];
    }
}
%end

%ctor {
    changeImage();
}