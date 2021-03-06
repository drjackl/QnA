//
//  EditProfileViewController.m
//  QnA
//
//  Created by Jack Li on 4/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "ProfileViewController.h"
//#import <Firebase.h>
#import <Cloudinary.h>
#import "DataSource.h"
#import "PictureCollectionViewController.h"

@interface ProfileViewController () <PictureCollectionViewControllerDelegate>
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // load description and download profile pic
    [self loadProfile];
    
    // all below done in storyboard (don't even need IBAction)
//    // allow user to tap on profile pic as alternate way to set pic
//    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage)];
//    [self.profileImageView addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Loading Profile

- (void) loadProfile {
    
    if (self.userReference) {
        
        [self.userReference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
            
            // must check for null value in case a profile was never set, else accessing bad value
            if (snapshot.value != NSNull.null) { // apple doc
                self.navigationItem.title = [[DataSource onlySource] createNameFromEmail:snapshot.value[@"email"]];
                self.descriptionTextView.text = snapshot.value[@"description"];
                [self loadProfilePicture:snapshot.value[@"imageUrl"]]; // method checks if imageID is nil
            }
            
        }];
        
    }
}

- (void) loadProfilePicture:(NSString*)imageURLString {
    if (!imageURLString) { // if no image, do nothing (don't download)
        return;
    }
    
    // otherwise setup url to try and download
//    CLCloudinary* cloudinary = [self createCloudinaryReference]; // storing url, not publicID
//    NSString* imageURLString = publicID;//[cloudinary url:publicID]; // so no need for cloudinary
    NSURL* imageURL = [NSURL URLWithString:imageURLString];
    
    // now download image from url and then set it
    [self downloadPictureAtURL:imageURL];
}

- (void) downloadPictureAtURL:(NSURL*)imageURL {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest* request = [NSURLRequest requestWithURL:imageURL];
        NSURLResponse* response;
        NSError* error;
        NSData* imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // if able to download image
        if (imageData) {
            UIImage* image = [UIImage imageWithData:imageData];
            if (image) {
                // dispatch back to main queue to update UI (else will have warning and will be much delayed)
                // also would be appropriate here if need to archive or notify others (that have UI updates) interested that image has downloaded
                dispatch_async(dispatch_get_main_queue(), ^{
                    // set edit profile image with initial image
                    self.profileImageView.image = image;
                });
            }
        } else { // no imageData
            NSLog(@"Error downloading image: %@", error);
        }
    }); // end dispatch to background to download image
}

#pragma mark - IBAction and Saving Profile

- (IBAction) saveProfile {
    NSDictionary* profile = @{@"description" : self.descriptionTextView.text};
    [[DataSource onlySource].loggedInUserReference updateChildValues:profile]; // better than setValue since won't override photo in case can't save photo (which happens with 4th sample pic)
    
    [self saveProfilePicture];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveProfilePicture {
    // cloudinary must have api_key and api_secret
    CLCloudinary* cloudinary = [self createCloudinaryReference];
    
    CLUploader* uploader = [[CLUploader alloc] init:cloudinary delegate:nil];
    
    NSData* imageData = UIImagePNGRepresentation(self.profileImageView.image);
    // if couldn't turn to PNG, try turning into JPG
    if (!imageData) { // this bit of code hasn't happened yet as far as I can tell
        imageData = UIImageJPEGRepresentation(self.profileImageView.image, 0.5); // least compression/best quality
    }
    
    // upload image data to Cloudinary and save url to Firebase
    // not using this, but if put @"resource_type" is @"raw" must have a file (which we don't have as direct from UIImage)
    // error says must upload either url, file path, or NSData (no UIImage)
    [uploader upload:imageData options:nil withCompletion:^(NSDictionary* successResult, NSString* errorResult, NSInteger code, id context) {
        if (successResult) {
            NSLog(@"Pic upload success!\nid=%@; result=%@", successResult[@"public_id"], successResult);
            
            // on successful upload, save imageURL to Firebase
            [[DataSource onlySource].loggedInUserReference updateChildValues:@{@"imageUrl" : successResult[@"url"]}];
        } else { // failure
            NSLog(@"Pic upload failure :(\nresult=%@, code=%ld", errorResult, code);
        }
    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
        NSLog(@"Pic upload progress: %ld/%ld (%ld)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
    }];
}

- (CLCloudinary*) createCloudinaryReference {
    CLCloudinary* cloudinary = [CLCloudinary new];
    [cloudinary.config setValue:@"dqe5zwgvc" forKey:@"cloud_name"];
    [cloudinary.config setValue:@"837721986796476" forKey:@"api_key"];
    [cloudinary.config setValue:@"zFy8Sc1CXlRDteKVytqcbEFxSi8" forKey:@"api_secret"]; // better to store this on server
    return cloudinary;
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
