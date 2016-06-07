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
//  PersonalInfoViewController.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/23/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import <UIKit/UIKit.h>
#import "PersonalInfoDelegate.h"


@class User;


@interface PersonalInfoViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIWebViewDelegate>
{
	id <PersonalInfoDelegate> delegate;
	NSManagedObjectContext *managedObjectContext;
	User *user;

	UITextField *age;
	UITextField *email;
	UITextField *gender;
    UITextField *ethnicity;
    UITextField *income;
	UITextField *homeZIP;
	UITextField *workZIP;
	UITextField *schoolZIP;
    UITextField *cyclingFreq;
    UITextField *riderType;
    UITextField *riderHistory;
    UIPickerView *demographicsPicker;
    
    NSArray *genderArray;
    NSArray *ageArray;
    NSArray *ethnicityArray;
    NSArray *incomeArray;
    NSArray *cyclingFreqArray;
    NSArray *rider_typeArray;
    NSArray *rider_historyArray;
    NSArray *textFieldArray;
    
    NSInteger selectedTextField;
}


@property (nonatomic, strong) id <PersonalInfoDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) UITextField	*age;
@property (nonatomic, strong) UITextField	*email;
@property (nonatomic, strong) UITextField	*gender;
@property (nonatomic, strong) UITextField   *ethnicity;
@property (nonatomic, strong) UITextField   *income;
@property (nonatomic, strong) UITextField	*homeZIP;
@property (nonatomic, strong) UITextField	*workZIP;
@property (nonatomic, strong) UITextField	*schoolZIP;

@property (nonatomic, strong) UITextField   *cyclingFreq;
@property (nonatomic, strong) UITextField   *riderType;
@property (nonatomic, strong) UITextField   *riderHistory;

@property (nonatomic) NSInteger ageSelectedRow;
@property (nonatomic) NSInteger genderSelectedRow;
@property (nonatomic) NSInteger ethnicitySelectedRow;
@property (nonatomic) NSInteger incomeSelectedRow;
@property (nonatomic) NSInteger cyclingFreqSelectedRow;
@property (nonatomic) NSInteger riderTypeSelectedRow;
@property (nonatomic) NSInteger riderHistorySelectedRow;
@property (nonatomic) NSInteger selectedItem;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;


@end
