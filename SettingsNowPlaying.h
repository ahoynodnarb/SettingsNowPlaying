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
@end
static UIImage *nowPlayingArtwork;
static BOOL enabled = YES;
static BOOL blur = YES;
static float intensity = 0.0f;