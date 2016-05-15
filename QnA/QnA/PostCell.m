//
//  PostCell.m
//  QnA
//
//  Created by Jack Li on 5/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) drawCaret:(CaretDirection)direction {
    CGRect bubbleFrame = [self convertRect:self.postBubbleView.frame fromCoordinateSpace:self.postBubbleView.superview];
    static int offset = 7;
    
    // find the 3 points that make up the caret: line 12 is perpendicular, points 1 & 3 sit on edge of bubble while 2 is the point of the caret
    CGFloat point1X, point1Y, point2X, point2Y, point3X, point3Y;
    if (direction == CaretDirectionRight) {
        point1X = CGRectGetMaxX(bubbleFrame);
        point1Y = CGRectGetMinY(bubbleFrame) + offset;
        
        point2X = point1X + offset;
        point2Y = point1Y;
        
        point3X = point1X;
        point3Y = point2Y + offset;
        
    } else if (direction == CaretDirectionLeft) {
        point1X = CGRectGetMinX(bubbleFrame);
        point1Y = CGRectGetMinY(bubbleFrame) + offset; // same as Right
        
        point2X = point1X - offset;
        point2Y = point1Y; // same as Right
        
        point3X = point1X; // same as Right
        point3Y = point2Y + offset; // same as Right
        
    } else if (direction == CaretDirectionBottom) {
        point1X = CGRectGetMinX(bubbleFrame) + 2*offset;
        point1Y = CGRectGetMaxY(bubbleFrame);
        
        point2X = point1X;
        point2Y = point1Y + offset;
        
        point3X = point1X - offset;
        point3Y = point1Y;
    }
    
    // draw the caret with these 3 points
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, point1X, point1Y);
    CGContextAddLineToPoint(context, point2X, point2Y);
    CGContextAddLineToPoint(context, point3X, point3Y);
    
    CGContextSetFillColorWithColor(context, self.postBubbleView.backgroundColor.CGColor);
    CGContextFillPath(context);
}


- (void) drawRect:(CGRect)rect {
    // Drawing code
    [self drawCaret:CaretDirectionLeft];
}

@end
