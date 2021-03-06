//
//  UIDevice(Identifier).h
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AdSupport/ASIdentifierManager.h>


@interface UIDevice (IdentifierAddition)
@property(nonatomic, readonly, retain) NSUUID *identifierForVendor;
@property(nonatomic, readonly) NSUUID *advertisingIdentifier;

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

@property (nonatomic, readonly, copy) NSString *uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

@property (nonatomic, readonly, copy) NSString *uniqueGlobalDeviceIdentifier;


@end
