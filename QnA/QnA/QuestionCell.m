//
//  QuestionCell.m
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "QuestionCell.h"
#import "PostBubbleView.h"

@interface QuestionCell ()
@property (weak, nonatomic) IBOutlet PostBubbleView* postBubbleView;
@end

@implementation QuestionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextMoveToPoint(context, 0, 0);
    //CGContextAddLineToPoint(context, 200, 300);
    
    // point 1 to 2 is perpendicular with chat window, 2 points to pic
    // must be sure to convert to this cell's (self) coordinates
    CGRect bubbleFrame = [self convertRect:self.postBubbleView.frame fromCoordinateSpace:self.postBubbleView.superview];//self.postBubbleView.frame;
    static int offset = 7;
    CGContextMoveToPoint(context, CGRectGetMaxX(bubbleFrame),
                         CGRectGetMinY(bubbleFrame) + offset);
    CGContextAddLineToPoint(context, CGRectGetMaxX(bubbleFrame) + offset,
                            CGRectGetMinY(bubbleFrame) + offset);
    //CGContextAddLineToPoint(context, 100, 100); // for debugging
    
    // point 3 is back to chat window
    CGContextAddLineToPoint(context, CGRectGetMaxX(bubbleFrame),
                            CGRectGetMinY(bubbleFrame) + 2*offset);
    
    //CGContextStrokePath(context); // initial example
    CGContextSetFillColorWithColor(context, self.postBubbleView.backgroundColor.CGColor);
    CGContextFillPath(context);
}

@end
