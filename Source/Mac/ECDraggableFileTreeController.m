// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableFileTreeController.h"
#import "ECDraggableFileItemsController.h"

@implementation ECDraggableFileTreeController

-(ECDraggableItemsController*)makeItemsControllerForTableView:(NSOutlineView*)outlineView
{
    return [ECDraggableFileItemsController itemsControllerForContentController:self view:outlineView];
}

- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items
{
    ECDraggableFileItemsController* itemsController = (ECDraggableFileItemsController*)self.itemsController;
    
    NSIndexSet* indexSet = nil;
    // TODO: make indexSet out of items array
    [itemsController namesOfPromisedFilesDroppedAtDestination:dropDestination forDraggedRowsWithIndexes:indexSet];
    return nil;
}

@end
