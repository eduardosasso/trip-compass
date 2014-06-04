#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GAUITableViewController.h"

@interface BookmarkItemViewController : GAUITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *city;

@end