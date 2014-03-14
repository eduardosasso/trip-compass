#import "PlaceTypeViewController.h"

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
  
  [self.delegate didSelectPlaceType:cell.textLabel.text];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectActiveFilter {
  for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = ([cell.textLabel.text isEqualToString:self.placeType]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  }
}

@end