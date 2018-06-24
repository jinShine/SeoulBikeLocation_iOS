//
//  ListTableViewCell.h
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 20..
//  Copyright © 2018년 김승진. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rentalShopName;
@property (weak, nonatomic) IBOutlet UILabel *rentalShopAddress;
@property (weak, nonatomic) IBOutlet UILabel *rentalShopNumber;
@property (weak, nonatomic) IBOutlet UILabel *cradleCount;


@end
