#import <UIKit/UIKit.h>

@protocol PlaceTypeDelegate <NSObject>

- (void)didSelectPlaceType:(NSString *)type;

@end

@interface PlaceTypeViewController : UITableViewController

- (IBAction)closeButtonClicked:(id)sender;
@property (nonatomic, weak) id<PlaceTypeDelegate> delegate;
@property (nonatomic, copy) NSString *placeType;

@end