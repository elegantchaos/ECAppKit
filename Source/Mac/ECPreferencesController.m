// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 07/03/2010
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
//  Based on original code by Matt Gemmell.
// --------------------------------------------------------------------------

#import "ECPreferencesController.h"
#import "ECPreferencePaneProtocol.h"

@implementation ECPreferencesController

ECDefineDebugChannel(ECPreferencesChannel);

#define Last_Pane_Defaults_Key	[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@"_Preferences_Last_Pane_Defaults_Key"]

// ************************************************
// version/init/dealloc/constructors
// ************************************************


+ (id)preferencesWithPanesSearchPath:(NSString*)path bundleExtension:(NSString *)ext
{
    return [[[ECPreferencesController alloc] initWithPanesSearchPath:path bundleExtension:ext] autorelease];
}


+ (id)preferencesWithBundleExtension:(NSString *)ext
{
    return [[[ECPreferencesController alloc] initWithBundleExtension:ext] autorelease];
}


+ (id)preferencesWithPanesSearchPath:(NSString*)path
{
    return [[[ECPreferencesController alloc] initWithPanesSearchPath:path] autorelease];
}


+ (id)preferences
{
    return [[[ECPreferencesController alloc] init] autorelease];
}


- (id)init
{
    return [self initWithPanesSearchPath:nil bundleExtension:nil];
}


- (id)initWithPanesSearchPath:(NSString*)path
{
    return [self initWithPanesSearchPath:path bundleExtension:nil];
}


- (id)initWithBundleExtension:(NSString *)ext
{
    return [self initWithPanesSearchPath:nil bundleExtension:ext];
}


// Designated initializer
- (id)initWithPanesSearchPath:(NSString*)path bundleExtension:(NSString *)ext
{
    if ((self = [super init]) != nil)
	{
        preferencePanes = [[NSMutableDictionary alloc] init];
        panesOrder = [[NSMutableArray alloc] init];
        
        [self setToolbarDisplayMode:NSToolbarDisplayModeIconAndLabel];
        [self setToolbarSizeMode:NSToolbarSizeModeDefault];
        [self setUsesTexturedWindow:NO];
        [self setAlwaysShowsToolbar:NO];
        [self setAlwaysOpensCentered:YES];
        
        if (!ext || [ext isEqualToString:@""]) {
            bundleExtension = [[NSString alloc] initWithString:@"preferencePane"];
        } else {
            bundleExtension = [ext retain];
        }
        
        if (!path || [path isEqualToString:@""]) {
            searchPath = [[NSString alloc] initWithString:[[NSBundle mainBundle] resourcePath]];
        } else {
            searchPath = [path retain];
        }
        
        // Read PreferencePanes
        if (searchPath) {
			for (NSString* panePath in [NSBundle pathsForResourcesOfType:bundleExtension inDirectory:searchPath])
			{
                [self activatePane:panePath];
            }
        }
        return self;
    }
    return nil;
}


- (void)dealloc
{
	[prefsWindow release];
	[prefsToolbar release];
	[prefsToolbarItems release];
	[preferencePanes release];
	[panesOrder release];
	[bundleExtension release];
	[searchPath release];

    [super dealloc];
}


// ************************************************
// Preferences methods
// ************************************************


- (void)showPreferencesWindow
{
    [self createPreferencesWindowAndDisplay:YES];
}


- (void)createPreferencesWindow
{
    [self createPreferencesWindowAndDisplay:YES];
}


- (void)createPreferencesWindowAndDisplay:(BOOL)shouldDisplay
{
    if (prefsWindow) {
        if (self.alwaysOpensCentered && ![prefsWindow isVisible]) {
            [prefsWindow center];
        }
        [prefsWindow makeKeyAndOrderFront:nil];
        return;
    }
    
    // Create prefs window
    unsigned int styleMask = (NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask);
    if (self.usesTexturedWindow) {
        styleMask = (styleMask | NSTexturedBackgroundWindowMask);
    }
    prefsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 350, 200)
                                              styleMask:styleMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
	prefsWindow.delegate = self;
    [prefsWindow setReleasedWhenClosed:NO];
    [prefsWindow setTitle:@"Preferences"]; // initial default title
    
    [prefsWindow center];
    [self createPrefsToolbar];
	
    // Register defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (panesOrder && ([panesOrder count] > 0)) {
        NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
        [defaultValues setObject:[panesOrder objectAtIndex:0] forKey:Last_Pane_Defaults_Key];
        [defaults registerDefaults:defaultValues];
    }
    
    // Load last view
    NSString *lastViewName = [defaults objectForKey:Last_Pane_Defaults_Key];
    
    if ([panesOrder containsObject:lastViewName] && [self loadPrefsPaneNamed:lastViewName display:NO]) 
	{
        if (shouldDisplay) {
            [prefsWindow makeKeyAndOrderFront:nil];
        }
        return;
    }
	
    ECDebug(ECPreferencesChannel, @"Could not load last-used preference pane \"%@\". Trying to load another pane instead.", lastViewName);
    
    // Try to load each prefpane in turn if loading the last-viewed one fails.
		for (NSString* pane in panesOrder)
	{
        if (![pane isEqualToString:lastViewName]) {
            if ([self loadPrefsPaneNamed:pane display:NO]) {
                if (shouldDisplay) {
                    [prefsWindow makeKeyAndOrderFront:nil];
                }
                return;
            }
        }
    }
	
    ECDebug(ECPreferencesChannel, @"Could not load any valid preference panes. The preference pane bundle extension was \"%@\" and the search path was: %@", bundleExtension, searchPath);
    
    // Show alert dialog.
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSRunAlertPanel(@"Preferences",
                    [NSString stringWithFormat:@"Preferences are not available for %@.", appName],
                    @"OK",
                    nil,
                    nil);
    [prefsWindow release];
    prefsWindow = nil;
}


- (void)destroyPreferencesWindow
{
    if (prefsWindow) {
        [prefsWindow release];
    }
    prefsWindow = nil;
}


- (void)activatePane:(NSString*)path 
{
    NSBundle* paneBundle = [NSBundle bundleWithPath:path];
    if (paneBundle) {
        NSDictionary* paneDict = [paneBundle infoDictionary];
        NSString* paneName = [paneDict objectForKey:@"NSPrincipalClass"];
        if (paneName) {
            Class paneClass = NSClassFromString(paneName);
            if (!paneClass) {
                paneClass = [paneBundle principalClass];
                if ([paneClass conformsToProtocol:@protocol(ECPreferencePaneProtocol)] && [paneClass isKindOfClass:[NSObject class]]) {
                    NSArray *panes = [paneClass preferencePanes];
                    
                    for (id <ECPreferencePaneProtocol> aPane in panes)
					{
                        [panesOrder addObject:[aPane paneName]];
                        [preferencePanes setObject:aPane forKey:[aPane paneName]];
                    }
                } else {
                    ECDebug(ECPreferencesChannel, @"Did not load bundle: %@ because its Principal Class is either not an NSObject subclass, or does not conform to the PreferencePane Protocol.", paneBundle);
                }
            } else {
                ECDebug(ECPreferencesChannel, @"Did not load bundle: %@ because its Principal Class was already used in another Preference pane.", paneBundle);
            }
        } else {
            ECDebug(ECPreferencesChannel, @"Could not obtain name of Principal Class for bundle: %@", paneBundle);
        }
    } else {
        ECDebug(ECPreferencesChannel, @"Could not initialize bundle: %@", paneBundle);
    }
}


- (BOOL)loadPreferencePaneNamed:(NSString *)name
{
    return [self loadPrefsPaneNamed:(NSString *)name display:YES];
}


- (NSArray *)loadedPanes
{
    if (preferencePanes) {
        return [preferencePanes allKeys];
    }
    return nil;
}


- (BOOL)loadPrefsPaneNamed:(NSString *)name display:(BOOL)disp
{
    if (!prefsWindow) {
        NSBeep();
        ECDebug(ECPreferencesChannel, @"Could not load \"%@\" preference pane because the Preferences window seems to no longer exist.", name);
        return NO;
    }
	
    id tempPane = nil;
    tempPane = [preferencePanes objectForKey:name];
    if (!tempPane) {
        ECDebug(ECPreferencesChannel, @"Could not load preference pane \"%@\", because that pane does not exist.", name);
        return NO;
    }
    
    NSView *prefsView = nil;
    prefsView = [tempPane paneView];
    if (!prefsView) {
        ECDebug(ECPreferencesChannel, @"Could not load \"%@\" preference pane because its view could not be loaded from the bundle.", name);
        return NO;
    }
    
    // Get rid of old view before resizing, for display purposes.
    if (disp) 
	{
        NSView *tempView = [(NSView*) [NSView alloc] initWithFrame:[(NSView*)[prefsWindow contentView] frame]];
        [prefsWindow setContentView:tempView];
        [tempView release]; 
    }
    
    // Preserve upper left point of window during resize.
    NSRect newFrame = [prefsWindow frame];
    newFrame.size.height = [prefsView frame].size.height + ([prefsWindow frame].size.height - [(NSView*)[prefsWindow contentView] frame].size.height);
    newFrame.size.width = [prefsView frame].size.width;
    newFrame.origin.y += ([(NSView*)[prefsWindow contentView] frame].size.height - [prefsView frame].size.height);
    
    id <ECPreferencePaneProtocol> pane = [preferencePanes objectForKey:name];
    [prefsWindow setShowsResizeIndicator:([pane allowsHorizontalResizing] || [pane allowsHorizontalResizing])];
    
    [prefsWindow setFrame:newFrame display:disp animate:disp];
    
    [prefsWindow setContentView:prefsView];

    // Set appropriate resizing on window.
    NSSize theSize = [prefsWindow frame].size;
    theSize.height -= ToolbarHeightForWindow(prefsWindow);
    [prefsWindow setMinSize:theSize];
    
    BOOL canResize = NO;
    if ([pane allowsHorizontalResizing]) {
        theSize.width = FLT_MAX;
        canResize = YES;
    }
    if ([pane allowsVerticalResizing]) {
        theSize.height = FLT_MAX;
        canResize = YES;
    }
    [prefsWindow setMaxSize:theSize];
    [prefsWindow setShowsResizeIndicator:canResize];
	
	NSString* app = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];
    if ((prefsToolbarItems && ([prefsToolbarItems count] > 1)) || self.alwaysShowsToolbar)
	{
        [prefsWindow setTitle: [NSString stringWithFormat: @"%@ - %@", app, name]];
    }
    
    // Update defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:Last_Pane_Defaults_Key];
    
    [prefsToolbar setSelectedItemIdentifier:name];

    // Attempt to set the initial first responder.
	NSView* nextKey = [prefsView nextKeyView];
    [nextKey becomeFirstResponder];
	[prefsWindow setInitialFirstResponder: nextKey];
	
    return YES;
}


// ************************************************
// Prefs Toolbar methods
// ************************************************


float ToolbarHeightForWindow(NSWindow *window)
{
    NSToolbar *toolbar;
    float toolbarHeight = 0.0f;
    NSRect windowFrame;
    
    toolbar = [window toolbar];
    
    if(toolbar && [toolbar isVisible])
    {
        windowFrame = [NSWindow contentRectForFrameRect:[window frame]
                                              styleMask:[window styleMask]];
        toolbarHeight = (float) (NSHeight(windowFrame) - NSHeight([(NSView*)[window contentView] frame]));
    }
	
    return toolbarHeight;
}


- (void)createPrefsToolbar
{
    // Create toolbar items
    prefsToolbarItems = [[NSMutableDictionary alloc] init];
    NSImage *itemImage;
    for (NSString* name in panesOrder)
	{
        if ([preferencePanes objectForKey:name] != nil) 
		{
            NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:name];
            [item setPaletteLabel:name]; // item's label in the "Customize Toolbar" sheet (not relevant here, but we set it anyway)
            [item setLabel:name]; // item's label in the toolbar
            NSString *tempTip = [[preferencePanes objectForKey:name] paneToolTip];
            if (!tempTip || [tempTip isEqualToString:@""]) {
                [item setToolTip:nil];
            } else {
                [item setToolTip:tempTip];
            }
            itemImage = [[preferencePanes objectForKey:name] paneIcon];
            [item setImage:itemImage];
            
            [item setTarget:self];
            [item setAction:@selector(prefsToolbarItemClicked:)]; // action called when item is clicked
            [prefsToolbarItems setObject:item forKey:name]; // add to items
            [item release];
        } else {
            ECDebug(ECPreferencesChannel, @"Could not create toolbar item for preference pane \"%@\", because that pane does not exist.", name);
        }
    }
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSString* identifier = [bundleIdentifier stringByAppendingString:@"_Preferences_Toolbar_Identifier"];
    prefsToolbar = [(NSToolbar*) [NSToolbar alloc] initWithIdentifier: identifier];
    [prefsToolbar setDelegate:self];
    [prefsToolbar setAllowsUserCustomization:NO];
    [prefsToolbar setAutosavesConfiguration:NO];
    [prefsToolbar setDisplayMode:self.toolbarDisplayMode];
    [prefsToolbar setSizeMode:self.toolbarSizeMode];

    if ((prefsToolbarItems && ([prefsToolbarItems count] > 1)) || self.alwaysShowsToolbar) {
        [prefsWindow setToolbar:prefsToolbar];
    } else if (!self.alwaysShowsToolbar && prefsToolbarItems && ([prefsToolbarItems count] == 1))
	{
		ECDebug(ECPreferencesChannel, @"Not showing toolbar in Preferences window because there is only one preference pane loaded. You can override this behaviour using -[setAlwaysShowsToolbar:YES].");
    }
}



- (void)prefsToolbarItemClicked:(NSToolbarItem*)item
{
    if (![[item itemIdentifier] isEqualToString:[prefsWindow title]]) {
        [self loadPrefsPaneNamed:[item itemIdentifier] display:YES];
    }
}


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return panesOrder;
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return panesOrder;
}


- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return panesOrder;
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    return [prefsToolbarItems objectForKey:itemIdentifier];
}


// ************************************************
// Accessors
// ************************************************


- (NSWindow *)preferencesWindow
{
    return prefsWindow;
}


- (NSString *)bundleExtension
{
    return bundleExtension;
}


- (NSString *)searchPath
{
    return searchPath;
}


- (NSArray *)panesOrder
{
    return panesOrder;
}


- (void)setPanesOrder:(NSArray *)newPanesOrder
{
    [panesOrder removeAllObjects];
	
    for (NSString* name in newPanesOrder)
	{
        if ([preferencePanes objectForKey:name] != nil) 
		{
            [panesOrder addObject:name];
        }
		else
		{
            ECDebug(ECPreferencesChannel, @"Did not add preference pane \"%@\" to the toolbar ordering array, because that pane does not exist.", name);
        }
    }
}



// --------------------------------------------------------------------------
//! Close the window.
// --------------------------------------------------------------------------

- (IBAction) alternatePerformClose: (id) sender
{
	[self.preferencesWindow performClose: sender];
}

@end
