//
//  EditProfileViewController.m
//  QnA
//
//  Created by Jack Li on 4/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Firebase.h>
#import "DataSource.h"
#import "PictureCollectionViewController.h"

@interface EditProfileViewController () <PictureCollectionViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) saveProfile {
    NSDictionary* profile = @{@"description" : self.descriptionTextView.text};
    [[DataSource onlySource].loggedInUserReference setValue:profile];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"picturePicker"]) {
        ((PictureCollectionViewController*)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - Picture Collection VC Delegate
- (void) didGetImage:(UIImage*)image {
    self.profileImageView.image = image;
    [self.navigationController popViewControllerAnimated:YES]; // pop off picVC to here editVC
}


@end
