//
//  AnswersViewController.h
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FDataSnapshot.h>

//@protocol AnswersViewControllerDelegate <NSObject>
//- (void) didFinishUpdatingVote;
//@end

@interface AnswersViewController : UIViewController

@property (nonatomic) FDataSnapshot* question;

//@property (weak, nonatomic) id<AnswersViewControllerDelegate> delegate;

@end
