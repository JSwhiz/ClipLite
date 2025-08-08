//
//  AppDelegate.mm
//  ClipLite
//
//  Created by Дмитрий Крючков on 05.08.2025.
//

#import "AppDelegate.h"
#import "StatusController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    __unused StatusController *ctrl = [[StatusController alloc] init];
}

@end
