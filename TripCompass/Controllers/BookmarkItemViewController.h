#import <UIKit/UIKit.h>
#import "CustomCell.h"
#import "GAUITableViewController.h"

@interface BookmarkItemViewController : GAUITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *city;

@end