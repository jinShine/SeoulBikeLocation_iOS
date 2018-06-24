//
//  FindPasswordViewController.m
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 24..
//  Copyright © 2018년 김승진. All rights reserved.
//

#import "FindPasswordViewController.h"

#import <SCLAlertView.h>
#import <AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface FindPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *id_TextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.35f animations:^{
        self.topConstraint.constant = 100;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)sendEmailButton:(UIButton *)sender {
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *contentURL=[NSString stringWithFormat:@"http://ec2-13-125-66-53.ap-northeast-2.compute.amazonaws.com:3000/findpassword"];
    NSDictionary *bodys = @{@"email":self.id_TextField.text};
    
    [manager POST:contentURL parameters:bodys progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject : %@", responseObject);
        
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        
        
        if([responseObject[@"stateMsg"] isEqualToString:@"SUCCESS"])
        {
            [alertView showSuccess:self title:@"메일 전송" subTitle:@"메일로 비밀번호를 보내드렸습니다" closeButtonTitle:@"확인" duration:0.0f];
            [alertView alertIsDismissed:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            NSDictionary *responseDic = [responseObject objectForKey:@"error"];
            NSInteger errorCode = [[responseDic objectForKey:@"code"] integerValue];
            NSString *errorMsg = [responseDic objectForKey:@"msg"];
            
            if(errorCode == 4002 || errorCode == 4005) {
                [alertView showError:self title:@"회원가입 에러" subTitle:[NSString stringWithFormat:@"%@%@",errorMsg,@"\n다시 시도하세요."] closeButtonTitle:@"확인" duration:0.0f];
                [alertView alertIsDismissed:^{
                    [self.id_TextField becomeFirstResponder];
                }];
            } else {
               
            }
        }
        
        [SVProgressHUD dismiss];
        
        [self.id_TextField resignFirstResponder];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"search Error : %@", error);
    }];
}


- (IBAction)goLoginVC:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.35f animations:^{
        self.topConstraint.constant = 70;
        [self.view layoutIfNeeded];
    }];
}



@end
