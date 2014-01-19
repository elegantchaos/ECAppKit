// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableItemsController.h"

@interface ECDraggableFileItemsController : ECDraggableItemsController

- (NSString*)typeOfItem:(id)item;
- (NSString*)makeFileFromItem:(id)item atDestination:(NSURL*)url;
- (BOOL)addFiles:(NSArray*)files atIndex:(NSInteger)index;
- (NSArray*)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet;

@end


