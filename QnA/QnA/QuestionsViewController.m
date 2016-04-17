//
//  QuestionsViewController.m
//  QnA
//
//  Created by Jack Li on 4/9/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "QuestionsViewController.h"
#import <Firebase.h>
#import "QuestionCell.h"
#import "DataSource.h"
#import "AnswersViewController.h"

@interface QuestionsViewController () <UITableViewDelegate, UITableViewDataSource>
// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // since not a TableVC! (*contains* a TableVC)
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[DataSource onlySource].questionsReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray* mutableQuestions = [NSMutableArray new];
        for (NSObject *object in snapshot.children) {
            [mutableQuestions addObject:object];
        }
        
        [DataSource onlySource].questions = mutableQuestions;
        
        [self.tableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// numberOfSections defaults to 1
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource onlySource].questions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"simpleQuestionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = ((FDataSnapshot*)[DataSource onlySource].questions[indexPath.row]).value;
    
    return cell;
}

// row (question) selection bring up that question's AnswerVC
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // set the question as selected
    [DataSource onlySource].selectedQuestion = [DataSource onlySource].questions[indexPath.row];
    
    // segue to answerVC
    [self performSegueWithIdentifier:@"answerQuickSegue" sender:self];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


//- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
//    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpleQuestionCell"];
//    //cell.textLabel.text = ;
//    return 100.0;
//}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"answerQuickSegue"]) {
        // prep answersVC and push on nav stack
        ((AnswersViewController*)segue.destinationViewController).question = [DataSource onlySource].selectedQuestion;
        
    }
}


@end
