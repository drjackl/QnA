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
//    _answerData = answerData;
//    
//    self.answerLabel.text = answerData.value[@"text"];
//    self.votesLabel.text = answerData.value[@"votes"];
//    self.votesReference = 
//}

//// won't work as can't just set answerID since need the aidReference too
//- (void) setAnswerID:(NSString*)answerID {
//    Firebase* aidReference = [self.answersReference childByAppendingPath:answer.uid];
//    cell.votesReference = [aidReference childByAppendingPath:@"votes"];
//}

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

- (IBAction) voteSwitchToggled:(UISwitch*)sender {
    // so it seems switch has already been switched by the time this method is reached
    //Firebase* idVoteReference = [self.votesReference childByAppendingPath:[DataSource onlySource].loggedInUserID];
//    if (sender.isOn) {
//        [answerVotesReference setValue:[DataSource onlySource].loggedInUserID];
//    } else {
//        [answerVotesReference removeValue];
//    }

    //int originalVote = self.votes;
    Firebase* answerVotesReference = [[DataSource onlySource].loggedInUserReference childByAppendingPath:@"answers_voted"];
    Firebase* answerIDReference = [answerVotesReference childByAppendingPath:self.answerID];
    if (sender.isOn) {
        self.votes++;
        [answerIDReference setValue:self.answerID];
    } else {
        self.votes--;
        [answerIDReference removeValue];
    }
    
    // wait to set value (though if not observing, shouldn't matter when this is done anymore)
    [self.votesReference setValue:[NSNumber numberWithInt:self.votes]];
    
    // use delegate method to have access to tableView
    //[self.delegate cell:self didUpdateVoteOriginalVote:originalVote increasing:sender.isOn votesReference:self.votesReference];
}

@end
