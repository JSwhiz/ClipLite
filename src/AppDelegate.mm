//
//  AppDelegate.mm
//  ClipLite
//
//  Created by Дмитрий Крючков on 05.08.2025.
//

#import "AppDelegate.h"
#import "StatusController.h"

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)note {
    self.ctrl = [StatusController new]; // создаём статус-бар контроллер
}
@end

