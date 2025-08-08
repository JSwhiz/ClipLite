//
//  AppDelegate.h
//  ClipLite
//
//  Created by Дмитрий Крючков on 05.08.2025.
//

#import <Cocoa/Cocoa.h>
@class StatusController;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) StatusController *ctrl;
@end
