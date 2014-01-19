// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableFileArrayController.h"
#import "ECDraggableFileItemsController.h"

@implementation ECDraggableFileArrayController

-(ECDraggableItemsController*)makeItemsControllerForTableView:(NSTableView*)tableView
{
    return [ECDraggableFileItemsController itemsControllerForContentController:self view:tableView];
}

@end

