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
//  PersonalInfoViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/23/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "PersonalInfoViewController.h"
#import "User.h"
#import "constants.h"

#define kMaxCyclingFreq 3

@implementation PersonalInfoViewController

@synthesize delegate, managedObjectContext, user;
@synthesize age, email, gender, ethnicity, income, homeZIP, workZIP, schoolZIP;
@synthesize cyclingFreq, riderType, riderHistory;

UITapGestureRecognizer *tapToSelect;

- (instancetype)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (instancetype)init
{
	NSLog(@"INIT");
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		NSLog(@"PersonalInfoViewController::initWithManagedObjectContext");
		self.managedObjectContext = context;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (UITextField*)createTextFieldAlpha
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}

- (UITextField*)createTextFieldBeta
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}


- (UITextField*)createTextFieldEmail
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone,
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"name@domain";
	textField.keyboardType = UIKeyboardTypeEmailAddress;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (UITextField*)createTextFieldNumeric
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"12345";
	textField.keyboardType = UIKeyboardTypeNumberPad;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (User *)createUser
{
	// Create and configure a new instance of the User entity
	User *noob = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createUser error %@, %@", error, error.localizedDescription);
	}
	
	return noob;
}

//currently this is tied to the textFieldArray
typedef NS_ENUM(NSInteger, textFieldTags) {
    ageTag,
    emailTag,
    genderTag,
    ethnicityTag,
    incomeTag,
    homeZIPTag,
    workZIPTag,
    schoolZIPTag,
    cyclingFreqTag,
    riderTypeTag,
    riderHistoryTag
    
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tapToSelect = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(tapAway:)];
    tapToSelect.delegate = self;
    
    textFieldArray = @[@"age",@"email",@"gender",@"ethnicity",@"income",@"homeZIP",@"workZIP",@"schoolZIP",@"cyclingFreq",@"rider_type",@"rider_history"];
    
    genderArray = @[@" ", @"Female",@"Male"];
    
    ageArray = @[@" ", @"Less than 18", @"18-24", @"25-34", @"35-44", @"45-54", @"55-64", @"65+"];
    
    ethnicityArray = @[@" ", @"White", @"African American", @"Asian", @"Native American", @"Pacific Islander", @"Multi-racial", @"Hispanic / Mexican / Latino", @"Other"];
    
    incomeArray = @[@" ", @"Less than $20,000", @"$20,000 to $39,999", @"$40,000 to $59,999", @"$60,000 to $74,999", @"$75,000 to $99,999", @"$100,000 or greater"];
    
    cyclingFreqArray = @[@" ", @"Less than once a month", @"Several times per month", @"Several times per week", @"Daily"];
    
    rider_typeArray = @[@" ", @"Strong & fearless", @"Enthused & confident", @"Comfortable, but cautious", @"Interested, but concerned"];
    
    rider_historyArray = @[@" ", @"Since childhood", @"Several years", @"One year or less", @"Just trying it out / just started"];
    
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    demographicsPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    demographicsPicker.showsSelectionIndicator = YES;
    demographicsPicker.dataSource = self;
    demographicsPicker.delegate = self;
    
    
	// initialize text fields
	self.age		= [self createTextFieldAlpha];
	self.email		= [self createTextFieldEmail];
	self.gender		= [self createTextFieldAlpha];
    self.ethnicity  = [self createTextFieldAlpha];
    self.income     = [self createTextFieldAlpha];
	self.homeZIP	= [self createTextFieldNumeric];
	self.workZIP	= [self createTextFieldNumeric];
	self.schoolZIP	= [self createTextFieldNumeric];
    self.cyclingFreq = [self createTextFieldBeta];
    self.riderType  =  [self createTextFieldBeta];
    self.riderHistory =[self createTextFieldBeta];
    
    // Assign picker view to selection inputs
    self.age.inputView = demographicsPicker;
    self.gender.inputView = demographicsPicker;
    self.ethnicity.inputView = demographicsPicker;
    self.income.inputView = demographicsPicker;
    self.cyclingFreq.inputView = demographicsPicker;
    self.riderType.inputView = demographicsPicker;
    self.riderHistory.inputView = demographicsPicker;
    
    // Assign tags
    self.age.tag		= ageTag;
    self.email.tag		= emailTag;
    self.gender.tag		= genderTag;
    self.ethnicity.tag  = ethnicityTag;
    self.income.tag     = incomeTag;
    self.homeZIP.tag	= homeZIPTag;
    self.workZIP.tag    = workZIPTag;
    self.schoolZIP.tag	= schoolZIPTag;
    self.cyclingFreq.tag = cyclingFreqTag;
    self.riderType.tag  =  riderTypeTag;
    self.riderHistory.tag = riderHistoryTag;
    

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:renoGreen];
    
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	request.entity = entity;
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"saved user count  = %ld", (long)count);
	if ( count == 0 )
	{
		// create an empty User entity
		self.user = [self createUser];
	}
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved user");
		if ( error != nil )
			NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, error.localizedDescription);
	}
	
	self.user = mutableFetchResults[0];
	if ( user != nil )
	{
		// initialize text fields indexes to saved personal info
		age.text            = ageArray[(user.age).integerValue];
		email.text          = user.email;
		gender.text         = genderArray[(user.gender).integerValue];
        ethnicity.text      = ethnicityArray[(user.ethnicity).integerValue];
        income.text         = incomeArray[(user.income).integerValue];
		
        homeZIP.text        = user.homeZIP;
		workZIP.text        = user.workZIP;
		schoolZIP.text      = user.schoolZIP;
        
        cyclingFreq.text        = cyclingFreqArray[(user.cyclingFreq).integerValue];
        riderType.text          = rider_typeArray[(user.rider_type).integerValue];
        riderHistory.text       = rider_historyArray[(user.rider_history).integerValue];
		
    }
	else
		NSLog(@"init FAIL");
	
}


#pragma mark UITextFieldDelegate methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.inputView == demographicsPicker) {
        return NO;
    } else {
        return YES;
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    selectedTextField = myTextField.tag;
    if(myTextField.inputView == demographicsPicker) {
        [demographicsPicker reloadAllComponents];
    }
    [self.view addGestureRecognizer:tapToSelect];
    
}

// save the new value for this textField
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	// save value
	if ( user != nil )
	{
        if(textField.inputView == demographicsPicker) {
            [user setValue:@([demographicsPicker selectedRowInComponent:0]) forKey:textFieldArray[textField.tag]];
            NSArray *valuesArray = [self valueForKey:[NSString stringWithFormat:@"%@Array",textFieldArray[textField.tag]]];
            textField.text = valuesArray[[demographicsPicker selectedRowInComponent:0]];
        } else {
            [user setValue:textField.text forKey:textFieldArray[textField.tag]];
        }
        
        if (user.hasChanges) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save textField error %@, %@", error, error.localizedDescription);
        } else {
            //not sure what this does, but it was used when the button was there
            [delegate setSaved:YES];
        }
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return nil;
			break;
		case 1:
			return @"Tell us about yourself";
			break;
		case 2:
			return @"Your typical commute";
			break;
		case 3:
			return @"How often do you cycle?";
			break;
        case 4:
			return @"What kind of rider are you?";
			break;
        case 5:
			return @"How long have you been a cyclist?";
			break;
	}
    return nil;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ( section )
	{
        case 0:
            return 1;
            break;
		case 1:
			return 5;
			break;
		case 2:
			return 3;
			break;
		case 3:
			return 1;
			break;
        case 4:
			return 1;
			break;
        case 5:
			return 1;
			break;
		default:
			return 0;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Set up the cell...
	UITableViewCell *cell = nil;
	
	// outer switch statement identifies section
	switch ([indexPath indexAtPosition:0])
	{
        case 0:
		{
			static NSString *CellIdentifier = @"CellInstruction";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Getting started with Reno Tracks";
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;

		case 1:
		{
			static NSString *CellIdentifier = @"CellPersonalInfo";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}

			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Age";
					[cell.contentView addSubview:age];
					break;
				case 1:
					cell.textLabel.text = @"Email";
					[cell.contentView addSubview:email];
					break;
				case 2:
					cell.textLabel.text = @"Gender";
					[cell.contentView addSubview:gender];
					break;
                case 3:
					cell.textLabel.text = @"Ethnicity";
					[cell.contentView addSubview:ethnicity];
					break;
                case 4:
					cell.textLabel.text = @"Home Income";
					[cell.contentView addSubview:income];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
	
		case 2:
		{
			static NSString *CellIdentifier = @"CellZip";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}

			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Home ZIP";
					[cell.contentView addSubview:homeZIP];
					break;
				case 1:
					cell.textLabel.text = @"Work ZIP";
					[cell.contentView addSubview:workZIP];
					break;
				case 2:
					cell.textLabel.text = @"School ZIP";
					[cell.contentView addSubview:schoolZIP];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 3:
		{
			static NSString *CellIdentifier = @"CellFrequecy";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Cycle Frequency";
					[cell.contentView addSubview:cyclingFreq];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 4:
		{
			static NSString *CellIdentifier = @"CellType";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider Type";
					[cell.contentView addSubview:riderType];
					break;
            }
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 5:
		{
			static NSString *CellIdentifier = @"CellHistory";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider History";
                    [cell.contentView addSubview:riderHistory];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
            break;
            
	}
	
    return cell;
}

//TODO: This can be dropped if the first item is a button instead of a label
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	// outer switch statement identifies section
    NSURL *url = [NSURL URLWithString:kInstructionsURL];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	switch ([indexPath indexAtPosition:0])
	{
		case 0:
		{
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    [[UIApplication sharedApplication] openURL:request.URL];
					break;
			}
			break;
		}
    }
}

#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSArray *pickerArray = [self valueForKey:[NSString stringWithFormat:@"%@Array",textFieldArray[selectedTextField]]];
    return pickerArray.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray *pickerArray = [self valueForKey:[NSString stringWithFormat:@"%@Array",textFieldArray[selectedTextField]]];
    return pickerArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:tapToSelect];

    
}

#pragma mark UIGesture Actions

- (IBAction)tapAway:(UITapGestureRecognizer *)tapRecognizer
{
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:tapToSelect];
    
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return true;
}




@end

