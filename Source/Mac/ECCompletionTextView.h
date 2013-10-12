// --------------------------------------------------------------------------
//! @date 12/08/2011.
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

#import <AppKit/AppKit.h>

@interface ECCompletionTextView : NSTextView

@property (strong, nonatomic) NSCharacterSet* triggers;
@property (strong, nonatomic) NSArray* potentialCompletions;

@end
