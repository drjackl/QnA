//
//  AnswerCell.h
//  QnA
//
//  Created by Jack Li on 5/1/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase.h>
#import "PostCell.h"
#import "UserButton.h"

@class AnswerCell;

// not using delegate anymore since can just observe query
//@protocol AnswerCellDelegate <NSObject>
//- (void) cell:(AnswerCell*)cell didUpdateVoteOriginalVote:(int)originalVote increasing:(BOOL)increasing votesReference:(Firebase*)votesReference;
//@end

@interface AnswerCell : PostCell

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel* answerLabel;
@property (weak, nonatomic) IBOutlet UserButton* authorButton;
@property (weak, nonatomic) IBOutlet UILabel* votesLabel;
@property (weak, nonatomic) IBOutlet UIButton* voteButton; // expose so can disable if no one logged in

@property (nonatomic) NSString* answerID; // needed to track if a user voted for this answer
@property (nonatomic) Firebase* votesReference;

//@property (weak, nonatomic) UITableView* tableView; // this was wrong, but easy for getting something to quickly work
//@property (weak, nonatomic) id<AnswerCellDelegate> delegate;

// use this property to be cleaner (if don't want to set in tableView)
//@property (nonatomic) FDataSnapshot* answerData;

@end
