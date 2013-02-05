//
//  ECGradientTextView.h
//  ambientweet
//
//  Created by Sam Deane on 10/04/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ECGradientTextView : NSTextView

@property (strong, nonatomic) NSGradient* gradient;
@property (assign, nonatomic) CGFloat radius;

@end
