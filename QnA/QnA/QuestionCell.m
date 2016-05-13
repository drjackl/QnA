//
//  QuestionCell.m
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "QuestionCell.h"
#import "PostBubbleView.h"

@implementation QuestionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// draw caret on right side
- (void) drawRect:(CGRect)rect {
    [self drawCaret:CaretDirectionRight];
}

@end
