//
//  AnswerCell.h
//  QnA
//
//  Created by Jack Li on 5/1/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel* answerLabel;
@property (weak, nonatomic) IBOutlet UILabel* votesLabel;

@end
