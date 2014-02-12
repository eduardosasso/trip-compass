#import <UIKit/UIKit.h>
#import "PlaceTypeViewController.h"

@interface TestViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PlaceTypeDelegate>
@property (strong, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end
