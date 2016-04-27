//
//  EditProfileViewController.h
//  QnA
//
//  Created by Jack Li on 4/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController

// IBOutlets
@property (weak, nonatomic) IBOutlet UITextView* descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView* profileImageView;

- (void) loadProfilePicture:(NSString*)imageURLString;

@end
