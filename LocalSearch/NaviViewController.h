//
//  NaviViewController.h
//  LocalSearch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocalSearchViewController.h"

@interface NaviViewController : UIViewController

@property (strong, nonatomic)	MKRoute *selectedRoute;
@property (weak, nonatomic)	LocalSearchViewController *delegate;

@end
