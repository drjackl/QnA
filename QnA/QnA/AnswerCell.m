//
//  AnswerCell.m
//  QnA
//
//  Created by Jack Li on 5/1/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "AnswerCell.h"
#import "DataSource.h"

@interface AnswerCell ()
@property (nonatomic) int votes;
@end


@implementation AnswerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// could set answerData to be cleaner (rather than setting in tableView delegate method), but it works ok without. votesReference is what's really needed (as implemented below)
//- (void) setAnswerData:(FDataSnapshot*)answerData {

- (void) drawRect:(CGRect)rect {
    [self drawCaret:CaretDirectionBottom];
}

- (void) setVotesReference:(Firebase*)votesReference {
    _votesReference = votesReference;
    
    [votesReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
        self.votes = ((NSNumber*)snapshot.value).intValue;
        
        // necessary now that not constantly observing changes
        self.votesLabel.text = [NSString stringWithFormat:@"%d votes", self.votes];
        
        // when votes had a list of uids of who answered
        //self.votesLabel.text = [NSString stringWithFormat:@"%lu votes", snapshot.childrenCount];
    }];
}

- (IBAction) voteButtonToggled:(UIButton*)sender {
    // flip selected state
    sender.selected = !sender.selected;
    
    
    Firebase* answerVotesReference = [[DataSource onlySource].loggedInUserReference childByAppendingPath:@"answers_voted"];
    Firebase* answerIDReference = [answerVotesReference childByAppendingPath:self.answerID];
    
    // update model here and in FB backend
    if (sender.selected) {
        self.votes++;
        [answerIDReference setValue:self.answerID];
    } else {
        self.votes--;
        [answerIDReference removeValue];
    }
    
    // set value (if using delegate, could've done it there)
    [self.votesReference setValue:[NSNumber numberWithInt:self.votes]];
    
    // use delegate method to have access to tableView
    //[self.delegate cell:self didUpdateVoteOriginalVote:originalVote increasing:sender.isOn votesReference:self.votesReference];
}

@end
