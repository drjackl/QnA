//
//  AnswerCell.h
//  QnA
//
//  Created by Jack Li on 5/1/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase.h>

@interface AnswerCell : UITableViewCell

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel* answerLabel;
@property (weak, nonatomic) IBOutlet UILabel* votesLabel;

@property (nonatomic) Firebase* votesReference;

//@property (nonatomic) FDataSnapshot* answerData;

@end
