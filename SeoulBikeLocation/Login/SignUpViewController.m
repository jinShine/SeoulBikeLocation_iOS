//
//  SignUpViewController.m
//  SeoulBikeLocation
//
//  Created by 김승진 on 2018. 6. 23..
//  Copyright © 2018년 김승진. All rights reserved.
//

#import "SignUpViewController.h"

#import <SCLAlertView.h>
#import <AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *id_TextField;
@property (weak, nonatomic) IBOutlet UITextField *password_TextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.35f animations:^{
        self.topConstraint.constant = 100;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)goLoginVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)signUpButton:(UIButton *)sender {
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *contentURL=[NSString stringWithFormat:@"http://ec2-13-125-66-53.ap-northeast-2.compute.amazonaws.com:3000/signup"];
    NSDictionary *bodys = @{@"email":self.id_TextField.text, @"password":self.password_TextField.text};
    
    [manager POST:contentURL parameters:bodys progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject : %@", responseObject);
        
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        
        
        if([responseObject[@"stateMsg"] isEqualToString:@"SUCCESS"])
        {
            [alertView showSuccess:self title:@"회원 가입을 축하드립니다!" subTitle:@"보다 좋은 서비스를 지향하겠습니다!" closeButtonTitle:@"확인" duration:0.0f];
            [alertView alertIsDismissed:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            NSDictionary *responseDic = [responseObject objectForKey:@"error"];
            NSInteger errorCode = [[responseDic objectForKey:@"code"] integerValue];
            NSString *errorMsg = [responseDic objectForKey:@"msg"];
            
            if(errorCode == 4001 || errorCode == 4002 || errorCode == 4003 || errorCode == 4004) {
                [alertView showError:self title:@"회원가입 에러" subTitle:[NSString stringWithFormat:@"%@%@",errorMsg,@"\n다시 시도하세요."] closeButtonTitle:@"확인" duration:0.0f];
                [alertView alertIsDismissed:^{
                    [self.id_TextField becomeFirstResponder];
                }];
            } else {
                SCLAlertView *alertView = [[SCLAlertView alloc] init];
                [alertView showError:self title:@"서버 점검" subTitle:@"현재 서버 점검 중입니다.\n서비스 이용에 불편을 드려 죄송합니다.\n신속하게 완료하여 보다 안정적인 서비스가 되도록 하겠습니다." closeButtonTitle:@"앱 종료" duration:0.0f];
                
                [alertView alertIsDismissed:^{
                    NSLog(@"앱 종료");
                    exit(0);
                }];
            }
        }
        
        [SVProgressHUD dismiss];
        
        [self.id_TextField resignFirstResponder];
        [self.password_TextField resignFirstResponder];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"search Error : %@", error);
    }];

}

#pragma - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.35f animations:^{
        self.topConstraint.constant = 70;
        [self.view layoutIfNeeded];
    }];
}

@end
