//
//  ProfileViewController.m
//  QnA
//
//  Created by Jack Li on 4/26/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "ProfileViewController.h"
#import <Firebase.h>
#import "DataSource.h"

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void) loadProfile {
//    if (self.userID) {
//        
//        Firebase* userProfileReference = [[DataSource onlySource].usersReference childByAppendingPath:self.userID];
//        
//        [userProfileReference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
//            
//            // must check for null value in case a profile was never set, else accessing bad value
//            if (snapshot.value != NSNull.null) { // apple doc
//                self.descriptionTextView.text = snapshot.value[@"description"];
//                [self loadProfilePicture:snapshot.value[@"imageUrl"]]; // method checks if imageID is nil
//            }
//            
//        }];
//        
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
