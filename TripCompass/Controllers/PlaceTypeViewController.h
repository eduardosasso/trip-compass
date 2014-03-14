#import <UIKit/UIKit.h>

@protocol PlaceTypeDelegate <NSObject>
- (void)didSelectPlaceType:(NSString *)type;
@end

@interface PlaceTypeViewController : UITableViewController

@property (nonatomic, weak) id<PlaceTypeDelegate> delegate;
@property (nonatomic, copy) NSString *placeType;

- (IBAction)closeButtonClicked:(id)sender;

@end