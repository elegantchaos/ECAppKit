
// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableItemsController.h"

@interface ECDraggableArrayController : NSArrayController<NSCollectionViewDelegate, ECDraggableItemContentController>
@property (strong, nonatomic) ECDraggableItemsController* itemsController;

-(ECDraggableItemsController*)makeItemsControllerForView:(NSView*)view;
- (NSSet*)indexSetAsSet:(NSIndexSet*)indexSet;

@end


