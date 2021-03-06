#include "SPRFRootListController.h"
#include <spawn.h>
@implementation SPRFRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}
-(void)openGithub {
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://github.com/PopsicleTreehouse/SettingsNowPlaying"] options:@{} completionHandler:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applyChanges)];
    self.navigationItem.rightBarButtonItem = applyButton;
}
-(void)applyChanges {
	UIAlertController *confirmation = [UIAlertController alertControllerWithTitle:@"Apply" message:@"Are you sure you want to quit settings?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) { [self killApp]; }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];

    [confirmation addAction:cancel];
    [confirmation addAction:confirm];

    [self presentViewController:confirmation animated:YES completion:nil];
}
-(void)killApp {
	pid_t pid;
	const char *argv[] = {"killall", "Preferences", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
}
@end
