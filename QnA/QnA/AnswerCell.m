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
    }];
}

- (IBAction) voteSwitchToggled:(UISwitch*)sender {
    // so it seems switch has already been switched by the time this method is reached
    if (sender.isOn) {
        // increment
        self.votes++;
    } else {
        // decrement
        self.votes--;
    }
    [self.votesReference setValue:[NSNumber numberWithInt:self.votes]];
}

@end
