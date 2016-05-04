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
#import "AnswerCell.h"

@interface AnswersViewController () <AnswerCellDelegate, UITableViewDataSource, UITableViewDelegate> // works without declaration, but declare to autocomplete moveRowAtIndexPath method
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
    
    // update UI - don't forget, this needs to be both here (for first time loading) and setter
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
        for (NSObject* object in snapshot.children) {
            //[mutableAnswers addObject:object];
            [mutableAnswers insertObject:object atIndex:0]; // insert in reverse order
        }
        
        self.answers = mutableAnswers;
        
        [self.answersTableView reloadData];
    }];
    
    // update UI (maybe this isn't necessary if in viewDidLoad)
    //self.questionLabel.text = question.value;
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

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.answers.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    //UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"simpleAnswerCell" forIndexPath:indexPath];
    AnswerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell" forIndexPath:indexPath];
    
    FDataSnapshot* answer = self.answers[indexPath.row];
    //cell.answerData = self.answers[indexPath.row];
    
    // old answer value was just the answer text
    // new answer value is a tuple with text and votes
    cell.answerLabel.text = answer.value[@"text"];
    NSNumber* votes = answer.value[@"votes"];
    cell.votesLabel.text = [votes.stringValue stringByAppendingString:@" votes"];
    
    // cell needs to know votesReference to update votes count when voting
    Firebase* aidReference = [self.answersReference childByAppendingPath:answer.key];
    cell.votesReference = [aidReference childByAppendingPath:@"votes"];
    
    //cell.tableView = tableView;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    FDataSnapshot* answerToMove = self.answers[sourceIndexPath.row];
    [self.answers removeObjectAtIndex:sourceIndexPath.row];
    [self.answers insertObject:answerToMove atIndex:destinationIndexPath.row];
}

- (void) cell:(AnswerCell*)cell didUpdateVoteOriginalVote:(int)originalVote increasing:(BOOL)increasing votesReference:(Firebase *)votesReference {
    NSIndexPath* originalIndexPath = [self.answersTableView indexPathForCell:cell];
    
    int replaceIndex = 0;
    while (replaceIndex < self.answers.count) {
        FDataSnapshot* answerData = self.answers[replaceIndex];
        if ([answerData.value[@"votes"] intValue] <= originalVote-1) {
            break;
        }
        replaceIndex++;
    }
    
    //int replaceIndex = [self findReplaceIndexWithOriginalVote:originalVote increasing:increasing];
    
    // once replaceIndex found, can update votes
//    int vote;
//    if (increasing) {
//        vote = originalVote+1;
//    } else {
//        vote = originalVote-1;
//    }
//    [votesReference setValue:[NSNumber numberWithInt:vote]];
    
    if (replaceIndex != originalIndexPath.row) {
        if (replaceIndex > originalIndexPath.row) {
            replaceIndex--;
        }
        
        [self.answersTableView beginUpdates];
        
        [self.answersTableView moveRowAtIndexPath:originalIndexPath toIndexPath:[NSIndexPath indexPathForRow:replaceIndex inSection:originalIndexPath.section]];
        
        [self.answersTableView endUpdates];
    }
}

- (int) findReplaceIndexWithOriginalVote:(int)originalVote increasing:(BOOL)increasing {
    int replaceIndex = 0;
    
    while (replaceIndex < self.answers.count) {
        FDataSnapshot* answerData = self.answers[replaceIndex];
        int answerVotes = [answerData.value[@"votes"] intValue];
        
        // if increasing, want the first original value index
        if (increasing &&
            answerVotes == originalVote) {
            break;
        }
        
        // if decreasing, want the last original value index
        if (!increasing &&
            answerVotes < originalVote) {
            replaceIndex--; // 1 before the next lesser value
            break;
        }
        
        replaceIndex++;
    }
    
    // if you get to the end (eg, decrementing the last element), it's just the last index  
    if (replaceIndex == self.answers.count) {
        replaceIndex--;
    }
    
    return replaceIndex;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
