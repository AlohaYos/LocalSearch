//
//  NaviViewController.m
//  LocalSearch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import "NaviViewController.h"

@interface NaviViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation NaviViewController {
	CLLocationCoordinate2D	_stepPoint;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_mapView.showsBuildings = YES;
	_mapView.showsPointsOfInterest = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	MKRouteStep *step = [_selectedRoute.steps objectAtIndex:0];
	[self moveMapCameraTo:step];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Job


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_selectedRoute.steps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NaviCell" forIndexPath:indexPath];
	
	MKRouteStep *step = [_selectedRoute.steps objectAtIndex:indexPath.row];
	cell.textLabel.text = step.instructions;
	cell.detailTextLabel.text = step.notice;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	MKRouteStep *step = [_selectedRoute.steps objectAtIndex:indexPath.row];
	[self moveMapCameraTo:step];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Map job

-(void)moveMapCameraTo:(MKRouteStep *)step {
	
	CLLocationCoordinate2D ground;
	CLLocationCoordinate2D eye;

	if([_tableView indexPathsForSelectedRows]==nil) {
		ground = step.polyline.coordinate;
		eye = ground;
	}
	else {
		ground = step.polyline.coordinate;
		eye = _stepPoint;
	}
	
	MKMapCamera *myCamera = [MKMapCamera cameraLookingAtCenterCoordinate:ground fromEyeCoordinate:eye eyeAltitude:100];
	[_mapView setCamera:myCamera animated:YES];

	_stepPoint = ground;

	MKDistanceFormatter *distanceFormat = [[MKDistanceFormatter alloc] init];
	NSString *distance = [distanceFormat stringFromDistance:step.distance];

	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
	annotation.coordinate = ground;
	annotation.title = distance;
	
	[_mapView removeAnnotations:[_mapView annotations]];
	[_mapView addAnnotation:annotation];
	[_mapView selectAnnotation:annotation animated:YES];
}

- (IBAction)backButtonPushed:(id)sender {
	[_delegate closeNaviPage];
}

@end
