//
//  QuestionCell.h
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserButton.h"

@interface QuestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* questionText;
@property (weak, nonatomic) IBOutlet UIImageView* userImageView;
//@property (weak, nonatomic) IBOutlet UIButton* askerButton;
//@property (weak, nonatomic) IBOutlet UserButton* askerButton;
@property (weak, nonatomic) IBOutlet UserButton *askerButton;


@end
