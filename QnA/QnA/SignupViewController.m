//
//  SignupViewController.m
//  QnA
//
//  Created by Jack Li on 4/8/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "SignupViewController.h"
#import <Firebase.h>

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) signMeUp {
    Firebase* reference = [[Firebase alloc] initWithUrl:@"https://qna-app.firebaseio.com"];
    [reference createUser:self.emailField.text password:self.passwordField.text withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error signing up: %@", error);
        } else {
            NSLog(@"We signed up!");
        }
    }];
}

- (IBAction) gotoLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
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
