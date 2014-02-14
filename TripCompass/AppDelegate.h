//
//  AppDelegate.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) Place *selectedLocation;
@property (nonatomic, assign, getter=isOnline) BOOL online;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
