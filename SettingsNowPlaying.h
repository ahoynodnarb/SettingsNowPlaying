#import <MediaRemote/MediaRemote.h>
#import <Foundation/NSDistributedNotificationCenter.h>
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
- (BOOL)isPlaying;
@end
BOOL checkForNull = YES;
BOOL enabled = YES;
BOOL blur = YES;
float intensity = 0.0f;
UIImage *nowPlayingArtwork;
UIImageView *backgroundImageView;