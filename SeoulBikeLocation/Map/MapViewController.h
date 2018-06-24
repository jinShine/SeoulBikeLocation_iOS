//
//  MapViewController.h
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 19..
//  Copyright © 2018년 김승진. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"

@interface MapViewController : UIViewController

- (void) selectedLocationOnListViewControllerWithLatitude:(double)latitude longitude:(double)longitude;

@end
