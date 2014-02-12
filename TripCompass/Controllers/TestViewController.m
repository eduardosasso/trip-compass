#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController {
   NSArray *tableData;
}

- (void)didSelectPlaceType:(NSString *)type {
  NSLog(@"Type %@", type);
}

//Going to place type selection screen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  //register this class as a delegate so it will receive events defined in the delegate class
  PlaceTypeViewController *placeType = (PlaceTypeViewController *)[segue.destinationViewController topViewController];
  placeType.delegate = self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *simpleTableIdentifier = @"SimpleTableItem";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
  }
  
  cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
  return cell;
}


@end
