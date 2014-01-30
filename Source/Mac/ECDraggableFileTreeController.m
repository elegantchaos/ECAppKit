// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableFileTreeController.h"
#import "ECDraggableFileItemsController.h"

@implementation ECDraggableFileTreeController

-(ECDraggableItemsController*)makeItemsControllerForView:(NSView*)view
{
    return [ECDraggableFileItemsController itemsControllerForContentController:self view:view];
}

- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items
{
    NSArray* paths = [items valueForKey:@"indexPath"];
    NSSet* indexes = [NSSet setWithArray:paths];

    ECDraggableFileItemsController* itemsController = (ECDraggableFileItemsController*)self.itemsController;
    NSArray* result = [itemsController namesOfPromisedFilesDroppedAtDestination:dropDestination forDraggedRowsWithIndexes:indexes view:outlineView];
    return result;
}

@end
