#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Place.h"
#import "PlaceTypeViewController.h"
#import "LocationSearchViewController.h"
#import "GAUITableViewController.h"
#import "CustomCell.h"
#import "API.h"

@interface PlaceViewController : GAUITableViewController <CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, APIDelegate, PlaceTypeDelegate, LocationSearchDelegate, CustomCellDelegate>

@property (strong, nonatomic) IBOutlet UIView *plainView;

- (IBAction)pullToRefresh:(id)sender;

@end

