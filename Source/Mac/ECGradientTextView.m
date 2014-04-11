// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECGradientTextView.h"

@interface ECGradientTextView()

@property (assign, nonatomic) NSRect lastRect;
@property (strong, nonatomic) NSBezierPath* path;

- (void)setupDefaults;

@end

@implementation ECGradientTextView

static const CGFloat kStartAlpha = 0.8;
static const CGFloat kEndAlpha = 0.65;
static const CGFloat kDefaultRadius = 25.0;

@synthesize lastRect = _lastRect;
@synthesize path = _path;
@synthesize gradient = _gradient;
@synthesize radius = _radius;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.drawsBackground = YES;
        [self setupDefaults];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setupDefaults];
}

- (void) setupDefaults
{
	self.radius = kDefaultRadius;
	NSColor* start = [NSColor colorWithCalibratedWhite:0.0f alpha:kStartAlpha];
	NSColor* end = [start colorWithAlphaComponent:kEndAlpha];
	self.gradient = [[NSGradient alloc] initWithStartingColor:start endingColor:end];
}

- (void)drawViewBackgroundInRect:(NSRect)rect
{
    if (!NSEqualRects(self.lastRect, rect))
    {
        self.path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.radius yRadius:self.radius];
    }

    [self.gradient drawInBezierPath:self.path angle:90.0];
}

@end
