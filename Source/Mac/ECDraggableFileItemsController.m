// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDraggableFileItemsController.h"

#pragma mark - Constants

ECDefineDebugChannel(ECDraggableFileItemsControllerChannel);

@implementation ECDraggableFileItemsController

#pragma mark - Properties

// --------------------------------------------------------------------------
//! Return mask to use for remote drags.
// --------------------------------------------------------------------------

- (NSDragOperation)remoteSourceMaskToUse
{
    return [super remoteSourceMaskToUse] | NSDragOperationEvery;
}

// --------------------------------------------------------------------------
//! Return drag types that we support.
// --------------------------------------------------------------------------

- (NSArray*)typesToRegister
{
    return [[super typesToRegister] arrayByAddingObject:(NSString*)kUTTypeFileURL];
}

// --------------------------------------------------------------------------
//! Return types to write when starting a drag of some rows.
// --------------------------------------------------------------------------

- (NSArray*)typesToDragForIndexes:(NSSet *)indexes
{
    return [[super typesToDragForIndexes:indexes] arrayByAddingObject:NSFilesPromisePboardType];
}

// --------------------------------------------------------------------------
//! Write data of a particular type to a pasteboard for some rows.
// --------------------------------------------------------------------------

- (void)writeDataOfType:(NSString*)type toPasteboard:(NSPasteboard*)pasteboard forIndexes:(NSSet *)indexes
{
    if ([type isEqualToString:NSFilesPromisePboardType])
    {
        // build array of file types
        NSMutableArray* types = [NSMutableArray arrayWithCapacity:[indexes count]];
        NSArray* items = [self.contentController itemsAtIndexes:indexes];
        for (id item in items)
        {
			NSString* itemType = [self typeOfItem:item];
            if (itemType)
                [types addObject:itemType];
        }
        
        [pasteboard setPropertyList:types forType:NSFilesPromisePboardType];
        ECDebug(ECDraggableFileItemsControllerChannel, @"written types %@", types);
    }
    else
    {
        [super writeDataOfType:type toPasteboard:pasteboard forIndexes:indexes];
    }
}

// --------------------------------------------------------------------------
//! Copy/make the dropped items and return their names.
// --------------------------------------------------------------------------

- (NSArray*)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSSet *)indexes view:(NSView *)view
{
    NSMutableArray* names = [NSMutableArray arrayWithCapacity:[indexes count]];
    NSArray* items = [self.contentController itemsAtIndexes:indexes];
    for (id item in items)
    {
        NSString* name = [self makeFileFromItem:item atDestination:dropDestination];
        [names addObject:name];
    }
    
    ECDebug(ECDraggableFileItemsControllerChannel, @"returning names %@ for dropped items %@", names, items);
    return names;
}

// --------------------------------------------------------------------------
//! Perform a remote copy of files from elsewhere.
// --------------------------------------------------------------------------

- (BOOL)performRemoteCopyToIndex:(NSIndexPath*)index withPasteboard:(NSPasteboard*)pasteboard
{
    NSArray* classes = [NSArray arrayWithObject:[NSURL class]];
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
    NSArray* urls = [pasteboard readObjectsForClasses:classes options:options];
    ECDebug(ECDraggableFileItemsControllerChannel, @"received urls %@", urls);
	BOOL result = [self addFiles:urls atIndex:index];

    return result;
}

// --------------------------------------------------------------------------
//! Return the file type to return for an item.
//! Subclasses should override this.
// --------------------------------------------------------------------------

- (NSString*)typeOfItem:(id)item
{
	return @"";
}

// --------------------------------------------------------------------------
//! Make a file item and return its name.
//! Subclasses should override this.
// --------------------------------------------------------------------------

- (NSString*)makeFileFromItem:(id)item atDestination:(NSURL*)url
{
	return nil;
}

// --------------------------------------------------------------------------
//! Add files dragged in from outside the application.
//! Subclasses should override this.
// --------------------------------------------------------------------------

- (BOOL)addFiles:(NSArray*)files atIndex:(NSIndexPath*)index
{
	return YES;
}

@end

