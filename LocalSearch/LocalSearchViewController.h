//
//  LocalSearchViewController.h
//  LocalSearch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocalSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoLabel;	// 追加

- (void)closeNaviPage;

@end
