//
//  AnswerCell.h
//  QnA
//
//  Created by Jack Li on 5/1/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase.h>

@class AnswerCell;

@protocol AnswerCellDelegate <NSObject>
- (void) cell:(AnswerCell*)cell didFinishUpdatingVote:(int)voteCount;
@end

@interface AnswerCell : UITableViewCell

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel* answerLabel;
@property (weak, nonatomic) IBOutlet UILabel* votesLabel;

@property (nonatomic) Firebase* votesReference;

//@property (weak, nonatomic) UITableView* tableView;
@property (weak, nonatomic) id<AnswerCellDelegate> delegate;

//@property (nonatomic) FDataSnapshot* answerData;

@end
