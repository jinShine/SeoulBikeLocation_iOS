//
//  ListViewController.m
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 20..
//  Copyright © 2018년 김승진. All rights reserved.
//

#import "ListViewController.h"
#import "ListTableViewCell.h"
#import "MapViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ListViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *goBack;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *districtData;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSearchBar];
    [self.searchBar becomeFirstResponder];
    [self initTableView];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - init Method

- (void) initSearchBar {
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    
    [self.view addSubview:self.searchBar];
    
    self.goBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
    [self.goBack setImage:[UIImage imageNamed:@"img_Back"] forState:UIControlStateNormal];
    [self.goBack addTarget:self action:@selector(dismissButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.goBack];
    [self.view bringSubviewToFront:self.goBack];
    
    //AutoLayout
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50.0].active = YES;
    [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0].active = YES;
    
    self.goBack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.goBack.widthAnchor constraintEqualToConstant: 10];
    [self.goBack.centerYAnchor constraintEqualToAnchor:self.searchBar.centerYAnchor constant:0.0].active = YES;
    [self.goBack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    [self.goBack.trailingAnchor constraintEqualToAnchor:self.searchBar.leadingAnchor constant:-10.0].active = YES;
    
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

- (void) dismissButton {
    [self dismissViewControllerAnimated:NO completion:^{
        NSLog(@"MapVC 이동");
    }];
}

- (void) initTableView {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //AutoLayout
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:0.0].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0.0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0.0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0.0].active = YES;
    
    //Register
    [self.tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil] forCellReuseIdentifier:@"listCell"];

}

#pragma mark - HTTP Method

- (void)districtRentalShopLocationParsing: (NSString *)districName {
    
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *searchText = [districName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet capitalizedLetterCharacterSet]];
    NSString *contentURL=[NSString stringWithFormat:@"http://ec2-13-125-66-53.ap-northeast-2.compute.amazonaws.com:3000/rentalShopInfo/%@", searchText];
    
    [manager GET:contentURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if([responseObject[@"msg"] isEqualToString:@"success"])
        {
            NSArray *dataArr = responseObject[@"seoulbikeItems"];
            self.districtData = dataArr;
            
            [self.tableView reloadData];
            
            NSLog(@"district : %@", self.districtData);
        }
        
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"search Error : %@", error);
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"searchBar : %@", searchBar.text);
    
    [self districtRentalShopLocationParsing:searchBar.text];
    
    [self.searchBar resignFirstResponder];
    
}


#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.districtData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ListTableViewCell *cell = (ListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    
    cell.rentalShopName.text = [[self.districtData objectAtIndex:indexPath.row] objectForKey:@"content_nm"];
    cell.rentalShopAddress.text = [[self.districtData objectAtIndex:indexPath.row] objectForKey:@"new_addr"];
    cell.rentalShopNumber.text = [NSString stringWithFormat:@"%@",[[self.districtData objectAtIndex:indexPath.row] objectForKey:@"content_id"]];
    cell.cradleCount.text = [NSString stringWithFormat:@"%@",[[self.districtData objectAtIndex:indexPath.row] objectForKey:@"cradle_count"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    double latitude = [[[self.districtData objectAtIndex:indexPath.row] objectForKey:@"latitude"] doubleValue];
    double longitude = [[[self.districtData objectAtIndex:indexPath.row] objectForKey:@"longitude"] doubleValue];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setDouble:latitude forKey:@"selectedLatitude"];
    [userDefault setDouble:longitude forKey:@"selectedLongitude"];
    
    [self dismissViewControllerAnimated:NO completion:^{
        NSLog(@"MapVC 이동");
        [userDefault removeObjectForKey:@"selectedLatitude"];
        [userDefault removeObjectForKey:@"selectedLongitude"];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0f;
}


@end
