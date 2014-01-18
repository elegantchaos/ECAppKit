//
//  ECPlaceholderView.h
//  ECAppKit
//
//  Created by Sam Deane on 17/01/2014.
//  Copyright (c) 2014 Elegant Chaos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ECPalceholderViewController<NSObject>
@optional
- (void)view:(NSView*)view willReplacePlaceholder:(NSView*)placeholder;
- (void)view:(NSView*)view didReplacePlaceholder:(NSView*)placeholder;
@end

@interface ECPlaceholderView : NSView

@property (strong, nonatomic) IBOutlet NSViewController<ECPalceholderViewController>* replacementController;

@end
