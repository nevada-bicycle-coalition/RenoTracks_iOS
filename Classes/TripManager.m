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
//  TripManager.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "constants.h"
#import "Coord.h"
#import "SaveRequest.h"
#import "Trip.h"
#import "TripManager.h"
#import "User.h"
#import "LoadingView.h"
#import "RecordTripViewController.h"
#import "SavedTripsViewController.h"

// use this epsilon for both real-time and post-processing distance calculations
#define kEpsilonAccuracy		100.0

// use these epsilons for real-time distance calculation only
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0	// meters per sec = 67 mph

#define kSaveProtocolVersion_1	1
#define kSaveProtocolVersion_2	2
#define kSaveProtocolVersion_3	3

//#define kSaveProtocolVersion	kSaveProtocolVersion_1
//#define kSaveProtocolVersion	kSaveProtocolVersion_2
#define kSaveProtocolVersion	kSaveProtocolVersion_3

@implementation TripManager

@synthesize saving, tripNotes, tripNotesText;
@synthesize coords, dirty, trip, managedObjectContext, receivedData;
@synthesize uploadingView, parent;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if ( self = [super init] )
	{
		self.activityDelegate		= self;
		self.coords					= [[NSMutableArray alloc] initWithCapacity:1000];
		distance					= 0.0;
		self.managedObjectContext	= context;
		self.trip					= nil;
		purposeIndex				= -1;
    }
    return self;
}


- (BOOL)loadTrip:(Trip*)_trip
{
    if ( _trip )
	{
		self.trip					= _trip;
		distance					= (_trip.distance).doubleValue;
		self.managedObjectContext	= _trip.managedObjectContext;
		
		// NOTE: loading coords can be expensive for a large trip
		NSLog(@"loading %fm trip started at %@...", distance, _trip.start);

		// sort coords by recorded date DESCENDING so that the coord at index=0 is the most recent
		NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recorded"
																		ascending:NO];
		NSArray *sortDescriptors	= @[dateDescriptor];
		self.coords					= [[(_trip.coords).allObjects sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
		
		//NSLog(@"loading %d coords completed.", [self.coords count]);

		// recalculate duration
		if ( coords && coords.count > 1 )
		{
			Coord *last		= coords[0];
			Coord *first	= coords.lastObject;
			NSTimeInterval duration = [last.recorded timeIntervalSinceDate:first.recorded];
			NSLog(@"duration = %.0fs", duration);
			trip.duration = @(duration);
		}
		
		// save updated duration to CoreData
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"loadTrip error %@, %@", error, error.localizedDescription);
            
		}
        
		/*
		// recalculate trip distance
		CLLocationDistance newDist	= [self calculateTripDistance:_trip];
		
		NSLog(@"newDist: %f", newDist);
		NSLog(@"oldDist: %f", distance);
		*/
		
		// TODO: initialize purposeIndex from trip.purpose
		purposeIndex				= -1;
    }
    return YES;
}


- (instancetype)initWithTrip:(Trip*)_trip
{
    if ( self = [super init] )
	{
		self.activityDelegate = self;
		[self loadTrip:_trip];
    }
    return self;
}


- (void)createTripNotesText
{
	tripNotesText = [[UITextView alloc] initWithFrame:CGRectMake( 12.0, 50.0, 260.0, 65.0 )];
	tripNotesText.delegate = self;
	tripNotesText.enablesReturnKeyAutomatically = NO;
	tripNotesText.font = [UIFont fontWithName:@"Arial" size:16];
	tripNotesText.keyboardAppearance = UIKeyboardAppearanceAlert;
	tripNotesText.keyboardType = UIKeyboardTypeDefault;
	tripNotesText.returnKeyType = UIReturnKeyDone;
	tripNotesText.text = kTripNotesPlaceholder;
	tripNotesText.textColor = [UIColor grayColor];
}


#pragma mark UITextViewDelegate


- (void)textViewDidBeginEditing:(UITextView *)textView
{
	NSLog(@"textViewDidBeginEditing");
	
	if ( [textView.text compare:kTripNotesPlaceholder] == NSOrderedSame )
	{
		textView.text = @"";
		textView.textColor = [UIColor blackColor];
	}
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	NSLog(@"textViewShouldEndEditing: \"%@\"", textView.text);
	
	if ( [textView.text compare:@""] == NSOrderedSame )
	{
		textView.text = kTripNotesPlaceholder;
		textView.textColor = [UIColor grayColor];
	}
	
	return YES;
}


// this code makes the keyboard dismiss upon typing done / enter / return
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"])
	{
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}


- (CLLocationDistance)distanceFrom:(Coord*)prev to:(Coord*)next realTime:(BOOL)realTime
{
	CLLocation *prevLoc = [[CLLocation alloc] initWithLatitude:(prev.latitude).doubleValue
													 longitude:(prev.longitude).doubleValue];
	CLLocation *nextLoc = [[CLLocation alloc] initWithLatitude:(next.latitude).doubleValue
													 longitude:(next.longitude).doubleValue];
	
	CLLocationDistance	deltaDist	= [nextLoc distanceFromLocation:prevLoc];
	NSTimeInterval		deltaTime	= [next.recorded timeIntervalSinceDate:prev.recorded];
	CLLocationDistance	newDist		= 0.;
	
	/*
	 NSLog(@"prev.date = %@", prev.recorded);
	 NSLog(@"deltaTime = %f", deltaTime);
	 
	 NSLog(@"deltaDist = %f", deltaDist);
	 NSLog(@"est speed = %f", deltaDist / deltaTime);
	 
	 if ( [next.speed doubleValue] > 0.1 ) {
	 NSLog(@"est speed = %f", deltaDist / deltaTime);
	 NSLog(@"rec speed = %f", [next.speed doubleValue]);
	 }
	 */
	
	// sanity check accuracy
	if ( (prev.hAccuracy).doubleValue < kEpsilonAccuracy && 
		 (next.hAccuracy).doubleValue < kEpsilonAccuracy )
	{
		// sanity check time interval
		if ( !realTime || deltaTime < kEpsilonTimeInterval )
		{
			// sanity check speed
            //TODO: Re-Enable and test on a real device. Not working with simulator
//			if ( !realTime || (deltaDist / deltaTime < kEpsilonSpeed) )
//			{
				// consider distance delta as valid
				newDist += deltaDist;
				
				// only log non-zero changes
				/*
				 if ( deltaDist > 0.1 )
				 {
				 NSLog(@"new dist  = %f", newDist);
				 NSLog(@"est speed = %f", deltaDist / deltaTime);
				 }
				 */
//			}
//			else
//				NSLog(@"WARNING speed exceeds epsilon: %f => throw out deltaDist: %f, deltaTime: %f",
//					  deltaDist / deltaTime, deltaDist, deltaTime);
		}
		else
			NSLog(@"WARNING deltaTime exceeds epsilon: %f => throw out deltaDist: %f", deltaTime, deltaDist);
	}
	else
		NSLog(@"WARNING accuracy exceeds epsilon: %f => throw out deltaDist: %f", 
			  MAX([prev.hAccuracy doubleValue], [next.hAccuracy doubleValue]) , deltaDist);
	
	return newDist;
}


- (CLLocationDistance)addCoord:(CLLocation *)location
{
	NSLog(@"addCoord");
	
	if ( !trip )
		[self createTrip];	

	// Create and configure a new instance of the Coord entity
	Coord *coord = (Coord *)[NSEntityDescription insertNewObjectForEntityForName:@"Coord" inManagedObjectContext:managedObjectContext];
	
	coord.altitude = @(location.altitude);
	coord.latitude = @(location.coordinate.latitude);
	coord.longitude = @(location.coordinate.longitude);
	
	// NOTE: location.timestamp is a constant value on Simulator
	//[coord setRecorded:[NSDate date]];
	coord.recorded = location.timestamp;
	
	coord.speed = @(location.speed);
	coord.hAccuracy = @(location.horizontalAccuracy);
	coord.vAccuracy = @(location.verticalAccuracy);
	
	[trip addCoordsObject:coord];
	//[coord setTrip:trip];

	// check to see if the coords array is empty
	if ( coords.count == 0 )
	{
		NSLog(@"updated trip start time");
		// this is the first coord of a new trip => update start
		trip.start = coord.recorded;
		dirty = YES;
	}
	else
	{
		// update distance estimate by tabulating deltaDist with a low tolerance for noise
		Coord *prev  = coords[0];
		distance	+= [self distanceFrom:prev to:coord realTime:YES];
		trip.distance = @(distance);
		
		// update duration
		Coord *first	= coords.lastObject;
		NSTimeInterval duration = [coord.recorded timeIntervalSinceDate:first.recorded];
		//NSLog(@"duration = %.0fs", duration);
		trip.duration = @(duration);
		
    }
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"TripManager addCoord error %@, %@", error, error.localizedDescription);
	}

	[coords insertObject:coord atIndex:0];
	//NSLog(@"# coords = %d", [coords count]);
	
	return distance;
}


- (CLLocationDistance)getDistanceEstimate
{
	return distance;
}


- (NSDictionary*)encodeUserData
{
	NSLog(@"encodeUserData");
	NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:7];
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	//NSLog(@"saved user count  = %d", count);
	
	if ( count )
	{
		NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"TripManager fetch saved user data error %@, %@", error, error.localizedDescription);
		}
        
        NSString *appVersion = [NSString stringWithFormat:@"%@ (%@) on iOS %@",
                                [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
                                [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"],
                                [UIDevice currentDevice].systemVersion];
        
		User *user = mutableFetchResults[0];
		if ( user != nil )
		{
			// initialize text fields to saved personal info
			[userDict setValue:user.age             forKey:@"age"];
			[userDict setValue:user.email           forKey:@"email"];
			[userDict setValue:user.gender          forKey:@"gender"];
			[userDict setValue:user.homeZIP         forKey:@"homeZIP"];
			[userDict setValue:user.workZIP         forKey:@"workZIP"];
			[userDict setValue:user.schoolZIP       forKey:@"schoolZIP"];
			[userDict setValue:user.cyclingFreq     forKey:@"cyclingFreq"];
            [userDict setValue:user.ethnicity       forKey:@"ethnicity"];
            [userDict setValue:user.income          forKey:@"income"];
            [userDict setValue:user.rider_type      forKey:@"rider_type"];
            [userDict setValue:user.rider_history	forKey:@"rider_history"];
            [userDict setValue:appVersion           forKey:@"app_version"];
		}
		else
			NSLog(@"TripManager fetch user FAIL");
		
	}
	else
		NSLog(@"TripManager WARNING no saved user data to encode");
	
    return userDict;
}


- (void)saveNotes:(NSString*)notes
{
	if ( trip && notes )
		trip.notes = notes;
}


- (void)saveTrip
{
	NSLog(@"about to save trip with %lu coords...", (unsigned long)coords.count);
//	[activityDelegate updateSavingMessage:kPreparingData];
	//NSLog(@"%@", trip);

	// close out Trip record
	// NOTE: this code assumes we're saving the current recording in progress
	
	/* TODO: revise to work with following edge cases:
	 o coords unsorted
	 o break in recording => can't calc duration by comparing first & last timestamp,
	   incrementally tally delta time if < epsilon instead
	 o recalculate distance
	 */
	if ( trip && coords.count )
	{
		CLLocationDistance newDist = [self calculateTripDistance:trip];
		NSLog(@"real-time distance = %.0fm", distance);
		NSLog(@"post-processing    = %.0fm", newDist);
		
		distance = newDist;
		trip.distance = @(distance);
		
		Coord *last		= coords[0];
		Coord *first	= coords.lastObject;
		NSTimeInterval duration = [last.recorded timeIntervalSinceDate:first.recorded];
		NSLog(@"duration = %.0fs", duration);
		trip.duration = @(duration);
	}
	
	trip.saved = [NSDate date];
	
	NSError *error;
	if (![managedObjectContext save:&error])
	{
		// Handle the error.
		NSLog(@"TripManager setSaved error %@, %@", error, error.localizedDescription);
	}
	else
		NSLog(@"Saved trip: %@ (%.0fm, %.0fs)", trip.purpose, (trip.distance).doubleValue, (trip.duration).doubleValue);

	dirty = YES;
	
	// get array of coords
	NSMutableDictionary *tripDict = [NSMutableDictionary dictionaryWithCapacity:coords.count];
	NSEnumerator *enumerator = [coords objectEnumerator];
	Coord *coord;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	outputFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

#if kSaveProtocolVersion == kSaveProtocolVersion_3
    NSLog(@"saving using protocol version 3");
	
	// create a tripDict entry for each coord
	while (coord = [enumerator nextObject])
	{
		NSMutableDictionary *coordsDict = [NSMutableDictionary dictionaryWithCapacity:7];
		[coordsDict setValue:coord.altitude  forKey:@"a"];  //altitude
		[coordsDict setValue:coord.latitude  forKey:@"l"];  //latitude
		[coordsDict setValue:coord.longitude forKey:@"n"];  //longitude
		[coordsDict setValue:coord.speed     forKey:@"s"];  //speed
		[coordsDict setValue:coord.hAccuracy forKey:@"h"];  //haccuracy
		[coordsDict setValue:coord.vAccuracy forKey:@"v"];  //vaccuracy
		
		NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		[coordsDict setValue:newDateString forKey:@"r"];    //recorded timestamp
		[tripDict setValue:coordsDict forKey:newDateString];
	}
#elif kSaveProtocolVersion == kSaveProtocolVersion_2
	NSLog(@"saving using protocol version 2");
	
	// create a tripDict entry for each coord
	while (coord = [enumerator nextObject])
	{
		NSMutableDictionary *coordsDict = [NSMutableDictionary dictionaryWithCapacity:7];
		[coordsDict setValue:coord.altitude  forKey:@"alt"];
		[coordsDict setValue:coord.latitude  forKey:@"lat"];
		[coordsDict setValue:coord.longitude forKey:@"lon"];
		[coordsDict setValue:coord.speed     forKey:@"spd"];
		[coordsDict setValue:coord.hAccuracy forKey:@"hac"];
		[coordsDict setValue:coord.vAccuracy forKey:@"vac"];
		
		NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		[coordsDict setValue:newDateString forKey:@"rec"];
		[tripDict setValue:coordsDict forKey:newDateString];
	}
#else
	NSLog(@"saving using protocol version 1");
	
	// create a tripDict entry for each coord
	while (coord = [enumerator nextObject])
	{
		NSMutableDictionary *coordsDict = [NSMutableDictionary dictionaryWithCapacity:7];
		[coordsDict setValue:coord.altitude  forKey:@"altitude"];
		[coordsDict setValue:coord.latitude  forKey:@"latitude"];
		[coordsDict setValue:coord.longitude forKey:@"longitude"];
		[coordsDict setValue:coord.speed     forKey:@"speed"];
		[coordsDict setValue:coord.hAccuracy forKey:@"hAccuracy"];
		[coordsDict setValue:coord.vAccuracy forKey:@"vAccuracy"];
		
		NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		[coordsDict setValue:newDateString forKey:@"recorded"];		
		[tripDict setValue:coordsDict forKey:newDateString];
	}    
#endif
	// get trip purpose
	NSString *purpose;
	if ( trip.purpose )
		purpose = trip.purpose;
	else
		purpose = @"unknown";
	
	// get trip notes
	NSString *notes = @"";
	if ( trip.notes )
		notes = trip.notes;
	
	// get start date
	NSString *start = [outputFormatter stringFromDate:trip.start];
	NSLog(@"start: %@", start);

	// encode user data
	NSDictionary *userDict = [self encodeUserData];
    
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    // JSON encode user data
    NSData *userJsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&writeError];
    NSString *userJson = [[NSString alloc] initWithData:userJsonData encoding:NSUTF8StringEncoding];
    NSLog(@"user data %@", userJson);
    
    // JSON encode the trip data
    NSData *tripJsonData = [NSJSONSerialization dataWithJSONObject:tripDict options:0 error:&writeError];
    NSString *tripJson = [[NSString alloc] initWithData:tripJsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"trip data %@", tripJson);

        
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = @{@"coords": tripJson,
							  @"purpose": purpose,
							  @"notes": notes,
							  @"start": start,
							  @"user": userJson,
                              
							  @"version": [NSString stringWithFormat:@"%d", kSaveProtocolVersion]};
	// create save request
	SaveRequest *saveRequest = [[SaveRequest alloc] initWithPostVars:postVars with:3 image:NULL];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:saveRequest.request delegate:self];
	// create loading view to indicate trip is being uploaded
    uploadingView = [LoadingView loadingViewInView:parent.parentViewController.view messageString:kSavingTitle];

    //switch to map w/ trip view
    //TODO displayuploadedtripmap should not work like this. 
    if([parent isKindOfClass:[SavedTripsViewController class]]) {
        [(SavedTripsViewController*)parent displayUploadedTripMap];
    }
    else if ([parent isKindOfClass:[RecordTripViewController class]]) {
        [(RecordTripViewController*)parent displayUploadedTripMap];
    }
    
    //TODO: get screenshot and store.

    if ( theConnection )
     {
         receivedData=[NSMutableData data];
     }
     else
     {
         // inform the user that the download could not be made
     
     }
    
}


#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"%ld bytesWritten, %ld totalBytesWritten, %ld totalBytesExpectedToWrite",
		  (long)bytesWritten, (long)totalBytesWritten, (long)totalBytesExpectedToWrite );
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	NSLog(@"didReceiveResponse: %@", response);
	
	NSHTTPURLResponse *httpResponse = nil;
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] &&
		( httpResponse = (NSHTTPURLResponse*)response ) )
	{
		BOOL success = NO;
		NSString *title   = nil;
		NSString *message = nil;
		switch ( httpResponse.statusCode )
		{
			case 200:
			case 201:
				success = YES;
				title	= kSuccessTitle;
				message = kSaveSuccess;
				break;
			case 202:
				success = YES;
				title	= kSuccessTitle;
				message = kSaveAccepted;
				break;
			case 500:
			default:
				title = @"Internal Server Error";
				//message = [NSString stringWithFormat:@"%d", [httpResponse statusCode]];
				message = kServerError;
		}
		
		NSLog(@"%@: %@", title, message);
        
        //
        // DEBUG
        NSLog(@"+++++++DEBUG didReceiveResponse %@: %@", response.URL,((NSHTTPURLResponse*)response).allHeaderFields);
        //
        //
		
		// update trip.uploaded 
		if ( success )
		{
			trip.uploaded = [NSDate date];
			
			NSError *error;
			if (![managedObjectContext save:&error]) {
				// Handle the error.
				NSLog(@"TripManager setUploaded error %@, %@", error, error.localizedDescription);
			}
            
            [uploadingView loadingComplete:kSuccessTitle delayInterval:.7];
		} else {

            [uploadingView loadingComplete:kServerError delayInterval:1.5];
        }
        
	}
	
    // it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	
    // receivedData is declared as a method instance elsewhere
    receivedData.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
    // append the new data to the receivedData	
    // receivedData is declared as a method instance elsewhere
	[receivedData appendData:data];	
//	[activityDelegate startAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // TODO: is this really adequate...?
    [uploadingView loadingComplete:kConnectionError delayInterval:1.5];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          error.localizedDescription,
          error.userInfo[NSURLErrorFailingURLStringErrorKey]);
    

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data
    NSLog(@"+++++++DEBUG: Received %lu bytes of data", (unsigned long)receivedData.length);
	NSLog(@"%@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] );

}


- (NSInteger)getPurposeIndex
{
	NSLog(@"%ld", (long)purposeIndex);
	return purposeIndex;
}


#pragma mark TripPurposeDelegate methods


- (NSString *)getPurposeString:(NSUInteger)index
{
	return [TripPurpose getPurposeString:index];
}


- (NSString *)setPurpose:(NSUInteger)index
{
	NSString *purpose = [self getPurposeString:index];
	NSLog(@"setPurpose: %@", purpose);
	purposeIndex = index;
	
	if ( trip )
	{
		trip.purpose = purpose;
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"setPurpose error %@, %@", error, error.localizedDescription);
		}
	}
	else
		[self createTrip];

	dirty = YES;
	return purpose;
}


- (void)createTrip
{
	NSLog(@"createTrip");
	
	// Create and configure a new instance of the Trip entity
	trip = (Trip *)[NSEntityDescription insertNewObjectForEntityForName:@"Trip" 
												  inManagedObjectContext:managedObjectContext];
	trip.start = [NSDate date];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createTrip error %@, %@", error, error.localizedDescription);
	}
}

#pragma mark ActivityIndicatorDelegate methods


- (void)dismissSaving
{
	if ( saving )
		[saving dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)startAnimating {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopAnimating {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)updateBytesWritten:(NSInteger)totalBytesWritten
 totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	if ( saving )
		saving.message = [NSString stringWithFormat:@"Sent %ld of %ld bytes", (long)totalBytesWritten, (long)totalBytesExpectedToWrite];
}


- (void)updateSavingMessage:(NSString *)message
{
	if ( saving )
		saving.message = message;
}


#pragma mark methods to allow continuing a previously interrupted recording


// count trips that have not yet been saved
- (NSInteger)countUnSavedTrips
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	request.sortDescriptors = sortDescriptors;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = nil"];
	request.predicate = predicate;
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"countUnSavedTrips = %ld", (long)count);
	
	return count;
}

// count trips that have been saved but not uploaded
- (NSInteger)countUnSyncedTrips
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	request.sortDescriptors = sortDescriptors;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved != nil AND uploaded = nil"];
	request.predicate = predicate;
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"countUnSyncedTrips = %ld", (long)count);
	
	return count;
}

// count trips that have been saved but have zero distance
- (NSInteger)countZeroDistanceTrips
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	request.sortDescriptors = sortDescriptors;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"];
	request.predicate = predicate;
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"countZeroDistanceTrips = %ld", (long)count);
	
	return count;
}

- (BOOL)loadMostRecetUnSavedTrip
{
	BOOL success = NO;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	request.sortDescriptors = sortDescriptors;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = nil"];
	request.predicate = predicate;
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no UNSAVED trips");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, error.userInfo);
	}
	else if ( mutableFetchResults.count )
	{
		NSLog(@"UNSAVED trip(s) found");

		// NOTE: this will sort the trip's coords and make it ready to continue recording
		success = [self loadTrip:mutableFetchResults[0]];
	}
	
	return success;
}


// filter and sort all trip coords before calculating distance in post-processing
- (CLLocationDistance)calculateTripDistance:(Trip*)_trip
{
	NSLog(@"calculateTripDistance for trip started %@ having %lu coords", _trip.start, (unsigned long)(_trip.coords).count);
	
	CLLocationDistance newDist = 0.;

	if ( _trip != trip )
		[self loadTrip:_trip];
	
	// filter coords by hAccuracy
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
	NSArray		*filteredCoords		= [(_trip.coords).allObjects filteredArrayUsingPredicate:filterByAccuracy];
	NSLog(@"count of filtered coords = %lu", (unsigned long)filteredCoords.count);
	
	if ( filteredCoords.count )
	{
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES];
		NSArray		*sortDescriptors	= @[sortByDate];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		// step through each pair of neighboring coors and tally running distance estimate
		
		// NOTE: assumes ascending sort order by coord.recorded
		// TODO: rewrite to work with DESC order to avoid re-sorting to recalc
		for (int i=1; i < sortedCoords.count; i++)
		{
			Coord *prev	 = sortedCoords[(i - 1)];
			Coord *next	 = sortedCoords[i];
			newDist	+= [self distanceFrom:prev to:next realTime:NO];
		}
	}
	
	NSLog(@"oldDist: %f => newDist: %f", distance, newDist);	
	return newDist;
}


- (NSInteger)recalculateTripDistances
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	request.sortDescriptors = sortDescriptors;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"];
	request.predicate = predicate;
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no trips with zero distance found");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, error.userInfo);
	}
	NSUInteger count = mutableFetchResults.count;

	NSLog(@"found %lu trip(s) in need of distance recalcuation", (unsigned long)count);

	for (Trip *_trip in mutableFetchResults)
	{
		CLLocationDistance newDist = [self calculateTripDistance:_trip];
		_trip.distance = @(newDist);

		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"TripManager addCoord error %@, %@", error, error.localizedDescription);
		}
		break;
	}
	
	
	return count;
}

@end


@implementation TripPurpose

+ (NSUInteger)getPurposeIndex:(NSString*)string
{
	if ( [string isEqualToString:kTripPurposeCommuteString] )
		return kTripPurposeCommute;
	else if ( [string isEqualToString:kTripPurposeSchoolString] )
		return kTripPurposeSchool;
	else if ( [string isEqualToString:kTripPurposeWorkString] )
		return kTripPurposeWork;
	else if ( [string isEqualToString:kTripPurposeExerciseString] )
		return kTripPurposeExercise;
	else if ( [string isEqualToString:kTripPurposeSocialString] )
		return kTripPurposeSocial;
	else if ( [string isEqualToString:kTripPurposeShoppingString] )
		return kTripPurposeShopping;
    else if ( [string isEqualToString:kTripPurposeErrandString] )
		return kTripPurposeErrand;
    else if ( [string isEqualToString:kTripPurposeBikeEventString] )
		return kTripPurposeBikeEvent;
    else if ( [string isEqualToString:kTripPurposeScalleyCatString] )
		return kTripPurposeScalleyCat;
    else
//	else ( [string isEqualToString:kTripPurposeErrandString] )
		return kTripPurposeOther;
//	else
//		return kTripPurposeRecording;
}

+ (NSString *)getPurposeString:(NSUInteger)index
{
	switch (index) {
		case kTripPurposeCommute:
			return @"Commute";
			break;
		case kTripPurposeSchool:
			return @"School";
			break;
		case kTripPurposeWork:
			return @"Work-Related";
			break;
		case kTripPurposeExercise:
			return @"Exercise";
			break;
		case kTripPurposeSocial:
			return @"Social";
			break;
		case kTripPurposeShopping:
			return @"Shopping";
			break;
		case kTripPurposeErrand:
			return @"Errand";
			break;
        case kTripPurposeBikeEvent:
			return @"Bike Event";
			break;
        case kTripPurposeScalleyCat:
			return @"ScalleyCat";
			break;
		case kTripPurposeOther:
		default:
			return @"Other";
			break;
	}
}

@end

