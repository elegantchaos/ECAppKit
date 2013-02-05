// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


@interface ECLegalFilenameFormatter : NSFormatter 
{
	// --------------------------------------------------------------------------
	// Member Variables
	// --------------------------------------------------------------------------

	NSCharacterSet* mIllegalCharacters;
}

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (BOOL) illegalCharactersInString: (NSString*) string;

@end

