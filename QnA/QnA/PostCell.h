//
//  PostCell.h
//  QnA
//
//  Created by Jack Li on 5/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostBubbleView.h"

typedef NS_ENUM(NSInteger, CaretDirection) {
    CaretDirectionRight,
    CaretDirectionLeft,
    CaretDirectionBottom
};

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PostBubbleView* postBubbleView;

- (void) drawCaret:(CaretDirection)direction;

@end
