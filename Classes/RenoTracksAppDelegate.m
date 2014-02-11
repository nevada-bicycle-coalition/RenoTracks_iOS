/** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  CycleTracksAppDelegate.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/21/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import <CommonCrypto/CommonDigest.h>


#import "RenoTracksAppDelegate.h"
#import "PersonalInfoViewController.h"
#import "RecordTripViewController.h"
#import "SavedTripsViewController.h"
#import "SavedNotesViewController.h"
#import "TripManager.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"
#import "constants.h"
#import "DetailViewController.h"
#import "NoteManager.h"
#import <CoreData/NSMappingModel.h>


@implementation RenoTracksAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize uniqueIDHash;
//@synthesize consentFor18;
@synthesize isRecording;
@synthesize locationManager;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// disable screen lock
	//[UIApplication sharedApplication].idleTimerDisabled = NO;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
 
    UITabBar *tabBar = tabBarController.tabBar;
    //set TabBarColor
    //[[UITabBar appearance] setBarTintColor:renoGreen];
    tabBarController.tabBar.translucent = false;
    
    // set color of selected icons and text to white
    //tabBar.tintColor = plainWhite;
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: plainWhite, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    // set color of unselected text to light grey
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: unSelected, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    // set selected and unselected icons
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    // set unslected icons to default color of .png
    tabBarItem1.image = [[UIImage imageNamed:@"tabbar_record.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.image = [[UIImage imageNamed:@"tabbar_view.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.image = [[UIImage imageNamed:@"tabbar_notes.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem4.image = [[UIImage imageNamed:@"tabbar_settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //set selected icons to tabBar.tintColor
//    tabBarItem1.selectedImage = [UIImage imageNamed:@"tabbar_record.png"];
//    tabBarItem2.selectedImage = [UIImage imageNamed:@"tabbar_view.png"];
//    tabBarItem3.selectedImage = [UIImage imageNamed:@"tabbar_notes.png"];
//    tabBarItem4.selectedImage = [UIImage imageNamed:@"tabbar_settings.png"];
    
    tabBarItem1.title = @"Record";
    tabBarItem2.title = @"Trips";
    tabBarItem3.title = @"Marks";
    tabBarItem4.title = @"Settings";

    
	//[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UINavigationBar appearance] setTintColor:renoGreen];
        [[UITabBar appearance] setTintColor:renoGreen];
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UINavigationBar appearance] setTintColor:plainWhite];
        //[[UITabBar appearance] setTintColor:plainWhite];
        [[UITabBar appearance] setBarTintColor:renoGreen];
        //[[UITabBar appearance] setSelectedImageTintColor:plainWhite];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:plainWhite, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabBarSelected.png"]];
        
//        UIImage *selectionIndicatorImage = [[UIImage imageNamed:@"tabBarSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
//        
//        [[UITabBar appearance] setSelectionIndicatorImage:selectionIndicatorImage];



    }

    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
	
	// init our unique ID hash
	[self initUniqueIDHash];
	
	// initialize trip manager with the managed object context
	TripManager *tripManager = [[[TripManager alloc] initWithManagedObjectContext:context] autorelease];
    NoteManager *noteManager = [[[NoteManager alloc] initWithManagedObjectContext:context] autorelease];
	
	UINavigationController	*recordNav	= (UINavigationController*)[tabBarController.viewControllers 
																	objectAtIndex:0];
	//[navCon popToRootViewControllerAnimated:NO];
	RecordTripViewController *recordVC	= (RecordTripViewController *)[recordNav topViewController];
	[recordVC initTripManager:tripManager];
    [recordVC initNoteManager:noteManager];
	
	
	UINavigationController	*tripsNav	= (UINavigationController*)[tabBarController.viewControllers 
																	objectAtIndex:1];
	//[navCon popToRootViewControllerAnimated:NO];
	SavedTripsViewController *tripsVC	= (SavedTripsViewController *)[tripsNav topViewController];
	tripsVC.delegate					= recordVC;
	[tripsVC initTripManager:tripManager];

	// select Record tab at launch
	tabBarController.selectedIndex = 0;
	
	// set delegate to prevent changing tabs when locked
	tabBarController.delegate = recordVC;
	
	// set parent view so we can apply opacity mask to it
	recordVC.parentView = tabBarController.view;
    
    UINavigationController *notesNav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:2];
    
    SavedNotesViewController *notesVC = (SavedNotesViewController *)[notesNav topViewController];
    [notesVC initNoteManager:noteManager];
	
	UINavigationController	*nav	= (UINavigationController*)[tabBarController.viewControllers 
															 objectAtIndex:3];
	PersonalInfoViewController *vc	= (PersonalInfoViewController *)[nav topViewController];
	vc.managedObjectContext			= context;

    window.rootViewController = tabBarController;
	[window makeKeyAndVisible];	
}


- (void)initUniqueIDHash
{
	//self.uniqueIDHash = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]; // save for later.
    self.uniqueIDHash = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	NSLog(@"Hashed uniqueID: %@", uniqueIDHash);
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			NSLog(@"applicationWillTerminate: Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

- (void)applicationDidEnterBackground:(UIApplication *) application
{
    RenoTracksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.isRecording){
        NSLog(@"BACKGROUNDED and recording"); //set location service to startUpdatingLocation
        [appDelegate.locationManager startUpdatingLocation];
    } else {
        NSLog(@"BACKGROUNDED and sitting idle"); //set location service to startMonitoringSignificantLocationChanges
        [appDelegate.locationManager stopUpdatingLocation];
        //[appDelegate.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *) application
{
    //always turnon location updating when active.
    RenoTracksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[appDelegate.locationManager stoptMonitoringSignificantLocationChanges];
    [appDelegate.locationManager startUpdatingLocation];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RenoTracks" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
                             //[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.window = nil;
    self.tabBarController = nil;
    self.uniqueIDHash = nil;
    self.isRecording = nil;
    self.locationManager = nil;
    
    [tabBarController release];
    [uniqueIDHash release];
    [locationManager release];
	[window release];
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[super dealloc];
}


@end

