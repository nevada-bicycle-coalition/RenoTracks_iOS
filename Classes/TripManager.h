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
//  TripManager.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "ActivityIndicatorDelegate.h"
#import "TripPurposeDelegate.h"
#import "LoadingView.h"

@class Trip;


@interface TripManager : NSObject
<ActivityIndicatorDelegate, 
TripPurposeDelegate, 
UIAlertViewDelegate, 
UITextViewDelegate>
{
	UIAlertView *saving;
	UIAlertView *tripNotes;
	UITextView	*tripNotesText;
//    id <ActivityIndicatorDelegate> activityDelegate;
//    id <UIAlertViewDelegate> alertDelegate;
//    UIActivityIndicatorView *activityIndicator;

	BOOL dirty;
	Trip *trip;
	CLLocationDistance distance;
	NSInteger purposeIndex;
	
	NSMutableArray *coords;
    NSManagedObjectContext *managedObjectContext;

	NSMutableData *receivedData;
	
	NSMutableArray *unSavedTrips;
	NSMutableArray *unSyncedTrips;
	NSMutableArray *zeroDistanceTrips;
}

@property (nonatomic, strong) id <ActivityIndicatorDelegate> activityDelegate;
@property (nonatomic, strong) id <UIAlertViewDelegate> alertDelegate;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) LoadingView *uploadingView;

@property (nonatomic, strong) UIViewController *parent; 

@property (nonatomic, strong) UIAlertView *saving;
@property (nonatomic, strong) UIAlertView *tripNotes;
@property (nonatomic, strong) UITextView *tripNotesText;

@property (assign) BOOL dirty;
@property (nonatomic, strong) Trip *trip;

@property (nonatomic, strong) NSMutableArray *coords;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableData *receivedData;


- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (instancetype)initWithTrip:(Trip*)trip;
- (BOOL)loadTrip:(Trip*)trip;

- (void)createTrip;

- (CLLocationDistance)addCoord:(CLLocation*)location;
- (void)saveNotes:(NSString*)notes;
- (void)saveTrip;

@property (nonatomic, getter=getDistanceEstimate, readonly) CLLocationDistance distanceEstimate;

@property (nonatomic, getter=getPurposeIndex, readonly) NSInteger purposeIndex;

//- (void)promptForTripNotes;

@property (nonatomic, readonly) NSInteger countUnSavedTrips;
@property (nonatomic, readonly) NSInteger countUnSyncedTrips;
@property (nonatomic, readonly) NSInteger countZeroDistanceTrips;

@property (nonatomic, readonly) BOOL loadMostRecetUnSavedTrip;
@property (nonatomic, readonly) NSInteger recalculateTripDistances;
- (CLLocationDistance)calculateTripDistance:(Trip*)_trip;

@end


@interface TripPurpose : NSObject { }

+ (NSUInteger)getPurposeIndex:(NSString*)string;
+ (NSString *)getPurposeString:(NSUInteger)index;

@end


