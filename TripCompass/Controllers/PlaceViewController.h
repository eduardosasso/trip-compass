#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Place.h"
#import "PlaceTypeViewController.h"
#import "GAUITableViewController.h"

@interface PlaceViewController : GAUITableViewController <UISearchBarDelegate, UITabBarControllerDelegate, PlaceTypeDelegate>

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (nonatomic, assign) BOOL searching;

- (IBAction)pullToRefresh:(id)sender;

@end

