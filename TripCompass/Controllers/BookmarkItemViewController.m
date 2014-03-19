#import "BookmarkItemViewController.h"
#import "PlaceDataManager.h"

@implementation BookmarkItemViewController {
  NSMutableArray *places;

  CLLocationManager *locationManager;
  CLLocation *currentLocation;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
}

-(void)viewWillAppear:(BOOL)animated {
  [self startTrackingLocation];
  
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.title = self.city;
}

#pragma mark Location Manager
- (void)startTrackingLocation {
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  locationManager.distanceFilter = 100;
  if([CLLocationManager locationServicesEnabled]) [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  currentLocation = (CLLocation *)[locations lastObject];
  
  [self findPlacesByCitySortedByDistance];
  
  [manager stopUpdatingLocation];
  [manager setDelegate:nil];
}

- (void)findPlacesByCitySortedByDistance {
  places = [NSMutableArray arrayWithArray:[PlaceDataManager findPlacesByCity:self.city]];
  
  for (PlaceModel *place in places) {
    CLLocationDegrees lat = [place.lat doubleValue];
    CLLocationDegrees lng = [place.lng doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLLocationDistance distance = [location distanceFromLocation:currentLocation];
    place.distance = [NSNumber numberWithDouble:distance];
  }

  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
  [places sortUsingDescriptors:@[sort]];
  
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
  
  PlaceModel *placeModel = [places objectAtIndex:indexPath.row];
  
  Place *place = [[Place alloc] init];
  place.name = placeModel.name;
  place.address = placeModel.address;
  place.lat = placeModel.lat;
  place.lng = placeModel.lng;
  
  cell.placeLabel.text = place.name;

  cell.detailLabel.text = [place formattedDistanceTo:currentLocation.coordinate];

  return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
//  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];
//  
//  return [cell calculateHeight:placeModel.name];
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  PlaceModel *place = [places objectAtIndex:indexPath.row];
  
  //TODO return key
  [PlaceDataManager destroy:place.key];
  [places removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
  if (places == 0) {
    //TODO check to see if return to previous view
    [self.navigationController popViewControllerAnimated:YES];
  }
//  [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  [self performSegueWithIdentifier:@"CompassViewController" sender:self];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];

  PlaceModel *placeModel = [places objectAtIndex:path.row];
  Place *place = [[Place alloc] init];
  place.name = placeModel.name;
  place.address = placeModel.address;
  place.lat = placeModel.lat;
  place.lng = placeModel.lng;
  
  [segue.destinationViewController performSelector:@selector(setPlace:)
                                        withObject:place];
}

-(NSString *)googleAnalyticsScreenName {
  return NSStringFromClass([self class]);
}

@end
