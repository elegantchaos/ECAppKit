//
//  ECPlaceholderView.m
//  ECAppKit
//
//  Created by Sam Deane on 17/01/2014.
//  Copyright (c) 2014 Elegant Chaos. All rights reserved.
//

#import "ECPlaceholderView.h"

@implementation ECPlaceholderView

ECDefineDebugChannel(PlaceholderViewChannel);

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    NSView* actualView = self.replacementController.view;
    
    return actualView;
}

- (void)awakeFromNib
{
    NSView* superview = self.superview;
    NSView* replacementView = self.replacementController.view;
    NSMutableArray* constraintsToTransfer = [NSMutableArray new];
    for (NSLayoutConstraint* constraint in superview.constraints)
    {
        if ((constraint.firstItem == self) || (constraint.secondItem == self))
        {
            id firstItem = (constraint.firstItem == self) ? replacementView : constraint.firstItem;
            id secondItem = (constraint.secondItem == self) ? replacementView : constraint.secondItem;
            [constraintsToTransfer addObject:@{
                                               @"firstItem": firstItem,
                                               @"firstAttribute" : @(constraint.firstAttribute),
                                               @"relation" : @(constraint.relation),
                                               @"secondItem" : secondItem,
                                               @"secondAttribute" : @(constraint.secondAttribute),
                                               @"multiplier" : @(constraint.multiplier),
                                               @"constant" : @(constraint.constant),
                                               @"priority" : @(constraint.priority)
                                               }];
        }
    }
    
    replacementView.translatesAutoresizingMaskIntoConstraints = NO;
    replacementView.identifier = self.identifier;
    [superview replaceSubview:self with:replacementView];
    
    for (NSDictionary* info in constraintsToTransfer)
    {
        id firstItem = info[@"firstItem"];
        NSLayoutAttribute firstAttribute = [info[@"firstAttribute"] integerValue];
        NSLayoutRelation relation = [info[@"relation"] integerValue];
        id secondItem = info[@"secondItem"];
        NSLayoutAttribute secondAttribute = [info[@"secondAttribute"] integerValue];
        CGFloat multiplier = [info[@"multiplier"] doubleValue];
        CGFloat constant = [info[@"constant"] doubleValue];
        NSLayoutConstraint* newConstraint = [NSLayoutConstraint constraintWithItem:firstItem attribute:firstAttribute relatedBy:relation toItem:secondItem attribute:secondAttribute multiplier:multiplier constant:constant];
        [superview addConstraint:newConstraint];
    }
    ECDebug(PlaceholderViewChannel, @"Replaced placholder with actual view controlled by %@", self.replacementController);
}

@end
