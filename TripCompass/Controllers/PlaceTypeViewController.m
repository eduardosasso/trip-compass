#import "PlaceTypeViewController.h"
#import "AppDelegate.h"

@implementation PlaceTypeViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.placeType.length == 0) self.placeType = @"All";
}

- (void)viewWillAppear:(BOOL)animated {
  [self selectActiveFilter];
}

- (IBAction)closeButtonClicked:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  cell.textLabel.textColor = customMagentaColor;
  
  [self.delegate didSelectPlaceType:cell.textLabel.text];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectActiveFilter {
  for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (([cell.textLabel.text isEqualToString:self.placeType])) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
      cell.textLabel.textColor = customMagentaColor;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
  }
}

@end