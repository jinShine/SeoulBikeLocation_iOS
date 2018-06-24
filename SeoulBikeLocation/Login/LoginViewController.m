//
//  LoginViewController.m
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 22..
//  Copyright © 2018년 김승진. All rights reserved.
//

#import "LoginViewController.h"
#import "MapViewController.h"
#import "SignUpViewController.h"
#import "FindPasswordViewController.h"

#import <SCLAlertView.h>
#import <AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *id_TextField;
@property (weak, nonatomic) IBOutlet UITextField *password_TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logo_topConstraint;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - HTTP Method

- (IBAction)LoginButton:(UIButton *)sender {
    
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *contentURL=[NSString stringWithFormat:@"http://ec2-13-125-66-53.ap-northeast-2.compute.amazonaws.com:3000/login"];
    NSDictionary *bodys = @{@"email":self.id_TextField.text, @"password":self.password_TextField.text};
    
    [manager POST:contentURL parameters:bodys progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject : %@", responseObject);
        
        if([responseObject[@"stateMsg"] isEqualToString:@"SUCCESS"])
        {
            [self.id_TextField resignFirstResponder];
            [self.password_TextField resignFirstResponder];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            [self.navigationController pushViewController:mapVC animated:YES];
        
        } else {
            
            NSDictionary *responseDic = [responseObject objectForKey:@"error"];
            NSInteger errorCode = [[responseDic objectForKey:@"code"] integerValue];
            NSString *errorMsg = [responseDic objectForKey:@"msg"];
            
            SCLAlertView *alertView = [[SCLAlertView alloc] init];
            
            if(errorCode == 4000) {
                [alertView showError:self title:@"로그인 에러" subTitle:[NSString stringWithFormat:@"%@%@",errorMsg,@"\n다시 시도하세요."] closeButtonTitle:@"확인" duration:0.0f];
                [alertView alertIsDismissed:^{
                    [self.id_TextField becomeFirstResponder];
                }];
            } else {
                
                [alertView showError:self title:@"로그인 에러" subTitle:@"로그인 정보가 올바르지 않습니다.\n다시 시도하세요." closeButtonTitle:@"확인" duration:0.0f];
                [alertView alertIsDismissed:^{
                    [self.id_TextField becomeFirstResponder];
                }];
            }
        }

        [SVProgressHUD dismiss];
        
        [self.id_TextField resignFirstResponder];
        [self.password_TextField resignFirstResponder];
        
        [UIView animateWithDuration:0.35f animations:^{
            self.logo_topConstraint.constant = 50;
            [self.view layoutIfNeeded];
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"search Error : %@", error);
    }];
}

- (IBAction)SignUpButton:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpViewController *signUpVC = [storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signUpVC animated:YES];
}

- (IBAction)findPassword:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FindPasswordViewController *findPasswordVC = [storyboard instantiateViewControllerWithIdentifier:@"FindPasswordViewController"];
    [self.navigationController pushViewController:findPasswordVC animated:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.35f animations:^{
        self.logo_topConstraint.constant = 50;
        [self.view layoutIfNeeded];
    }];
}

#pragma - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.35f animations:^{
        self.logo_topConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

@end
