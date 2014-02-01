//
//  LocalSearchViewController.m
//  LocalSearch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import "LocalSearchViewController.h"
#import "NaviViewController.h"

@interface LocalSearchViewController ()

@property (strong, nonatomic)	NSMutableArray *mapItems;
@property (strong, nonatomic)	MKDirectionsResponse *response;
@property (strong, nonatomic)	MKMapItem *mapItemFrom;
@property (strong, nonatomic)	MKMapItem *mapItemTo;
@property (assign, nonatomic)	int routeIndex;

@property (strong, nonatomic)	MKRoute *selectedRoute;

@end

@implementation LocalSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	_mapItems = [NSMutableArray array];
	_routeIndex = 0;

	[self setGestureOnTableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[self initMapRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Search Job

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];

	MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
	request.naturalLanguageQuery = searchBar.text;
	request.region = _mapView.region;
	
	MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
	
	
	[search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

		[_mapItems removeAllObjects];
		[_mapView removeAnnotations:[_mapView annotations]];

		for(MKMapItem *item in response.mapItems) {
			MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
			point.coordinate = item.placemark.coordinate;
			point.title = item.placemark.name;
			point.subtitle = item.phoneNumber;

			[_mapView addAnnotation:point];
			[_mapItems addObject:item];
		}
		[_mapView showAnnotations:[_mapView annotations] animated:YES];
		_mapItemFrom = _mapItemTo = nil;

		[_tableView reloadData];
	}];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	return YES;
}

#pragma mark - TableView Job


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	MKMapItem *item = [_mapItems objectAtIndex:indexPath.row];
	cell.textLabel.text = item.name;
	cell.detailTextLabel.text = item.placemark.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	MKMapItem *item = [self.mapItems objectAtIndex:indexPath.row];
	
	for(MKPointAnnotation *annotation in _mapView.annotations) {
		if((annotation.coordinate.latitude == item.placemark.coordinate.latitude) && (annotation.coordinate.longitude == item.placemark.coordinate.longitude)) {

			[_mapView selectAnnotation:annotation animated:YES];
			
			if(_mapItemFrom == nil) {
				_mapItemFrom = item;
			}
			else {
				if(_mapItemTo == nil) {
					_mapItemTo = item;
				}
				else {
					if(_mapItemTo == item) {
						_routeIndex++;
					}
					else {
						_routeIndex = 0;
						_mapItemFrom = self.mapItemTo;
						_mapItemTo = item;
					}
				}
				[self findDirectionsFrom:_mapItemFrom to:_mapItemTo routeIndex:_routeIndex];
			}
			break;
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)setGestureOnTableView {
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(execNavi:)];
	tapGestureRecognizer.numberOfTapsRequired = 2;
    [_tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void)execNavi:(UILongPressGestureRecognizer*)gestureRecognizer {
	[self performSegueWithIdentifier:@"showNaviPage" sender:self];
}


#pragma mark - Map Job

-(void)initMapRegion {
	
	CLLocationCoordinate2D center = CLLocationCoordinate2DMake(21.500353, -157.959694);
	MKCoordinateSpan span = MKCoordinateSpanMake(0.520984, 0.603312);
	MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
	
	self.mapView.region = region;
}

- (IBAction)initButtonPushed:(id)sender {
	[self initMapRegion];
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
	
	MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
	
	renderer.lineWidth = 5.0;
	renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
	
	return (MKOverlayRenderer*)renderer;
}

#pragma mark - Route Job

-(void)findDirectionsFrom:(MKMapItem*)source
					   to:(MKMapItem*)destination
			  routeIndex:(int)routeIndex
{
	MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
	request.source = source;
	request.destination = destination;
	request.requestsAlternateRoutes = YES;

	MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		if(!error) {
			_response = response;
			NSLog(@"route count %d", [response.routes count]);

			int routeNo = routeIndex % [response.routes count];
			MKRoute *route = response.routes[routeNo];
			_selectedRoute = route;
			
			for(MKRouteStep *step in route.steps) {
				NSLog(@"%@", step.instructions);
				NSLog(@"%@", step.notice);
			}

			MKDistanceFormatter *distanceFormat = [[MKDistanceFormatter alloc] init];
			NSString *distance = [distanceFormat stringFromDistance:route.distance];
			NSString *time = [NSString stringWithFormat:@"%.0lf", route.expectedTravelTime/60];
			NSLog(@"%@経由", route.name);
			NSLog(@"%@ - 約%@分で到着", distance, time);
			
			[_mapView removeOverlays:[_mapView overlays]];
			[_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];

			_routeInfoLabel.text = [NSString stringWithFormat:@"%@経由で%@：約%@分で到着", route.name, distance, time];
		}
	}];
}


#pragma mark - Navi job

-(void)openNaviPageWithRoute {
		[self performSegueWithIdentifier:@"showNaviPage" sender:self];
}

-(void)closeNaviPage {
		[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [[segue identifier] isEqualToString:@"showNaviPage"] ) {
        NaviViewController *nextViewController = [segue destinationViewController];
		nextViewController.delegate = self;
        nextViewController.selectedRoute = _selectedRoute;
    }
}

@end
