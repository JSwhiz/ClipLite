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

static inline NSString* CLTrim30(NSString *s) {
    if (s.length <= 30) return s;
    return [[s substringToIndex:29] stringByAppendingString:@"…"];
}

- (void)showMenu:(id)sender {
    NSMenu *menu = [NSMenu new];

    // ——— Pinned ———
    [menu addItemWithTitle:@"Pinned" action:NULL keyEquivalent:@""].enabled = NO;
    for (size_t i = 0; i < _history.get().size(); ++i) {
        if (!_history.get()[i].pinned) continue;

        NSString *raw  = [NSString stringWithUTF8String:_history.get()[i].text.c_str()];
        NSString *trim = (raw.length > 30) ? [[raw substringToIndex:29] stringByAppendingString:@"…"] : raw;

        NSMenuItem *item = [[NSMenuItem alloc]
            initWithTitle:[NSString stringWithFormat:@"📌 %@", trim]
                   action:@selector(selectClip:)
            keyEquivalent:@""];
        item.target  = self;
        item.tag     = (int)i;
        item.toolTip = raw;
        [menu addItem:item];
    }
    [menu addItem:[NSMenuItem separatorItem]];

    // ——— History ———
    [menu addItemWithTitle:@"History" action:NULL keyEquivalent:@""].enabled = NO;
    NSUInteger hot = 1;
    for (size_t i = 0; i < _history.get().size(); ++i) {
        if (_history.get()[i].pinned) continue;

        NSString *raw  = [NSString stringWithUTF8String:_history.get()[i].text.c_str()];
        NSString *trim = (raw.length > 30) ? [[raw substringToIndex:29] stringByAppendingString:@"…"] : raw;

        NSString *keyEq = (hot <= 9) ? [NSString stringWithFormat:@"%lu",(unsigned long)hot] : @"";
        NSMenuItem *item = [[NSMenuItem alloc]
            initWithTitle:trim
                   action:@selector(selectClip:)
            keyEquivalent:keyEq];
        item.target  = self;
        item.tag     = (int)i;
        item.toolTip = raw;
        item.keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagOption; // рисует ⌘⌥N справа
        [menu addItem:item];
        hot++;
    }

    [menu addItem:[NSMenuItem separatorItem]];

    // ——— Clear All ———
    NSMenuItem *clear = [[NSMenuItem alloc] initWithTitle:@"Clear All"
                                                   action:@selector(clearAll:)
                                            keyEquivalent:@""];
    clear.target = self;
    [menu addItem:clear];

    [_statusItem popUpStatusItemMenu:menu];
}

- (void)selectClip:(NSMenuItem*)mi {
    // Если зажат Option — переключаем pin/unpin вместо копирования
    NSEventModifierFlags flags = [NSEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    if (flags & NSEventModifierFlagOption) {
        [self togglePin:mi];
        return;
    }

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
    [self showMenu:nil];
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
