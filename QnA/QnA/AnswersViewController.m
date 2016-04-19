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

@interface AnswersViewController () /*<UITableViewDataSource, UITableViewDelegate>*/ // works without declaration
@property (nonatomic) Firebase* answersReference;
@property (nonatomic) NSArray* answers;
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setQuestion:(FDataSnapshot*)question {
    _question = question;
    
    // set reference here
    NSString* allAnswersPath = [question.key stringByAppendingPathComponent:@"answers"]; // id/answers
    self.answersReference = [[DataSource onlySource].questionsReference childByAppendingPath:allAnswersPath]; // "questions/id/answers"
    
    // add read observer right away (if in viewDidAppear, answers would not show)
    [self.answersReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray* mutableAnswers = [NSMutableArray new];
        for (NSObject* object in snapshot.children) {
            [mutableAnswers addObject:object];
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
        [answerReference setValue:alertController.textFields[0].text];
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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"simpleAnswerCell" forIndexPath:indexPath];
    cell.textLabel.text = ((FDataSnapshot*)self.answers[indexPath.row]).value;
    return cell;
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
