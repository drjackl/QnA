//
//  UserButton.h
//  QnA
//
//  Created by Jack Li on 4/28/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase.h>

@interface UserButton : UIButton

@property (nonatomic) Firebase* userReference;

@end
