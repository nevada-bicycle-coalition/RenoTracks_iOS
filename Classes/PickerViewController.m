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
//	PickerViewController.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "CustomView.h"
#import "PickerViewController.h"
#import "DetailViewController.h"
#import "TripDetailViewController.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "RecordTripViewController.h"


@implementation PickerViewController

@synthesize customPickerView, customPickerDataSource, delegate, descriptionTextView;
@synthesize descriptionText;


// return the picker frame based on its size
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	
	// layout at bottom of page
	/*
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
									screenRect.size.height - 84.0 - size.height,
									size.width,
									size.height);
	 */
	
	// layout at top of page
	//CGRect pickerRect = CGRectMake(	0.0, 0.0, size.width, size.height );	
	
	// layout at top of page, leaving room for translucent nav bar
	//CGRect pickerRect = CGRectMake(	0.0, 43.0, size.width, size.height );
    CGRect pickerRect;
    
	if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGRect pickerRect = CGRectMake(	0.0, 98.0, size.width, size.height );
        return pickerRect;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect pickerRect = CGRectMake(	0.0, 83.0, size.width, size.height );
        return pickerRect;
    }
    return pickerRect;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)createCustomPicker
{
	customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerDataSource.parent = self;
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = CGSizeMake(320, 216);
	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	//customPickerView.hidden = YES;
	[self.view addSubview:customPickerView];
}


- (IBAction)cancel:(id)sender
//add value to be sent in
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[delegate didCancelNote];
}


- (IBAction)save:(id)sender
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        NSLog(@"Purpose Save button pressed");
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        TripDetailViewController *tripDetailViewController = [[TripDetailViewController alloc] initWithNibName:@"TripDetailViewController" bundle:nil];
        tripDetailViewController.delegate = self.delegate;
        
        [self presentViewController:tripDetailViewController animated:YES completion:nil];
        
        [delegate didPickPurpose:row];
    }
    else if (pickerCategory == 1){
        NSLog(@"Issue Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        //[self dismissModalViewControllerAnimated:YES];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentViewController:detailViewController animated:YES completion:nil];
        //Note: get index of picker
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:row forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %ld", (long)pickedNotedType);
    }
    else if (pickerCategory == 2){
        NSLog(@"Asset Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentViewController:detailViewController animated:YES completion:nil];
        //do something here: get index for later use.
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:row+6 forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %ld", (long)pickedNotedType);
        
    }
    else if (pickerCategory == 3){
        NSLog(@"Note This Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentViewController:detailViewController animated:YES completion:nil];
        
        
        //Note: get index of type
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        NSNumber *tempType = 0;

        
        if(row >= 7){
            tempType = @(row-7);
        }
        else if (row<=5){
            tempType = @(11-row);
        }
        
        NSLog(@"tempType: %d", tempType.intValue);
        
        [delegate didPickNoteType:tempType];
    }	
}


- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	NSLog(@"initWithNibNamed");
	if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		//NSLog(@"PickerViewController init");		
		[self createCustomPicker];
        
		pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        if (pickerCategory == 0) {
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        else if (pickerCategory == 3){
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:6 inComponent:0];
        }
        
		
	}
	return self;
}


- (instancetype)initWithPurpose:(NSInteger)index
{
	if (self = [self init])
	{
		//NSLog(@"PickerViewController initWithPurpose: %d", index);
		
		// update the picker
		[customPickerView selectRow:index inComponent:0 animated:YES];
		
		pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        if (pickerCategory == 0) {
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        else if (pickerCategory == 3){
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:6 inComponent:0];
        }
	}
	return self;
}


- (void)viewDidLoad
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        navBarItself.topItem.title = @"Trip Purpose";
        self.descriptionText.text = @"Please select your trip purpose & tap Save";
    }
    else if (pickerCategory == 1){
        navBarItself.topItem.title = @"Boo this...";
        self.descriptionText.text = @"Please select the issue type & tap Save";
    }
    else if (pickerCategory == 2){
        navBarItself.topItem.title = @"This is rad!";
        self.descriptionText.text = @"Please select the asset type & tap Save";
    }
    else if (pickerCategory == 3){
        navBarItself.topItem.title = @"Mark";
        self.descriptionText.text = @"Please select the type & tap Save";
        [self.customPickerView selectRow:6 inComponent:0 animated:NO];
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }

	[super viewDidLoad];
    
	

	//self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	// self.view.backgroundColor = [[UIColor alloc] initWithRed:40. green:42. blue:57. alpha:1. ];

	// Set up the buttons.
	/*
	UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
															  target:self action:@selector(done)];
	done.enabled = YES;
	self.navigationItem.rightBarButtonItem = done;
	 */
	//[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	//description = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 280.0, 284.0, 130.0 )];
	descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 314.0, 284.0, 120.0 )];
	descriptionTextView.editable = NO;
    descriptionTextView.backgroundColor = [UIColor clearColor];
    descriptionTextView.textColor = [UIColor whiteColor];
    
	descriptionTextView.font = [UIFont fontWithName:@"Arial" size:16];
	[self.view addSubview:descriptionTextView];
}


// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerCategory == 3){
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }
	//NSLog(@"parent didSelectRow: %d inComponent:%d", row, component);
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        switch (row) {
            case 0:
                descriptionTextView.text = kDescCommute;
                break;
            case 1:
                descriptionTextView.text = kDescSchool;
                break;
            case 2:
                descriptionTextView.text = kDescWork;
                break;
            case 3:
                descriptionTextView.text = kDescExercise;
                break;
            case 4:
                descriptionTextView.text = kDescSocial;
                break;
            case 5:
                descriptionTextView.text = kDescShopping;
                break;
            case 6:
                descriptionTextView.text = kDescErrand;
                break;
            case 7:
                descriptionTextView.text = kDescBikeEvent;
                break;
            case 8:
                descriptionTextView.text = kDescScalleyCat;
                break;
            default:
                descriptionTextView.text = kDescOther;
                break;
        }
    }

    else if (pickerCategory == 1){
        switch (row) {
            case 0:
                descriptionTextView.text = kIssueDescPavementIssue;
                break;
            case 1:
                descriptionTextView.text = kIssueDescTrafficSignal;
                break;
            case 2:
                descriptionTextView.text = kIssueDescEnforcement;
                break;
            case 3:
                descriptionTextView.text = kIssueDescNeedParking;
                break;
            case 4:
                descriptionTextView.text = kIssueDescBikeLaneIssue;
                break;
            default:
                descriptionTextView.text = kIssueDescNoteThisSpot;
                break;
        }
    }
    else if (pickerCategory == 2){
        switch (row) {
            case 0:
                descriptionTextView.text = kAssetDescBikeParking;
                break;
            case 1:
                descriptionTextView.text = kAssetDescBikeShops;
                break;
            case 2:
                descriptionTextView.text = kAssetDescPublicRestrooms;
                break;
            case 3:
                descriptionTextView.text = kAssetDescSecretPassage;
                break;
            case 4:
                descriptionTextView.text = kAssetDescWaterFountains;
                break;
            default:
                descriptionTextView.text = kAssetDescNoteThisSpot;
                break;
        }
    }
    else if (pickerCategory == 3){
        switch (row) {
            case 6:
                descriptionTextView.text = kDescNoteThis;
                break;
                
            case 0:
                descriptionTextView.text = kAssetDescNoteThisSpot;
                break;
            case 1:
                descriptionTextView.text = kAssetDescWaterFountains;
                break;
            case 2:
                descriptionTextView.text = kAssetDescSecretPassage;
                break;
            case 3:
                descriptionTextView.text = kAssetDescPublicRestrooms;
                break;
            case 4:
                descriptionTextView.text = kAssetDescBikeShops;
                break;
            case 5:
                descriptionTextView.text = kAssetDescBikeParking;
                break;
        
            
            
            case 7:
                descriptionTextView.text = kIssueDescPavementIssue;
                break;
            case 8:
                descriptionTextView.text = kIssueDescTrafficSignal;
                break;
            case 9:
                descriptionTextView.text = kIssueDescEnforcement;
                break;
            case 10:
                descriptionTextView.text = kIssueDescNeedParking;
                break;
            case 11:
                descriptionTextView.text = kIssueDescBikeLaneIssue;
                break;
            case 12:
                descriptionTextView.text = kIssueDescNoteThisSpot;
                break;

        }
    }
}




@end

