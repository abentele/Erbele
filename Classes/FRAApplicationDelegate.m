/*
 Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg
 
 Current Maintainer (since 2016): 
 Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */


#import "FRAApplicationDelegate.h"
#import "FRAOpenSavePerformer.h"
#import "FRAProjectsController.h"
#import "FRACommandsController.h"
#import "FRABasicPerformer.h"
#import "FRAServicesController.h"
#import "FRAToolsMenuController.h"
#import "FRAProject.h"
#import "FRAVariousPerformer.h"

#import "ODBEditorSuite.h"

@implementation FRAApplicationDelegate
	
@synthesize persistentStoreCoordinator,  managedObjectModel, managedObjectContext, shouldCreateEmptyDocument, hasFinishedLaunching, isTerminatingApplication, filesToOpenArray, appleEventDescriptor;


static id sharedInstance = nil;

+ (FRAApplicationDelegate *)sharedInstance
{ 
	if (sharedInstance == nil) { 
		sharedInstance = [[self alloc] init];
	}
	
	return sharedInstance;
} 


- (id)init 
{
    if (sharedInstance == nil) {
        sharedInstance = [super init];	
		
		shouldCreateEmptyDocument = YES;
		hasFinishedLaunching = NO;
		isTerminatingApplication = NO;
		appleEventDescriptor = nil;
    }
	
    return sharedInstance;
}


- (NSString *)applicationSupportFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Erbele"];
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FRADataModel" ofType:@"momd"]]];
    
    return managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSString *applicationSupportFolder = nil;
    NSError *error;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if (![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil]; //options for migration from old model
    
	NSString *storePath = [applicationSupportFolder stringByAppendingPathComponent: @"Erbele3.erbele"];
	
	NSURL *url = [NSURL fileURLWithPath:storePath];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil URL:url options:options error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}

 
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
	return [[self managedObjectContext] undoManager];
}

 
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	id item;
	NSArray *array = [[FRAProjectsController sharedDocumentController] documents];
	for (item in array) {
		[item autosave];
		if ([item areAllDocumentsSaved] == NO) {
			return NSTerminateCancel;
		}
	}

	isTerminatingApplication = YES; // This is to avoid changing the document when quiting the application because otherwise it "flashes" when removing the documents
	
	[[FRACommandsController sharedInstance] clearAnyTemporaryFiles];
	
	if ([[FRADefaults valueForKey:@"OpenAllDocumentsIHadOpen"] boolValue] == YES) {

		NSMutableArray *documentsArray = [NSMutableArray array];
		NSArray *projects = [[FRAProjectsController sharedDocumentController] documents];
		for (id project in projects) {
			if ([project fileURL] == nil) {
				NSArray *documents = [[project documentsArrayController] arrangedObjects];
				for (id document in documents) {
					if ([document valueForKey:@"path"] != nil && [[document valueForKey:@"fromExternal"] boolValue] != YES) {
						[documentsArray addObject:[document valueForKey:@"path"]];
					}
				}
			}
		}
		
		[FRADefaults setValue:documentsArray forKey:@"OpenDocuments"];
	}
	
	if ([[FRADefaults valueForKey:@"OpenAllProjectsIHadOpen"] boolValue] == YES) {
		NSMutableArray *projectsArray = [NSMutableArray array];
		NSArray *array = [[FRAProjectsController sharedDocumentController] documents];
		for (id project in array) {
			if ([project fileURL] != nil) {
				[projectsArray addObject:[[project fileURL] path]];
			}
		}
		
		[FRADefaults setValue:projectsArray forKey:@"OpenProjects"];
	}
	
	array = [FRABasic fetchAll:@"Document"]; // Mark any external documents as closed
	for (item in array) {
		if ([[item valueForKey:@"fromExternal"] boolValue] == YES) {
			[FRAVarious sendClosedEventToExternalDocument:item];
		}
	}
	
	[FRABasic removeAllObjectsForEntity:@"Document"];
	[FRABasic removeAllObjectsForEntity:@"Encoding"];
	[FRABasic removeAllObjectsForEntity:@"SyntaxDefinition"];
	[FRABasic removeAllObjectsForEntity:@"Project"];
	
	NSError *error;
    NSInteger reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) { 

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } else {
                    NSAlert* alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"Quit anyway"];
                    [alert addButtonWithTitle:@"Cancel"];
                    [alert setInformativeText:@"Could not save changes while quitting. Quit anyway?"];
                    [alert setAlertStyle:NSAlertStyleWarning];
                    
                    if ([alert runModal] == NSAlertSecondButtonReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } else {
            reply = NSTerminateCancel;
        }
    }
    
	if (reply == NSTerminateCancel) {
		isTerminatingApplication = NO;
	}
	
    return reply;
}


- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	filesToOpenArray = [[NSMutableArray alloc] initWithArray:filenames];
	[filesToOpenArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	shouldCreateEmptyDocument = NO;
	
	if (hasFinishedLaunching) {
		[FRAOpenSave openAllTheseFiles:filesToOpenArray];
		filesToOpenArray = nil;
	} else if ([[[NSAppleEventManager sharedAppleEventManager] currentAppleEvent] paramDescriptorForKeyword:keyFileSender] != nil || [[[NSAppleEventManager sharedAppleEventManager] currentAppleEvent] paramDescriptorForKeyword:keyAEPropData] != nil) {
		if (appleEventDescriptor == nil) {
			appleEventDescriptor = [[NSAppleEventDescriptor alloc] initWithDescriptorType:[[[NSAppleEventManager sharedAppleEventManager] currentAppleEvent] descriptorType] data:[[[NSAppleEventManager sharedAppleEventManager] currentAppleEvent] data]];
			shouldCreateEmptyDocument = NO;
		}
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setServicesProvider:[FRAServicesController sharedInstance]];
	
	[self performSelector:@selector(markItAsTrulyFinishedWithLaunching) withObject:nil afterDelay:0.0]; // Do it this way because otherwise this is called before the values are inserted by Core Data
}


- (void)markItAsTrulyFinishedWithLaunching
{
	if (filesToOpenArray != nil && [filesToOpenArray count] > 0) {
		NSArray *openDocument = [FRABasic fetchAll:@"Document"];
		if ([openDocument count] != 0) {
			if (FRACurrentProject != nil) {
				[FRACurrentProject performCloseDocument:openDocument[0]];
			}
		}
		[FRAManagedObjectContext processPendingChanges];
		[FRAOpenSave openAllTheseFiles:filesToOpenArray];
		[FRACurrentProject selectionDidChange];
		filesToOpenArray = nil;
	} else { // Open previously opened documents/projects only if Erbele wasn't opened by e.g. dragging a document onto the icon
		
		if ([[FRADefaults valueForKey:@"OpenAllDocumentsIHadOpen"] boolValue] == YES && [[FRADefaults valueForKey:@"OpenDocuments"] count] > 0) {
			shouldCreateEmptyDocument = NO;
			NSArray *openDocument = [FRABasic fetchAll:@"Document"];
			if ([openDocument count] != 0) {
				if (FRACurrentProject != nil) {
					filesToOpenArray = [[NSMutableArray alloc] init]; // A hack so that -[FRAProject performCloseDocument:] won't close the window
					[FRACurrentProject performCloseDocument:openDocument[0]];
					filesToOpenArray = nil;
				}
			}
			[FRAManagedObjectContext processPendingChanges];
			[FRAOpenSave openAllTheseFiles:[FRADefaults valueForKey:@"OpenDocuments"]];
			[FRACurrentProject selectionDidChange];
		}
		
		if ([[FRADefaults valueForKey:@"OpenAllProjectsIHadOpen"] boolValue] == YES && [[FRADefaults valueForKey:@"OpenProjects"] count] > 0) {
			shouldCreateEmptyDocument = NO;
			[FRAOpenSave openAllTheseFiles:[FRADefaults valueForKey:@"OpenProjects"]];
		}
	}

	hasFinishedLaunching = YES;
	shouldCreateEmptyDocument = NO;

	// Do this here so that it won't slow down the perceived start-up time
	[[FRAToolsMenuController sharedInstance] buildInsertSnippetMenu];
	[[FRAToolsMenuController sharedInstance] buildRunCommandMenu];
}


- (void)changeFont:(id)sender // When you change the font in the print panel
{
    NSFont *oldFont = [NSUnarchiver unarchiveObjectWithData:[FRADefaults valueForKey:@"PrintFont"]];
    NSFont *panelFont = [sender convertFont:oldFont];
	[FRADefaults setValue:[NSArchiver archivedDataWithRootObject:panelFont] forKey:@"PrintFont"];
}


- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	if (([[FRADefaults valueForKey:@"OpenAllProjectsIHadOpen"] boolValue] == YES
        && [[FRADefaults valueForKey:@"OpenProjects"] count] > 0)
        || [[[FRAProjectsController sharedDocumentController] documents] count] > 0)
    {
		return NO;
	} else
    {
		return [[FRADefaults valueForKey:@"NewDocumentAtStartup"] boolValue];
	}
}


- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	NSMenu *returnMenu = [[NSMenu alloc] init];
	NSMenuItem *menuItem;
	id document;
	
	NSEnumerator *currentProjectEnumerator = [[[FRACurrentProject documentsArrayController] arrangedObjects] reverseObjectEnumerator];
	for (document in currentProjectEnumerator) {
		menuItem = [[NSMenuItem alloc] initWithTitle:[document valueForKey:@"name"] action:@selector(selectDocumentFromTheDock:) keyEquivalent:@""];
		[menuItem setTarget:[FRAProjectsController sharedDocumentController]];
		[menuItem setRepresentedObject:document];
		[returnMenu insertItem:menuItem atIndex:0];
	}
	
	NSArray *projects = [[FRAProjectsController sharedDocumentController] documents];
	for (id project in projects) {
		if (project == FRACurrentProject) {
			continue;
		}
		NSMenu *menu;
		if ([project valueForKey:@"name"] == nil) {
			menu = [[NSMenu alloc] initWithTitle:UNTITLED_PROJECT_NAME];
		} else {
			menu = [[NSMenu alloc] initWithTitle:[project valueForKey:@"name"]];
		}
		
		NSEnumerator *documentsEnumerator = [[[(FRAProject *)project documents] allObjects] reverseObjectEnumerator];
		for (document in documentsEnumerator) {
			menuItem = [[NSMenuItem alloc] initWithTitle:[document valueForKey:@"name"] action:@selector(selectDocumentFromTheDock:) keyEquivalent:@""];
			[menuItem setTarget:[FRAProjectsController sharedDocumentController]];
			[menuItem setRepresentedObject:document];
			[menu insertItem:menuItem atIndex:0];
		}
		
		NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:[menu title] action:nil keyEquivalent:@""];
		[subMenuItem setSubmenu:menu];
		[returnMenu addItem:subMenuItem];
	}

	return returnMenu;
}


- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	if ([[FRADefaults valueForKey:@"CheckIfDocumentHasBeenUpdated"] boolValue] == YES) { // Check for updates directly when Erbele gets focus
		[FRAVarious checkIfDocumentsHaveBeenUpdatedByAnotherApplication];
	}
}

@end
