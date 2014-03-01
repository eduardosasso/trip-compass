#import "BookmarkViewController.h"
#import "CompassViewController.h"
#import "BookmarkItemViewController.h"
#import "Place.h"
#import "PlaceModel.h"

@interface BookmarkViewController () <CLLocationManagerDelegate>
@end

@implementation BookmarkViewController {
  CLLocationManager *locationManager;
  NSInteger savedPlacesCount;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Fix the header under status bar
  self.tableView.contentInset = UIEdgeInsetsMake(self.tabBarController.topLayoutGuide.length, 0, 0, 0);

  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"BookmarkCell" bundle:nil] forCellReuseIdentifier:@"BookmarkCell"];
  
  //TODO: get the initial size dynamically from the constraints
  self.tableView.estimatedRowHeight = 43;
  
//  self.tabBarController.delegate = self;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (NSString *)googleAnalyticsScreenName {
  return @"Bookmark";
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
  [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
  self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tabBarController.navigationItem.title = @"Favorites";
  
  NSError *error;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
    
  NSPropertyDescription *propDesc = [[entity propertiesByName] objectForKey:@"area"];
  NSExpression *emailExpr = [NSExpression expressionForKeyPath:@"area"];
  NSExpression *countExpr = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:emailExpr]];
  NSExpressionDescription *exprDesc = [[NSExpressionDescription alloc] init];
  [exprDesc setExpression:countExpr];
  [exprDesc setExpressionResultType:NSInteger64AttributeType];
  [exprDesc setName:@"count"];
  
  NSFetchRequest *fr = [[NSFetchRequest alloc] init];
  [fr setEntity:entity];
  
  [fr setPropertiesToGroupBy:[NSArray arrayWithObject:propDesc]];
  fr.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
  
  [fr setPropertiesToFetch:[NSArray arrayWithObjects:propDesc, exprDesc, nil]];
  [fr setResultType:NSDictionaryResultType];
  
  self.savedPlaces = [[NSMutableArray alloc] initWithArray: [self.managedObjectContext executeFetchRequest:fr error:&error]];
  savedPlacesCount = [self.savedPlaces count];
  
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 return savedPlacesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
  
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  
  cell.placeLabel.text = [place valueForKey:@"area"];
  cell.detailLabel.text = [[place objectForKey:@"count"]stringValue];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell"];
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  
  return [cell calculateHeight:[place valueForKey:@"area"]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  [fetchRequest setEntity:entity];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area == %@", [place valueForKey:@"area"]];
  [fetchRequest setPredicate:predicate];
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  
  for (NSManagedObject *managedObject in results) {
    [self.managedObjectContext deleteObject:managedObject];
  }
  --savedPlacesCount;
  [self.savedPlaces removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
  [self.managedObjectContext save:nil];
  
  [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"toBookmarkItemController" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];

  NSDictionary *place = [self.savedPlaces objectAtIndex:path.row];
  BookmarkItemViewController *controller = (BookmarkItemViewController *)segue.destinationViewController;

  controller.selectedAreaGroup = [place valueForKey:@"area"];  
}

@end
