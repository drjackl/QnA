//
//  LoginViewController.m
//  QnA
//
//  Created by Jack Li on 4/8/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "LoginViewController.h"
#import <Firebase.h>
#import <UICKeyChainStore.h>
#import "DataSource.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField* emailField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) login {
    [[DataSource onlySource].reference authUser:self.emailField.text password:self.passwordField.text withCompletionBlock:^(NSError* error, FAuthData* authData) {
        if (error) {
            NSLog(@"Error logging in: %@", error);
        } else {
            NSLog(@"We're logged in!");
            
            [DataSource onlySource].loggedInUserID = authData.uid;
            
            // also save uid as access token so login remembered in future
            [UICKeyChainStore setString:authData.uid forKey:@"access uid token"];
            
            [self showMainQuestions];
        }
    }];
}

- (IBAction) skipLogin {
    [self showMainQuestions];
}

- (void) showMainQuestions {
    [self performSegueWithIdentifier:@"mainQuestions" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
