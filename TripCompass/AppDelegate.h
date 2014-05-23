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

#define customMagentaColor [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:126.0/255.0 alpha:1]
#define customGreenColor [UIColor colorWithRed:0 green:1 blue:0 alpha:1]
#define customRedColor [UIColor colorWithRed:1 green:0.231 blue:0.188 alpha:1]

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
