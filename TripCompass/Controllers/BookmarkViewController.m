//
//  BookmarkViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2014 Eduardo Sasso
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "BookmarkViewController.h"
#import "PlaceDataManager.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NoFavoritesView.h"

@implementation BookmarkViewController {
  NSMutableArray *cities;
  NoFavoritesView *noFavoritesView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.tableView registerNib:[UINib nibWithNibName:@"BookmarkCell" bundle:nil] forCellReuseIdentifier:@"BookmarkCell"];
  self.tableView.rowHeight = 60;

  noFavoritesView = [[NoFavoritesView alloc] init];
  [self.navigationController.view addSubview:noFavoritesView];
}

- (void)viewWillAppear:(BOOL)animated {
  [[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = nil;
  
  cities = [NSMutableArray arrayWithArray:[PlaceDataManager findCities]];
  if ([cities count] > 0) self.navigationItem.rightBarButtonItem = self.editButtonItem;

  [self toggleNoFavoritesView:([cities count] == 0)];
  [self.tableView reloadData];
}

- (void)toggleNoFavoritesView:(BOOL)show {
  [noFavoritesView setHidden:!show];
  [self.tableView setHidden:show];
  
  if (show) [self.navigationController.view bringSubviewToFront:noFavoritesView];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
  
  NSDictionary *place = [cities objectAtIndex:indexPath.row];
  
  cell.placeLabel.text = [place valueForKey:@"city"];
  NSString *count = [[place objectForKey:@"count"] stringValue];

  cell.detailLabel.text = ([count integerValue] > 99) ? @"99" : count;
  cell.detailLabel.textColor = [UIColor whiteColor];
  
  UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
  UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
  cell.detailLabel.font = [UIFont fontWithDescriptor:boldFontDescriptor size:0.f];

  cell.detailLabel.backgroundColor = customMagentaColor;
  cell.detailLabel.layer.cornerRadius = 12;
  cell.detailLabel.layer.masksToBounds = YES;
  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *place = [cities objectAtIndex:indexPath.row];
  
  [PlaceDataManager destroyByCity:[place valueForKey:@"city"]];
  
  [cities removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
  if ([cities count] == 0) {
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
    [self toggleNoFavoritesView:YES];
  }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  [self performSegueWithIdentifier:@"BookmarkItemViewController" sender:self];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];
  NSDictionary *place = [cities objectAtIndex:path.row];
  
  [segue.destinationViewController performSelector:@selector(setCity:)
                                        withObject:[place valueForKey:@"city"]];
}

#pragma mark Undefined
- (NSString *)googleAnalyticsScreenName {
  return NSStringFromClass([self class]);
}

@end
