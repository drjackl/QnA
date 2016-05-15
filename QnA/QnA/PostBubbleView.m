//
//  PostBubbleView.m
//  QnA
//
//  Created by Jack Li on 5/11/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "PostBubbleView.h"

@implementation PostBubbleView

// this initializer not used, so not needed
//- (instancetype) initWithFrame:(CGRect)frame {


// all PostBubbleView does is create a rounded rectangle of its view rectangle (caret drawn in table cells)
- (instancetype) initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

/* // moved to PostCell
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void) drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 200, 300);
    
    CGContextStrokePath(context);
}
*/

@end
