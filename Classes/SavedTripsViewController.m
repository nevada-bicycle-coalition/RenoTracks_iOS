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
//  SavedTripsViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "constants.h"
#import "Coord.h"
#import "LoadingView.h"
#import "MapViewController.h"
#import "PickerViewController.h"
#import "SavedTripsViewController.h"
#import "Trip.h"
#import "TripManager.h"
#import "TripPurposeDelegate.h"


#define kAccessoryViewX	282.0
#define kAccessoryViewY 24.0

#define kCellReuseIdentifierCheck		@"CheckMark"
#define kCellReuseIdentifierExclamation @"Exclamataion"
#define kCellReuseIdentifierInProgress	@"InProgress"

#define kRowHeight	75
#define kTagTitle	1
#define kTagDetail	2
#define kTagImage	3

#define PURPOSELABEL_TAG 1
#define DURATIONLABEL_TAG 2
#define TIMETEXT_TAG 3
#define CO2TEXT_TAG 4
#define CALORYTEXT_TAG 5
#define PURPOSEICON_TAG 6
#define errorLabel_TAG 7



@interface TripCell : UITableViewCell
{	
}

- (void)setTitle:(NSString *)title;
- (void)setDetail:(NSString *)detail;
- (void)setDirty;

@end

@implementation TripCell

- (void)setTitle:(NSString *)title
{
	self.textLabel.text = title;
	[self setNeedsDisplay];
}

- (void)setDetail:(NSString *)detail
{
	self.detailTextLabel.text = detail;
	[self setNeedsDisplay];
}

- (void)setDirty
{
	[self setNeedsDisplay];
}

@end


@implementation SavedTripsViewController

@synthesize delegate, managedObjectContext;
@synthesize trips, tripManager, selectedTrip;


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    
    if (self = [super init]) {
		self.managedObjectContext = context;

		// Set the title NOTE: important for tab bar tab item to set title here before view loads
		self.title = @"View Saved Trips";
    }
    return self;
}

- (void)initTripManager:(TripManager*)manager
{
	self.tripManager = manager;
}

- (id)initWithTripManager:(TripManager*)manager
{
    
    if (self = [super init]) {
		//NSLog(@"SavedTripsViewController::initWithTripManager");
		self.tripManager = manager;
		
		// Set the title NOTE: important for tab bar tab item to set title here before view loads
		self.title = @"View Saved Trips";
    }
    return self;
}

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */


- (void)refreshTableView
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:tripManager.managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSError *error;
	NSInteger count = [tripManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %d", count);
	
	NSMutableArray *mutableFetchResults = [[tripManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved trips");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, [error userInfo]);
	}
	
	[self setTrips:mutableFetchResults];
	[self.tableView reloadData];

	[mutableFetchResults release];
	[request release];
}


- (void)viewDidLoad
{
    // load trips from CoreData
	[self refreshTableView];
    
    [super viewDidLoad];
	self.tableView.rowHeight = kRowHeight;

	// Set up the buttons.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:renoGreen];

	
	// check for countZeroDistanceTrips
	if ( [tripManager countZeroDistanceTrips] )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kZeroDistanceTitle
														message:kZeroDistanceMessage
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Recalculate", nil];
		alert.tag = 202;
		[alert show];
		[alert release];
	}
	
	// check for countUnSyncedTrips
	else if ( [tripManager countUnSyncedTrips] )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kUnsyncedTitle
														message:kUnsyncedMessage
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		alert.tag = 303;
		[alert show];
		[alert release];
	}
	else
		NSLog(@"no zero distance or unsynced trips found");
	
	// no trip selection by default
	selectedTrip = nil;
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"SavedTripsViewController viewWillAppear");

	// update conditionally as needed
	[self refreshTableView];
    
	if ( tripManager.dirty )
	{
		NSLog(@"dirty => refresh");
		[self refreshTableView];
		tripManager.dirty = NO;
	}
    
	[super viewWillAppear:animated];

}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */

 - (void)viewDidDisappear:(BOOL)animated
{
    [self refreshTableView];
	[super viewDidDisappear:animated];

}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)_recalculateDistanceForSelectedTripMap
{
	// important if we call from a background thread
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool
	
	// instantiate a temporary TripManager to recalcuate distance
	TripManager *mapTripManager = [[TripManager alloc] initWithTrip:selectedTrip];
	CLLocationDistance newDist	= [mapTripManager calculateTripDistance:selectedTrip];
	
	// save updated distance to CoreData
	[mapTripManager.trip setDistance:[NSNumber numberWithDouble:newDist]];

	NSError *error;
	if (![mapTripManager.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"_recalculateDistanceForSelectedTripMap error %@, %@", error, [error localizedDescription]);
	}
	
	[mapTripManager release];
	tripManager.dirty = YES;
	
	[self performSelectorOnMainThread:@selector(_displaySelectedTripMap) withObject:nil waitUntilDone:NO];
    [pool release];  // Release the objects in the pool.
}


- (void)_displaySelectedTripMap
{
	// important if we call from a background thread
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool

	if ( selectedTrip )
	{
		MapViewController *mvc = [[MapViewController alloc] initWithTrip:selectedTrip];
		[[self navigationController] pushViewController:mvc animated:YES];
		[mvc release];
		selectedTrip = nil;
	}

    [pool release];  // Release the objects in the pool.
}


// display map view
- (void)displaySelectedTripMap
{
	loading		= [[LoadingView loadingViewInView:self.parentViewController.view messageString:@"Loading..."] retain];
	loading.tag = 909;
	[self performSelectorInBackground:@selector(_recalculateDistanceForSelectedTripMap) withObject:nil];
    
}


#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [trips count];
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

- (TripCell *)getCellWithReuseIdentifier:(NSString *)reuseIdentifier
{
	TripCell *cell = (TripCell*)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

	if (cell == nil)
	{
		cell = [[[TripCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
        
		cell.detailTextLabel.numberOfLines = 2;
        if ([reuseIdentifier isEqual: kCellReuseIdentifierCheck])
        {
        
        }
		else if ( [reuseIdentifier isEqual: kCellReuseIdentifierExclamation] )
		{
			// add exclamation point
			UIImage		*image		= [UIImage imageNamed:@"failedUpload.png"];
			UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
			imageView.frame = CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
			imageView.tag	= kTagImage;
			cell.accessoryView = imageView;
		}
        else if ( [reuseIdentifier isEqual: kCellReuseIdentifierInProgress] )
		{
			// prevent user from selecting the current recording in progress
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			// reuse existing indicator if available
			UIActivityIndicatorView *inProgressIndicator = (UIActivityIndicatorView *)[cell viewWithTag:kTagImage];
			if ( !inProgressIndicator )
			{
				// create activity indicator if needed
				CGRect frame = CGRectMake( kAccessoryViewX - 10.0, kAccessoryViewY + 4.0, kActivityIndicatorSize, kActivityIndicatorSize );
				inProgressIndicator = [[[UIActivityIndicatorView alloc] initWithFrame:frame] autorelease];
				inProgressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
				[inProgressIndicator sizeToFit];
				[inProgressIndicator startAnimating];
				inProgressIndicator.tag	= kTagImage;
				[cell.contentView addSubview:inProgressIndicator];
			}
		}
	}
	else
		[[cell.contentView viewWithTag:kTagImage] setNeedsDisplay];

	// slide accessory view out of the way during editing
	cell.editingAccessoryView = cell.accessoryView;

	return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tripsCell";
    
    UILabel *timeText, *purposeText, *durationText, *CO2Text, *CaloryText, *errorLabel;
    UIImage *image;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // A date formatter for timestamp
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    static NSDateFormatter *timeFormatter = nil;
    if (timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    Trip *trip = (Trip *)[trips objectAtIndex:indexPath.row];
    
    // check for recordingInProgress
	Trip *recordingInProgress = [delegate getRecordingInProgress];
    
    
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        purposeText = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, 120, 30)];
        purposeText.tag = PURPOSELABEL_TAG;
        [purposeText setFont:[UIFont boldSystemFontOfSize:18]];
        [purposeText setTextColor:[UIColor blackColor]];
        [cell.contentView addSubview:purposeText];
    
        durationText = [[UILabel alloc] initWithFrame:CGRectMake(140, 24, 190, 30)];
        durationText.tag = DURATIONLABEL_TAG;
        [durationText setFont:[UIFont systemFontOfSize:18]];
        [durationText setTextColor:[UIColor blackColor]];
        [cell.contentView addSubview:durationText];
    
        timeText = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 220, 25)];
        timeText.tag = TIMETEXT_TAG;
        [timeText setFont:[UIFont systemFontOfSize:15]];
        [timeText setTextColor:[UIColor grayColor]];
        [cell.contentView addSubview:timeText];
    
        CO2Text = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 190, 20)];
        CO2Text.tag = CO2TEXT_TAG;
        [CO2Text setFont:[UIFont systemFontOfSize:12]];
        [CO2Text setTextColor:[UIColor grayColor]];
        [cell.contentView addSubview:CO2Text];
    
        CaloryText = [[UILabel alloc] initWithFrame:CGRectMake(140, 50, 190, 20)];
        CaloryText.tag = CALORYTEXT_TAG;
        [CaloryText setFont:[UIFont systemFontOfSize:12]];
        [CaloryText setTextColor:[UIColor grayColor]];
        [cell.contentView addSubview:CaloryText];
        
        errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, 300, 30)];
        errorLabel.tag = errorLabel_TAG;
        [errorLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [errorLabel setTextColor:[UIColor blackColor]];
        [cell.contentView addSubview:errorLabel];

    } else {
    
        purposeText = (UILabel *)[cell.contentView viewWithTag:PURPOSELABEL_TAG];
        durationText = (UILabel *)[cell.contentView viewWithTag:DURATIONLABEL_TAG];
        timeText = (UILabel *)[cell.contentView viewWithTag:TIMETEXT_TAG];
        CO2Text = (UILabel *)[cell.contentView viewWithTag:CO2TEXT_TAG];
        CaloryText = (UILabel *)[cell.contentView viewWithTag:CALORYTEXT_TAG];
        
        errorLabel = (UILabel *)[cell.contentView viewWithTag:errorLabel_TAG];
    }

    // completed
    if ( trip.uploaded )
    {
        
        int index = [TripPurpose getPurposeIndex:trip.purpose];
        NSLog(@"trip.purpose: %d => %@", index, trip.purpose);
        
        // add purpose icon
        switch ( index ) {
            case kTripPurposeCommute:
                image = [UIImage imageNamed:kTripPurposeCommuteIcon];
                break;
            case kTripPurposeSchool:
                image = [UIImage imageNamed:kTripPurposeSchoolIcon];
                break;
            case kTripPurposeWork:
                image = [UIImage imageNamed:kTripPurposeWorkIcon];
                break;
            case kTripPurposeExercise:
                image = [UIImage imageNamed:kTripPurposeExerciseIcon];
                break;
            case kTripPurposeSocial:
                image = [UIImage imageNamed:kTripPurposeSocialIcon];
                break;
            case kTripPurposeShopping:
                image = [UIImage imageNamed:kTripPurposeShoppingIcon];
                break;
            case kTripPurposeErrand:
                image = [UIImage imageNamed:kTripPurposeErrandIcon];
                break;
            case kTripPurposeOther:
                image = [UIImage imageNamed:kTripPurposeOtherIcon];
                break;
            default:
                image = [UIImage imageNamed:@"GreenCheckMark2.png"];
        }
        UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.frame			= CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
        imageView.tag = PURPOSEICON_TAG;
        cell.accessoryView = imageView;
        
        purposeText.text = [NSString stringWithFormat:@"%@", trip.purpose];
        
    }
    
    // saved but not yet uploaded
    else if ( trip.saved )
    {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        //cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierExclamation];
        
        // add exclamation point
        UIImage		*image		= [UIImage imageNamed:@"failedUpload.png"];
        UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.frame = CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
        imageView.tag	= kTagImage;
        cell.accessoryView = imageView;
        
        purposeText.text = [NSString stringWithFormat:@"%@", trip.purpose];
        
//        [cell.contentView addSubview:purposeText];
//        [cell.contentView addSubview:durationText];
//        [cell.contentView addSubview:timeText];
//        [cell.contentView addSubview:CO2Text];
//        [cell.contentView addSubview:CaloryText];
        
    }
    
    // recording for this trip is still in progress (or just completed)
    // NOTE: this test may break when attempting re-upload
    else if ( trip == recordingInProgress )
    {
        
        
        int index = [TripPurpose getPurposeIndex:trip.purpose];
        NSLog(@"trip.purpose: %d => %@", index, trip.purpose);
        
        // add purpose icon
        image = [UIImage imageNamed:kTripPurposeOtherRedIcon];

        UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.frame			= CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
        imageView.tag = PURPOSEICON_TAG;
        cell.accessoryView = imageView;

        purposeText.text = [NSString stringWithFormat:@"Recording..."];
        
    }
    
    // this trip was orphaned (an abandoned previous recording)
    else
    {
        //cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierExclamation];
        
        // Delete the managed object at the given index path.
        NSManagedObject *tripToDelete = [trips objectAtIndex:indexPath.row];
        [tripManager.managedObjectContext deleteObject:tripToDelete];
		
        // Update the array and table view.
        [trips removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
		
        // Commit the change.
        NSError *error;
        if (![tripManager.managedObjectContext save:&error]) {
            // Handle the error.
			NSLog(@"Unresolved error %@", [error localizedDescription]);
        }
        
        //[self refreshTableView];
    }
    
    // display duration, distance as navbar prompt
	static NSDateFormatter *inputFormatter = nil;
	if ( inputFormatter == nil ){
		inputFormatter = [[NSDateFormatter alloc] init];
    }
	
	[inputFormatter setDateFormat:@"HH:mm:ss"];
	NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
	[inputFormatter setDateFormat:@"HH:mm:ss"];
	NSLog(@"trip duration: %f", [trip.duration doubleValue]);
	NSDate *outputDate = [[[NSDate alloc] initWithTimeInterval:(NSTimeInterval)[trip.duration doubleValue] sinceDate:fauxDate] autorelease];
    
    //Add text to cell
    
    //purposeText.text = [NSString stringWithFormat:@"%@", trip.purpose];
    durationText.text = [NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:outputDate]];
    timeText.text = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:[trip start]], [timeFormatter stringFromDate:[trip start]]];
    
    //CO2 text
    CO2Text.text = [NSString stringWithFormat:@"CO2 Saved: %.1f lbs", 0.93 * [trip.distance doubleValue] / 1609.344];
    
    //Calory text
    double calory = 49 * [trip.distance doubleValue] / 1609.344 - 1.69;
    if (calory <= 0) {
        CaloryText.text = [NSString stringWithFormat:@"Calories Burned: 0 kcal"];
    }
    else
        CaloryText.text = [NSString stringWithFormat:@"Calories Burned: %.1f kcal", calory];
    
    return cell;
}


/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"willDisplayCell: %@", cell);
}
*/

- (void)promptToConfirmPurpose
{
	NSLog(@"promptToConfirmPurpose");
	
	NSString *confirm = [NSString stringWithFormat:@"This trip has not yet been uploaded. Try now?"];
	
	// present action sheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Upload", nil];
	
	actionSheet.actionSheetStyle	= UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	// identify trip by row
	//NSLog(@"didSelectRow: %d", indexPath.row);
	selectedTrip = (Trip *)[trips objectAtIndex:indexPath.row];
	//NSLog(@"%@", selectedTrip);

	// check for recordingInProgress
	Trip *recordingInProgress = [delegate getRecordingInProgress];

	// if trip not yet uploaded => prompt to re-upload
	if ( recordingInProgress != selectedTrip )
	{
		if ( !selectedTrip.uploaded )
		{
			// init new TripManager instance with selected trip
			// release previously set tripManager
			if ( tripManager )
				[tripManager release];
			
			tripManager = [[TripManager alloc] initWithTrip:selectedTrip];
			//tripManager.activityDelegate = self;
			tripManager.alertDelegate = self;
			tripManager.parent = self;
			// prompt to upload
			[self promptToConfirmPurpose];
		}
		
		// else => goto map view
		else 
			[self displaySelectedTripMap];
	}
	//else disallow selection of recordingInProgress
}


// Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	return ( ![cell.reuseIdentifier isEqual: kCellReuseIdentifierInProgress] );
}

- (void)displayUploadedTripMap
{
    Trip *trip = tripManager.trip;
    
    // load map view of saved trip
    MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
    [[self navigationController] pushViewController:mvc animated:YES];
    [mvc release];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSLog(@"Delete");
		
        // Delete the managed object at the given index path.
        NSManagedObject *tripToDelete = [trips objectAtIndex:indexPath.row];
        [tripManager.managedObjectContext deleteObject:tripToDelete];
		
        // Update the array and table view.
        [trips removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
        // Commit the change.
        NSError *error;
        if (![tripManager.managedObjectContext save:&error]) {
            // Handle the error.
			NSLog(@"Unresolved error %@", [error localizedDescription]);
        }
    }
	else if ( editingStyle == UITableViewCellEditingStyleInsert )
		NSLog(@"INSERT");
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark UINavigationController


- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"View Saved Trips";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Back";
		self.tabBarItem.title = @"View Saved Trips"; // important to maintain the same tab item title
	}
}


#pragma mark UIActionSheet delegate methods


// NOTE: implement didDismissWithButtonIndex to process after sheet has been dismissed
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet clickedButtonAtIndex %d", buttonIndex);
    
	switch ( buttonIndex )
	{
			
		case kActionSheetButtonDiscard:
			NSLog(@"Discard");
			
			// Delete the selectedTrip
			//NSManagedObject *tripToDelete = [trips objectAtIndex:indexPath.row];
			[tripManager.managedObjectContext deleteObject:selectedTrip];
			
			// Update the array and table view.
			//[trips removeObjectAtIndex:indexPath.row];
			NSUInteger index = [trips indexOfObject:selectedTrip];
			[trips removeObjectAtIndex:index];
			selectedTrip = nil;
			
			
			//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
			//[self.tableView reloadData];
			
			// Commit the change.
			NSError *error;
			if (![tripManager.managedObjectContext save:&error]) {
				// Handle the error.
				NSLog(@"Unresolved error %@", [error localizedDescription]);
			}
			break;
			
			/*
		case kActionSheetButtonConfirm:
			NSLog(@"Confirm => creating Trip Notes dialog");
			[tripManager promptForTripNotes];
			break;
			*/
		//case kActionSheetButtonChange:
		case 0:
			NSLog(@"Upload => push Trip Purpose picker");
			/*
			// NOTE: this code to get purposeIndex fails for the load a saved trip case
			PickerViewController *pickerViewController = [[PickerViewController alloc]
														  initWithPurpose:[tripManager getPurposeIndex]];
			[pickerViewController setDelegate:self];
			[[self navigationController] pushViewController:pickerViewController animated:YES];
			[pickerViewController release];
			*/
			
			// Trip Purpose
//			NSLog(@"INIT + PUSH");
//			PickerViewController *pickerViewController = [[PickerViewController alloc]
//														  initWithNibName:@"TripPurposePicker" bundle:nil];
//			[pickerViewController setDelegate:self];
//			//[[self navigationController] pushViewController:pickerViewController animated:YES];
//			[self.navigationController presentModalViewController:pickerViewController animated:YES];
//			[pickerViewController release];
            [tripManager saveTrip];
			break;
			
		//case kActionSheetButtonCancel:
		case 1:
		default:
			NSLog(@"Cancel");
			[self displaySelectedTripMap];
			break;
	}
}


// called if the system cancels the action sheet (e.g. homescreen button has been pressed)
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
}


#pragma mark UIAlertViewDelegate methods


// NOTE: method called upon closing save error / success alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case 202:
		{
			NSLog(@"zeroDistance didDismissWithButtonIndex: %d", buttonIndex);
			switch (buttonIndex) {
				case 0:
					// nothing to do
					break;
				case 1:
				default:
					// Recalculate
					[tripManager recalculateTripDistances];
					break;
			}
		}
			break;
		case 303:
		{
			NSLog(@"unSyncedTrips didDismissWithButtonIndex: %d", buttonIndex);
			switch (buttonIndex) {
				case 0:
					// Nevermind
					[self displaySelectedTripMap];
					break;
				case 1:
				default:
					// Upload Now
					break;
			}
		}
			break;
		default:
		{
			NSLog(@"SavedTripsView alertView: didDismissWithButtonIndex: %d", buttonIndex);
			[self displaySelectedTripMap];
		}
	}
}


#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	return [tripManager setPurpose:index];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [tripManager getPurposeString:index];
}


- (void)didCancelPurpose
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didPickPurpose:(unsigned int)index
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	[tripManager setPurpose:index];
	//[tripManager promptForTripNotes];
}

- (void)dealloc {
    self.trips = nil;
    self.managedObjectContext = nil;
    self.delegate = nil;
    self.tripManager = nil;
    self.selectedTrip = nil;
    
    [delegate release];
    [trips release];
    [tripManager release];
    [selectedTrip release];
    [loading release];
    
    [super dealloc];
}


@end

