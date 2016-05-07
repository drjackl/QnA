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
- (void) cell:(AnswerCell*)cell didUpdateVoteOriginalVote:(int)originalVote increasing:(BOOL)increasing votesReference:(Firebase*)votesReference;
@end

@interface AnswerCell : UITableViewCell

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel* answerLabel;
@property (weak, nonatomic) IBOutlet UILabel* votesLabel;
@property (weak, nonatomic) IBOutlet UISwitch* votesSwitch; // expose so can disable if no one logged in

@property (nonatomic) NSString* answerID;
@property (nonatomic) Firebase* votesReference;

//@property (weak, nonatomic) UITableView* tableView;
@property (weak, nonatomic) id<AnswerCellDelegate> delegate;

// use this property to be cleaner (if don't want to set in tableView)
//@property (nonatomic) FDataSnapshot* answerData;

@end
