#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIKit.h>
@interface SBApplication
- (NSString *)bundleIdentifier;
@end
@interface UITableView ()
- (void)setBackground;
@end
@interface SBMediaController
+ (id)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end
static UIImage *nowPlayingArtwork;
static BOOL enabled = YES;