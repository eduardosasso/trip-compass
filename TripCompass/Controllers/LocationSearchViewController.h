#import <UIKit/UIKit.h>
//#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "GAUITableViewController.h"
#import "API.h"

@protocol LocationSearchDelegate <NSObject>
- (void)didSelectLocation:(CLLocation *)location city:(NSString *)city;
@end

@interface LocationSearchViewController : GAUITableViewController <CLLocationManagerDelegate, APIDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, weak) id<LocationSearchDelegate> delegate;

@end
