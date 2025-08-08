//
//  StatusController.mm
//  ClipLite
//
//  Created by Дмитрий Крючков on 05.08.2025.
//

#import "StatusController.h"
#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>
#include "ClipboardHistory.hpp"

static NSString * const kHistoryFile =
    @"~/Library/Application Support/ClipLite/history.json";

@implementation StatusController {
    ClipboardHistory _history;
    NSStatusItem    *_statusItem;
    NSTimer         *_timer;
    BOOL             _ignoreNextClipboard;
    NSString        *_lastClipboard;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    NSString *path = [kHistoryFile stringByExpandingTildeInPath];
    _history.loadFromFile(path.UTF8String);

    _statusItem = [[NSStatusBar systemStatusBar]
                    statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.button.title  = @"📋";
    _statusItem.button.target = self;
    _statusItem.button.action = @selector(showMenu:);

    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(checkClipboard)
                                            userInfo:nil
                                             repeats:YES];

    return self;
}

- (void)showMenu:(id)sender {
    NSMenu *menu = [NSMenu new];

    NSDictionary *smallGrayAttrs = @{
        NSForegroundColorAttributeName: [NSColor secondaryLabelColor],
        NSFontAttributeName: [NSFont systemFontOfSize:11]
    };

    [menu addItemWithTitle:@"Pinned" action:NULL keyEquivalent:@""].enabled = NO;
    for (size_t i = 0; i < _history.get().size(); ++i) {
        if (!_history.get()[i].pinned) continue;
        NSString *raw = [NSString stringWithUTF8String:_history.get()[i].text.c_str()];
        NSString *trimmed = raw;
        if (trimmed.length > 30) {
            trimmed = [[trimmed substringToIndex:29] stringByAppendingString:@"…"];
        }
        NSString *title = [NSString stringWithFormat:@"📌 %@", trimmed];

        NSMenuItem *clipItem = [[NSMenuItem alloc]
            initWithTitle:title
                   action:@selector(selectClip:)
            keyEquivalent:@""];
        clipItem.target  = self;
        clipItem.tag     = (int)i;
        clipItem.toolTip = raw;
        [menu addItem:clipItem];

        NSMenuItem *unpin = [[NSMenuItem alloc]
            initWithTitle:@"Unpin"
                   action:@selector(togglePin:)
            keyEquivalent:@""];
        unpin.target          = self;
        unpin.tag             = (int)i;
        unpin.attributedTitle = [[NSAttributedString alloc]
            initWithString:@"Unpin" attributes:smallGrayAttrs];
        [menu addItem:unpin];
    }
    [menu addItem:[NSMenuItem separatorItem]];

    [menu addItemWithTitle:@"History" action:NULL keyEquivalent:@""].enabled = NO;
    NSUInteger hot = 1;
    for (size_t i = 0; i < _history.get().size(); ++i) {
        if (_history.get()[i].pinned) continue;
        NSString *raw = [NSString stringWithUTF8String:_history.get()[i].text.c_str()];
        NSString *trimmed = raw;
        if (trimmed.length > 30) {
            trimmed = [[trimmed substringToIndex:29] stringByAppendingString:@"…"];
        }

        NSString *keyEq = (hot <= 9)
            ? [NSString stringWithFormat:@"%lu", (unsigned long)hot]
            : @"";

        NSMenuItem *clipItem = [[NSMenuItem alloc]
            initWithTitle:trimmed
                   action:@selector(selectClip:)
            keyEquivalent:keyEq];
        clipItem.target                   = self;
        clipItem.tag                      = (int)i;
        clipItem.toolTip                  = raw;
        clipItem.keyEquivalentModifierMask = NSEventModifierFlagCommand|
                                             NSEventModifierFlagOption;
        [menu addItem:clipItem];

        NSMenuItem *pin = [[NSMenuItem alloc]
            initWithTitle:@"Pin"
                   action:@selector(togglePin:)
            keyEquivalent:@""];
        pin.target          = self;
        pin.tag             = (int)i;
        pin.attributedTitle = [[NSAttributedString alloc]
            initWithString:@"Pin" attributes:smallGrayAttrs];
        [menu addItem:pin];

        hot++;
    }
    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *clear = [[NSMenuItem alloc]
        initWithTitle:@"Clear All"
               action:@selector(clearAll:)
        keyEquivalent:@""];
    clear.target = self;
    [menu addItem:clear];

    [_statusItem popUpStatusItemMenu:menu];
}




- (void)selectClip:(NSMenuItem*)mi {
    int idx = mi.tag;
    if ((size_t)idx >= _history.get().size()) return;
    std::string s = _history.get()[(size_t)idx].text;

    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString:[NSString stringWithUTF8String:s.c_str()]
       forType:NSPasteboardTypeString];

    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"ClipLite";
    content.body  = [NSString stringWithFormat:@"Copied: %@",
                     [NSString stringWithUTF8String:s.c_str()]];
    UNTimeIntervalNotificationTrigger *trig =
      [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    UNNotificationRequest *req =
      [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
                                           content:content
                                           trigger:trig];
    [[UNUserNotificationCenter currentNotificationCenter]
       addNotificationRequest:req withCompletionHandler:nil];

    _ignoreNextClipboard = YES;
    _lastClipboard = [NSString stringWithUTF8String:s.c_str()];
}

- (void)togglePin:(NSMenuItem*)mi {
    NSUInteger idx = (NSUInteger)mi.tag;
    if (idx < _history.get().size()) {
        if (_history.get()[idx].pinned) _history.unpin(idx);
        else                            _history.pin(idx);
        std::string path = [kHistoryFile stringByExpandingTildeInPath].UTF8String;
        _history.saveToFile(path);
    }
}

- (void)clearAll:(id)sender {
    _ignoreNextClipboard = YES;
    _history.clear();
    std::string path = [kHistoryFile stringByExpandingTildeInPath].UTF8String;
    _history.saveToFile(path);
}

- (void)checkClipboard {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSString     *txt = [pb stringForType:NSPasteboardTypeString];
    if (!txt.length) return;

    if (_ignoreNextClipboard) {
        _ignoreNextClipboard = NO;
        return;
    }
    if (_lastClipboard && [txt isEqualToString:_lastClipboard]) return;

    _history.add(txt.UTF8String);
    _lastClipboard = txt;
    std::string path = [kHistoryFile stringByExpandingTildeInPath].UTF8String;
    _history.saveToFile(path);
}

@end
