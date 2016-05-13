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
#import "ProfileViewController.h"

@interface AnswersViewController () </*AnswerCellDelegate,*/ UITableViewDataSource, UITableViewDelegate> // works without declaration, but declare to autocomplete moveRowAtIndexPath method
@property (nonatomic) Firebase* answersReference;
@property (nonatomic) NSMutableArray* answers;
// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet UserButton* authorButton;
@property (weak, nonatomic) IBOutlet UITableView* answersTableView;
@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // apparently doesn't need to be in setter, just here
    // (if this isn't in, question label is still the default ("Question Text"))
    self.questionLabel.text = self.question.value[@"text"];
    
    //self.navigationItem.title = [DataSource onlySource].selectedQuestion.value[@"uid"];
    NSString* questionAuthorUID = [DataSource onlySource].selectedQuestion.value[@"uid"];
    if (questionAuthorUID) { // must do nil check, else runtime error
        Firebase* questionAuthorReference = [[DataSource onlySource].usersReference childByAppendingPath:questionAuthorUID];
        
        // also need segue in storyboard (or here)
        self.authorButton.userReference = questionAuthorReference;
        
        [questionAuthorReference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
            NSString* authorName = [[DataSource onlySource] createNameFromEmail:snapshot.value[@"email"]];
            self.navigationItem.title = [authorName stringByAppendingString:@" asks ..."];
            
            [self downloadAndSetProfileImageAtURL:snapshot.value[@"imageUrl"]];
        }];
    }
    
    self.answers = [NSMutableArray array]; // no longer setting a new array in setValue, so must initialize
    
    // hooked these up in storyboard
    //self.answersTableView.dataSource = self;
    //self.answersTableView.delegate = self;
    
    // necessary for packing row height
    self.answersTableView.estimatedRowHeight = 50;
    self.answersTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void) downloadAndSetProfileImageAtURL:(NSString*)imageUrlString {
    if (imageUrlString) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL* url = [NSURL URLWithString:imageUrlString];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];

            NSURLResponse* response; NSError* error;
            
            // try to download imageData
            NSData* imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage* image = [UIImage imageWithData:imageData];
                if (image) {
                    
                    // set the image
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.authorButton setImage:image forState:UIControlStateNormal];
                    });
                }
            }
        });
    }
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
    
    // sort according to number of votes (reverse of query)
    FQuery* queryReference = [self.answersReference queryOrderedByChild:@"votes"];
    
    // syncing done via ChildAdded (not Value) observing now
    // add read observer right away (if in viewDidAppear, answers would not show)
    // if there's a prevKey, insert at that index, else insert at end
    [queryReference observeEventType:FEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FDataSnapshot* snapshot, NSString* prevKey) {
        Answer* answer = [[Answer alloc] initWithText:snapshot.value[@"text"] voteCount:[snapshot.value[@"votes"] intValue] answerID:snapshot.key];
        
        if (prevKey) {
            // findIndexPath finds in order of self.answers, not queryReference
            NSIndexPath* indexPath = [self findIndexPathOfKey:prevKey];
            [self.answers insertObject:answer atIndex:indexPath.row];
        } else {
            // if prevKey null, this item is first item or last item of self.answers
            [self.answers addObject:answer];
        }
        
        // don't forget to refresh
        [self.answersTableView reloadData];
    }];
    
    // when an answer is moved (when its vote is changed and causes a resorting), show move animation and change the model as well
    [queryReference observeEventType:FEventTypeChildMoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot* snapshot, NSString* prevKey) {
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
        if ([key isEqualToString:((Answer*)self.answers[i]).answerID]) {
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
        
        // posting answer to backend (answerValue used to have one value; before that, just the answer text itself)
        Firebase* answerReference = [self.answersReference childByAutoId];
        NSDictionary* answerValue;
        
        // if logged in, add logged in user as author (uid)
        if ([DataSource onlySource].loggedInUserID) {
            answerValue = @{@"text" : alertController.textFields[0].text,
                            @"votes" : @0, // new value: answer and votes tuple
                            @"uid" : [DataSource onlySource].loggedInUserID};
        } else { // else don't
            answerValue = @{@"text" : alertController.textFields[0].text,
                            @"votes" : @0}; // new value: answer and votes tuple
        }
        [answerReference setValue:answerValue];
        
        // used to update self.answers here since wasn't syncing before (only observed first time to set self.answers initially)
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
    // using AnswerCell, not UITableViewCell
    AnswerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell" forIndexPath:indexPath];
    
    // previously just stored the FDataSnapshot
    Answer* answer = self.answers[indexPath.row];
    
    // old answer value was just the answer text
    // new answer value is a tuple with text and votes
    cell.answerLabel.text = answer.text;//answer.value[@"text"];
    
    // need to set up authorButton just like in questions
    //cell.authorButton.userReference = [[DataSource onlySource].usersReference childByAppendingPath:answer.uid];
    
    
    //NSNumber* votes = answer.value[@"votes"];
    //cell.votesLabel.text = [votes.stringValue stringByAppendingString:@" votes"];
    int votes = answer.voteCount;//s.count;
    cell.votesLabel.text = [NSString stringWithFormat:@"%d votes", votes];
    
    // cell needs to know votesReference to update votes count when voting
    //Firebase* aidReference = [self.answersReference childByAppendingPath:answer.key];
    Firebase* aidReference = [self.answersReference childByAppendingPath:answer.answerID];
    cell.votesReference = [aidReference childByAppendingPath:@"votes"];
    cell.answerID = answer.answerID;
    
    if ([DataSource onlySource].loggedInUserID) {
        // if logged in user voted for this answer
        //if ([self loggedInUserVotedFor:cell.votesReference]) {
        //if (answer.votes[[DataSource onlySource].loggedInUserID]) {
        if ([DataSource onlySource].answersVotedFor[answer.answerID]) {
            cell.votesSwitch.on = YES;
        } else {
            cell.votesSwitch.on = NO;
        }
    } else { // disallow voting if not logged in
        cell.votesSwitch.enabled = NO;
    }
    
    
    //cell.tableView = tableView; // passing VCs or tableViews not right, breaking MVC
    //cell.delegate = self; // not necessary if using FB
    
    return cell;
}

// this doesn't work since the block doesn't execute synchronously
//- (BOOL) loggedInUserVotedFor:(Firebase*)votesReference {
//    __block BOOL voted = NO;
//    [votesReference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
//        for (FDataSnapshot* uidVoted in snapshot.children) {
//            if ([uidVoted.key isEqualToString:[DataSource onlySource].loggedInUserID]) {
//                voted = YES;
//                break;
//            }
//        }
//    }];
//    return voted;
//}

// called manually (since user can't reorder table manually)
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //FDataSnapshot* answerToMove = self.answers[sourceIndexPath.row];
    Answer* answerToMove = self.answers[sourceIndexPath.row];
    [self.answers removeObjectAtIndex:sourceIndexPath.row];
    [self.answers insertObject:answerToMove atIndex:destinationIndexPath.row];
}


//#pragma mark - AnswerCell delegate methods

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UserButton class]]) {
        ((ProfileViewController*)segue.destinationViewController).userReference = ((UserButton*)sender).userReference;
    }
}


@end
