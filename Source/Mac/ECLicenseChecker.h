// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

@interface ECLicenseChecker : NSObject

- (BOOL)            isValid;
- (NSDictionary*)   info;
- (NSString*)       user;
- (NSString*)       email;
- (NSString*)       status;
- (BOOL)            importLicenseFromURL: (NSURL*) url;
- (void)            registerLicenseFile: (NSURL*) licenseURL;
- (void)            chooseLicenseFile;

@end
