//
//  EditProfileViewController.m
//  QnA
//
//  Created by Jack Li on 4/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Firebase.h>
#import <Cloudinary.h>
#import "DataSource.h"
#import "PictureCollectionViewController.h"

@interface EditProfileViewController () <PictureCollectionViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView* descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView* profileImageView;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage)];
    [self.profileImageView addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tappedImage {
    [self performSegueWithIdentifier:@"picturePicker" sender:self];
}

- (IBAction) saveProfile {
    NSDictionary* profile = @{@"description" : self.descriptionTextView.text};
    [[DataSource onlySource].loggedInUserReference setValue:profile];
    
    [self saveProfilePicture];
}

- (void) saveProfilePicture {
    // cloudinary must have api_key and api_secret
    CLCloudinary* cloudinary = [CLCloudinary new];
    [cloudinary.config setValue:@"dqe5zwgvc" forKey:@"cloud_name"];
    [cloudinary.config setValue:@"837721986796476" forKey:@"api_key"];
    [cloudinary.config setValue:@"zFy8Sc1CXlRDteKVytqcbEFxSi8" forKey:@"api_secret"]; // better to store this on server
    
    CLUploader* uploader = [[CLUploader alloc] init:cloudinary delegate:nil];
    
    NSData* imageData = UIImagePNGRepresentation(self.profileImageView.image);
    // if put @"resource_type" is @"raw" must have a file (which we don't have as direct from UIImage)
    // error says must upload either url, file path, or NSData (no UIImage)
    [uploader upload:imageData options:nil withCompletion:^(NSDictionary* successResult, NSString* errorResult, NSInteger code, id context) {
        if (successResult) {
            NSLog(@"Pic upload success!");
            NSLog(@"id=%@; result=%@", successResult[@"public_id"], successResult);
        } else { // failure
            NSLog(@"Pic upload failure :(");
            NSLog(@"result=%@, code=%ld", errorResult, code);
        }
    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
        NSLog(@"Pic upload progress: %ld/%ld (%ld)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
    }];
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
