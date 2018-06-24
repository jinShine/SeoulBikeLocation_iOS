//
//  MapViewController.m
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 19..
//  Copyright © 2018년 김승진. All rights reserved.
//


#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

#import <GoogleMaps/GoogleMaps.h>
#import <SCLAlertView.h>
#import <AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface MapViewController () <CLLocationManagerDelegate, UISearchBarDelegate>


//locationManager
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *settingBtn;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *marker;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 위치 권한 체크
    [self initLocationManager];
    
    // 대여소 전체 위치 마커
    [self totalRentalShopLocationParsing];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // ListVC presentedViewController
    if (self.presentedViewController) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        //ListVC에서 검색 위치 선택하면 선택한 위치로 이동
        if([[[userDefault dictionaryRepresentation] allKeys] containsObject:@"selectedLatitude"] || [[[userDefault dictionaryRepresentation] allKeys] containsObject:@"selectedLongitude"] == YES)
        {
            [self selectedLocationOnListViewControllerWithLatitude:[userDefault doubleForKey:@"selectedLatitude"] longitude:[userDefault doubleForKey:@"selectedLongitude"]];
        }
        //ListVC에서 검색 하지 않고 Back버튼 선택시 현재 위치 기억
        else {
            [self selectedLocationOnListViewControllerWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
        }
        
    }
}

#pragma mark - init Method

- (void) initMapUI {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude
                                                            longitude:self.locationManager.location.coordinate.longitude
                                                                 zoom:17];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.padding = UIEdgeInsetsMake(70, 0, 0, 0);
    
    [self.view addSubview:self.mapView];
    
    [self initSearchBar]; // SearchBar init
    
}

- (void) initSearchBar {

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    
    [self.view addSubview:self.searchBar];
    
    self.settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 13, 10)];
    [self.settingBtn setImage:[UIImage imageNamed:@"img_Setting"] forState:UIControlStateNormal];
    [self.settingBtn addTarget:self action:@selector(settingButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingBtn];
    [self.view bringSubviewToFront:self.settingBtn];
    
    //AutoLayout
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50.0].active = YES;
    [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0].active = YES;
    
    self.settingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.settingBtn.widthAnchor constraintEqualToConstant: 10];
    [self.settingBtn.centerYAnchor constraintEqualToAnchor:self.searchBar.centerYAnchor constant:0.0].active = YES;
    [self.settingBtn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    [self.settingBtn.trailingAnchor constraintEqualToAnchor:self.searchBar.leadingAnchor constant:-10.0].active = YES;
    
    //Customize
    self.searchBar.layer.borderWidth = 2.0;
    self.searchBar.layer.borderColor = [UIColor colorWithRed: 34/255.0 green:138/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.searchBar.layer.cornerRadius = 15.0;
    self.searchBar.barTintColor = [UIColor colorWithRed:255/255.0 green:246/255.0 blue:241/255.0 alpha:1.0];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.backgroundImage = [UIImage imageNamed:@"img_SearchBar"];
    
    UITextField *textField = [self.searchBar valueForKey:@"_searchField"];
    textField.textColor = [UIColor colorWithRed: 34/255.0 green:138/255.0 blue:255/255.0 alpha:1.0];
    textField.placeholder = @"따릉이 위치 검색";
    textField.backgroundColor = [UIColor colorWithRed:255/255.0 green:246/255.0 blue:241/255.0 alpha:1.0];
    textField.font = [UIFont systemFontOfSize:18.0];
    [textField setValue:[UIColor colorWithRed: 34/255.0 green:138/255.0 blue:255/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void) initLocationManager {
    
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (void) settingButton {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"title" message:@"message" preferredStyle:UIAlertControllerStyleActionSheet];
    

    
    UIAlertAction *logout = [UIAlertAction actionWithTitle:@"로그아웃" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    [alertController addAction:logout];
    [self presentViewController:alertController animated:YES completion:nil];
}

//ListVC selected and camera position update
- (void)selectedLocationOnListViewControllerWithLatitude:(double)latitude longitude:(double)longitude {
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:17];
    [self.mapView animateToCameraPosition:self.mapView.camera];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - HTTP Method

- (void) totalRentalShopLocationParsing {
    
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // 192.168.0.37
    // 172.30.1.46
    NSString *contentURL=[NSString stringWithFormat:@"http://ec2-13-125-66-53.ap-northeast-2.compute.amazonaws.com:3000/rentalShopInfo"];
    
    [manager GET:contentURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"responseObject : %@", responseObject);
        
        if([responseObject[@"msg"] isEqualToString:@"success"])
        {
            
            NSArray *dataArr = responseObject[@"seoulbikeItems"];
            
            for (int i = 0; i<dataArr.count; i++) {
                
                self.marker = [[GMSMarker alloc] init];
                
                double rentalShopLatitude = [[[dataArr objectAtIndex:i] objectForKey:@"latitude"] doubleValue];
                double rentalShopLongitude = [[[dataArr objectAtIndex:i] objectForKey:@"longitude"] doubleValue];
                self.marker.position = CLLocationCoordinate2DMake(rentalShopLatitude, rentalShopLongitude);
            
                self.marker.title = [[dataArr objectAtIndex:i] objectForKey:@"content_nm"];
                self.marker.snippet = [[dataArr objectAtIndex:i] objectForKey:@"new_addr"];
                self.marker.map = self.mapView;
            }
        } else {
            SCLAlertView *alertView = [[SCLAlertView alloc] init];
            [alertView showError:self title:@"서버 점검" subTitle:@"현재 서버 점검 중입니다.\n서비스 이용에 불편을 드려 죄송합니다.\n신속하게 완료하여 보다 안정적인 서비스가 되도록 하겠습니다." closeButtonTitle:@"앱 종료" duration:0.0f];
            
            [alertView alertIsDismissed:^{
                NSLog(@"앱 종료");
                exit(0);
            }];
        }
        
        
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"search Error : %@", error);
    }];
}

#pragma mark - CoreLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"%s : ","kCLAuthorizationStatusDenied");
        
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        
        [alertView addButton:@"확인" actionBlock:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                if(success)
                    NSLog(@"openURL Success");
            }];
        }];
        
        [alertView showNotice:self title:@"현재 위치" subTitle:@"현재 위치를 불러 올 수 없습니다.\n 보다 편리한 검색을 위해 위치서비스를 사용해 보세요.\n iOS 기기의 [설정] > [HiKorea] > [위치]를 ON으로 설정해주세요."
             closeButtonTitle:@"close" duration:0.0f];
    }
    else if(status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        NSLog(@"%s : ","kCLAuthorizationStatusAuthorizedWhenInUse");
        
        [self initMapUI];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"didUpdateLocations : %@", [locations lastObject]);
}


#pragma - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    
    ListViewController *listVC = [[ListViewController alloc] init];
    [self presentViewController:listVC animated:NO completion:^{
        NSLog(@"ListVC 이동");
    }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"textDidChange");
}


@end
