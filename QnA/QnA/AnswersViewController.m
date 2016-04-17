//
//  AnswersViewController.m
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "AnswersViewController.h"
#import <Firebase.h>

@interface AnswersViewController ()
// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // update UI - don't forget, this needs to be both here (for first time loading) and setter
    // (if this isn't in, question label is still the default ("Question Text"))
    self.questionLabel.text = self.question.value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setQuestion:(FDataSnapshot*)question {
    _question = question;
    
    // set reference here
    
    // update UI (maybe this isn't necessary if in viewDidLoad)
    //self.questionLabel.text = question.value;
}

- (IBAction) addAnswer {
    NSString* title = NSLocalizedString(@"Add An Answer", @"Title for user to create an answer for this question");
    NSString* messageString = [NSString stringWithFormat:@"Give an answer to the question \"%@\"", self.questionLabel.text];
    NSString* message = NSLocalizedString(messageString, @"Directions for user to create an answer for this question");
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Answer", @"Add Answer action") style:UIAlertActionStyleDefault handler:^(UIAlertAction*_Nonnull action) {
        NSLog(@"Pressed Add Answer!");
    }];
    [alertController addAction:defaultAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)dismissAnswers:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// this method NEEDS to have UIStoryboardSegue* as an arg (not an id) or else you can't drag to Exit
- (IBAction) unwindBackToAnswers:(UIStoryboardSegue*)sender {
    
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
