// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

#import "ECMacStoreSaved.h"
#import "ECMacStoreReceipt.h"


@implementation ECMacStoreSaved

// --------------------------------------------------------------------------
//! Initialise using the default url for the receipt file.
// --------------------------------------------------------------------------

- (id) init 
{
    if ((self = [super init]) != nil) 
    {
        // do we have an exact match with a receipt saved in the application data folder?
        NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
        NSData* guid = [ECMachine machineAddress];
        if (guid)
        {
            ECMacStoreReceipt* receipt = [[ECMacStoreReceipt alloc] initWithURL: [ECMacStore savedReceiptURLForGuid:guid]];
            if ([receipt isValidForGuid:guid identifier:identifier version:version])
            {
                self.status = @"Found MAS Receipt";
                self.receipt = receipt;
            }
        }
    }
    
    return self;
}

@end
