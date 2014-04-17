//
//  MainNavigationController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 4/15/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "MainNavigationController.h"
#import "CompassViewController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//      UINavigationBar *bar = [UINavigationBar appearanceWhenContainedIn:[CompassViewController class], nil];
//      [bar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//      [bar setShadowImage:[[UIImage alloc] init]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
}

-(void)viewWillAppear:(BOOL)animated {
//  if (self.visibleViewController.class == [CompassViewController class]){
//      [[UINavigationBar appearance] setTintColor:[UIColor yellowColor]];
//  } else {
//    [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
//  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
