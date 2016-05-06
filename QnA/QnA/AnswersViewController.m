//
//  AnswersViewController.m
//  QnA
//
//  Created by Jack Li on 4/10/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "AnswersViewController.h"
#import <Firebase.h>
#import "DataSource.h"
#import "Answer.h"
#import "AnswerCell.h"

@interface AnswersViewController () </*AnswerCellDelegate,*/ UITableViewDataSource, UITableViewDelegate> // works without declaration, but declare to autocomplete moveRowAtIndexPath method
@property (nonatomic) Firebase* answersReference;
@property (nonatomic) NSMutableArray* answers;
// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet UITableView* answersTableView;
@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // apparently doesn't need to be in setter, just here
    // (if this isn't in, question label is still the default ("Question Text"))
    self.questionLabel.text = self.question.value[@"text"];
    
    // hooked these up in storyboard
    //self.answersTableView.dataSource = self;
    //self.answersTableView.delegate = self;
    
    // necessary for packing row height
    self.answersTableView.estimatedRowHeight = 50;
    self.answersTableView.rowHeight = UITableViewAutomaticDimension;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setQuestion:(FDataSnapshot*)question {
    _question = question;
    
    // set reference here
    NSString* allAnswersPath = [question.key stringByAppendingPathComponent:@"answers"]; // qid/answers
    self.answersReference = [[DataSource onlySource].questionsReference childByAppendingPath:allAnswersPath]; // "questions/qid/answers"
    
    // sort according to number of votes
    FQuery* queryReference = [self.answersReference queryOrderedByChild:@"votes"];
    
    // add read observer right away (if in viewDidAppear, answers would not show)
    [queryReference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray* mutableAnswers = [NSMutableArray new];
        for (FDataSnapshot* data in snapshot.children) {
            // before answers were ordered, just added to end
            //[mutableAnswers addObject:object];
            
            // before using Answer array
            //[mutableAnswers insertObject:data atIndex:0]; // insert in reverse order
            
            Answer* answer = [[Answer alloc] initWithText:data.value[@"text"] voteCount:[data.value[@"votes"] intValue] uid:data.key];
            [mutableAnswers insertObject:answer atIndex:0]; // insert in reverse order
        }
        
        self.answers = mutableAnswers;
        
        [self.answersTableView reloadData];
    }];
    
    // still a problem since this is called the first time as well
//    [queryReference observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot) {
//
//        // since new answer just add it to end
//        Answer* answer = [[Answer alloc] initWithText:snapshot.value[@"text"] voteCount:[snapshot.value[@"votes"] intValue] uid:snapshot.key];
//        [self.answers addObject:answer];
//        
//        [self.answersTableView reloadData];
//    }];
    
    // had a problem with this method called multiple times per move
//    [queryReference observeEventType:FEventTypeChildMoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
//        NSIndexPath* oldIndexPath = [self findIndexPathOfKey:prevKey];
//        NSIndexPath* newIndexPath = [self findIndexPathOfKey:snapshot.key];
//        if (oldIndexPath.row < newIndexPath.row) {
//            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row-1 inSection:newIndexPath.section];
//        }
//        [self.answersTableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
//    }];
    [queryReference observeEventType:FEventTypeChildMoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        NSLog(@"Moved snapshot: %@, from prevKey: %@", snapshot, prevKey);
        
        NSIndexPath* oldIndexPath = [self findIndexPathOfKey:snapshot.key];
        
        NSIndexPath* newIndexPath;
        if (prevKey) {
            newIndexPath = [self findIndexPathOfKey:prevKey];
            
            // adjust for decrement:
            // if moving to higher index, means decrementing vote count, so subtract 1 to account for removed object
            if (newIndexPath.row > oldIndexPath.row) {
                newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row-1 inSection:newIndexPath.section];
            }
        } else {
            // if prevKey nil, must be decrementing and no need to adjust since nil means last value (smallest vote count)
            newIndexPath = [NSIndexPath indexPathForRow:self.answers.count-1 inSection:0];
        }
        
        [self.answersTableView beginUpdates];
        
        // this does the actual animation
        [self.answersTableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
        
        // this updates the model (implemented delegate method above)
        [self tableView:self.answersTableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
        
        [self.answersTableView endUpdates];
    }];
    
    // update UI (maybe this isn't necessary if in viewDidLoad)
    //self.questionLabel.text = question.value;
}

- (NSIndexPath*) findIndexPathOfKey:(NSString*)key {
    for (int i = 0; i < self.answers.count; i++) {
        if ([key isEqualToString:((Answer*)self.answers[i]).uid]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

- (IBAction) addAnswer {
    NSString* title = NSLocalizedString(@"Add An Answer", @"Title for user to create an answer for this question");
    NSString* messageString = [NSString stringWithFormat:@"Give an answer to the question:\n\"%@\"", self.questionLabel.text];
    NSString* message = NSLocalizedString(messageString, @"Directions for user to create an answer for this question");
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // text field for entering answer
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Post Answer", @"Post Answer action") style:UIAlertActionStyleDefault handler:^(UIAlertAction*_Nonnull action) {
        
        // posting answer to backend
        Firebase* answerReference = [self.answersReference childByAutoId];
        NSDictionary* answerValue = @{@"text" : alertController.textFields[0].text,
                                      @"votes" : @0}; // new value: answer and votes tuple
        //[answerReference setValue:alertController.textFields[0].text]; // old value: ans text
        [answerReference setValue:answerValue];
        
        // sync model in app (since not syncing with query)
        Answer* answer = [[Answer alloc] initWithText:answerValue[@"text"] voteCount:0 uid:answerReference.key];
        [self.answers addObject:answer];
        [self.answersTableView reloadData];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:defaultAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)dismissAnswers:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// this method NEEDS to have UIStoryboardSegue* as an arg (not an id) or else you can't drag to Exit
- (IBAction) unwindBackToAnswers:(UIStoryboardSegue*)segue {
}


#pragma mark - UITableView data source and delegate methods

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.answers.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    //UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"simpleAnswerCell" forIndexPath:indexPath];
    AnswerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell" forIndexPath:indexPath];
    
    //cell.answerData = self.answers[indexPath.row];
    //FDataSnapshot* answer = self.answers[indexPath.row];
    Answer* answer = self.answers[indexPath.row];
    
    // old answer value was just the answer text
    // new answer value is a tuple with text and votes
    cell.answerLabel.text = answer.text;//answer.value[@"text"];
    //NSNumber* votes = answer.value[@"votes"];
    //cell.votesLabel.text = [votes.stringValue stringByAppendingString:@" votes"];
    int votes = answer.voteCount;
    cell.votesLabel.text = [NSString stringWithFormat:@"%d votes", votes];
    
    // cell needs to know votesReference to update votes count when voting
    //Firebase* aidReference = [self.answersReference childByAppendingPath:answer.key];
    Firebase* aidReference = [self.answersReference childByAppendingPath:answer.uid];
    cell.votesReference = [aidReference childByAppendingPath:@"votes"];
    
    //cell.tableView = tableView;
    //cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //FDataSnapshot* answerToMove = self.answers[sourceIndexPath.row];
    Answer* answerToMove = self.answers[sourceIndexPath.row];
    [self.answers removeObjectAtIndex:sourceIndexPath.row];
    [self.answers insertObject:answerToMove atIndex:destinationIndexPath.row];
}


#pragma mark - AnswerCell delegate methods

//- (void) cell:(AnswerCell*)cell didUpdateVoteOriginalVote:(int)originalVote increasing:(BOOL)increasing votesReference:(Firebase*)votesReference {
//    NSIndexPath* originalIndexPath = [self.answersTableView indexPathForCell:cell];
//    
//    int replaceIndex = [self findReplaceIndexWithOriginalVote:originalVote increasing:increasing];
//    
//    // once replaceIndex found, can update votes
//    int vote;
//    if (increasing) {
//        vote = originalVote+1;
//    } else {
//        vote = originalVote-1;
//    }
//    [votesReference setValue:[NSNumber numberWithInt:vote]];
//    
//    //FDataSnapshot* answerData = self.answers[originalIndexPath.row];
//    //answerData.value[@"votes"];
//    Answer* answer = self.answers[originalIndexPath.row];
//    answer.voteCount = vote;
//    
//    if (replaceIndex != originalIndexPath.row) {
//        // this is wrong because if replaceIndex greater (decrementing), you put it one *after* the last, so decrementing replaceIndex puts it one off
////        if (replaceIndex > originalIndexPath.row) {
////            replaceIndex--;
////        }
//        
//        NSIndexPath* replaceIndexPath = [NSIndexPath indexPathForRow:replaceIndex inSection:originalIndexPath.section];
//        
//        
//        [self.answersTableView beginUpdates];
//        
//        // this does the actual animation
//        [self.answersTableView moveRowAtIndexPath:originalIndexPath toIndexPath:replaceIndexPath];
//        
//        // this updates the model (implemented delegate method above)
//        [self tableView:self.answersTableView moveRowAtIndexPath:originalIndexPath toIndexPath:replaceIndexPath];
//        
//        [self.answersTableView endUpdates];
//    }
//}

// replaceIndex is first index with originalVoteCount if increasing, or last index with originalVoteCount if decreasing
//- (int) findReplaceIndexWithOriginalVote:(int)originalVote increasing:(BOOL)increasing {
//    int replaceIndex = 0;
//    
//    while (replaceIndex < self.answers.count) {
//        //FDataSnapshot* answerData = self.answers[replaceIndex];
//        Answer* answer = self.answers[replaceIndex];
//        //int answerVotes = [answerData.value[@"votes"] intValue];
//        int answerVotes = answer.voteCount;
//        
//        // if increasing, want the first original value index
//        if (increasing &&
//            answerVotes == originalVote) {
//            break;
//        }
//        
//        // if decreasing, want the last original value index
//        if (!increasing &&
//            answerVotes < originalVote) {
//            replaceIndex--; // 1 before the next lesser value
//            break;
//        }
//        
//        replaceIndex++;
//    }
//    
//    // if you get to the end (eg, decrementing the last element), it's just the last index  
//    if (replaceIndex == self.answers.count) {
//        replaceIndex--;
//    }
//    
//    return replaceIndex;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
