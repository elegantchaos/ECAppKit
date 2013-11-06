// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLegalFilenameFormatter.h"


@interface ECLegalFilenameFormatter()

@property (strong, nonatomic) NSCharacterSet* illegalCharacters;

@end

@implementation ECLegalFilenameFormatter

// --------------------------------------------------------------------------
//! Initialise
// --------------------------------------------------------------------------

- (id) init
{
	if ((self = [super init]) != nil)
	{
		self.illegalCharacters = [NSCharacterSet characterSetWithCharactersInString: @":"];
	}
	
	return self;
}

// --------------------------------------------------------------------------
//! Turn an input object into a string. We only accept strings as valid input.
// --------------------------------------------------------------------------

- (NSString*) stringForObjectValue:(id) anObject 
{
	NSString* result = nil;
	
    if ([anObject isKindOfClass:[NSString class]]) 
	{
        result = anObject;
    }
	
    return result;
}

// --------------------------------------------------------------------------
//! Get an output object for the string. We just return the string.
// --------------------------------------------------------------------------

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error 
{	
    *obj = string;
	return YES;
}

// --------------------------------------------------------------------------
//! Get an attributed string. We don't add any extra attributes.
// --------------------------------------------------------------------------

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes
{
	NSAttributedString* result = [[NSAttributedString alloc] initWithString: [self stringForObjectValue: anObject]];
	
	return result;
}

// --------------------------------------------------------------------------
//! Does the string contain illegal characters.
// --------------------------------------------------------------------------

- (BOOL) illegalCharactersInString: (NSString*) string
{
	return ([string rangeOfCharacterFromSet: self.illegalCharacters].length != 0);
}

// --------------------------------------------------------------------------
//! Validate the string.
//! We dissallow any characters that are illegal in filenames.
//! We also dissallow names that begin with '.'.
// --------------------------------------------------------------------------

- (BOOL) isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	BOOL startsWithDot = ([partialString length] > 0) && ([partialString characterAtIndex:0] == '.');
	BOOL ok = !startsWithDot && ![self illegalCharactersInString: partialString];
	
	if (!ok)
	{
		*error = @"Illegal character.";
	}
	
	return ok;
}

@end
