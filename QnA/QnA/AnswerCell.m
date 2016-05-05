//
//  AnswerCell.m
//  QnA
//
//  Created by Jack Li on 5/1/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "AnswerCell.h"

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

- (void) setVotesReference:(Firebase*)votesReference {
    _votesReference = votesReference;
    
    [votesReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
        self.votes = ((NSNumber*)snapshot.value).intValue;
        
        // necessary now that not constantly observing changes
        self.votesLabel.text = [NSString stringWithFormat:@"%d votes", self.votes];
    }];
}

- (IBAction) voteSwitchToggled:(UISwitch*)sender {
    // so it seems switch has already been switched by the time this method is reached
    int originalVote = self.votes;
    if (sender.isOn) {
        // increment
        self.votes++;
    } else {
        // decrement
        self.votes--;
    }
    
    //[self.votesReference setValue:[NSNumber numberWithInt:self.votes]];
    
    [self.delegate cell:self didUpdateVoteOriginalVote:originalVote increasing:sender.isOn votesReference:self.votesReference];
    
//    [self.tableView beginUpdates];
//    [self.votesReference setValue:[NSNumber numberWithInt:self.votes]];
//    
//    // get original index path
//    NSIndexPath* originalIndexPath = [self.tableView indexPathForCell:self];
//    
//    // then get index of first value with self.votes-1
////    int i = 0;
////    while (i < self.answers)) {
////        <#statements#>
////    }
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    
//    [self.tableView moveRowAtIndexPath:originalIndexPath toIndexPath:indexPath];
//    [self.tableView endUpdates];
}

@end
