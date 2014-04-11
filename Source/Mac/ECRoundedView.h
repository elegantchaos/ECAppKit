// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//! A semi-transparent round-rectangular view.
// --------------------------------------------------------------------------

@interface ECRoundedView : NSView

// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic) NSGradient* gradient;
@property (assign, nonatomic) CGFloat radius;

@end
