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
#import "ProfileViewController.h"


@interface QuestionsViewController () <UITableViewDelegate, UITableViewDataSource>
// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // add observer for reading data (no need to wait till viewDidAppear)
    [[DataSource onlySource].questionsReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
        NSMutableArray* mutableQuestions = [NSMutableArray new];
        for (NSObject* object in snapshot.children) {
            [mutableQuestions addObject:object];
        }
        
        [DataSource onlySource].questions = mutableQuestions;
        
        [self.tableView reloadData];
    }];
    
    // since not a TableVC! (*contains* a TableVC)
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // both needs to be set
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) addQuestionModal {
    // title
    NSString* title = NSLocalizedString(@"Add A Question", @"Title for user to create a question");
    
    // message
    NSAttributedString* exampleText = [[NSAttributedString alloc] initWithString:@"Is Apple a better technology company than Google?" attributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:[UIFont systemFontSize]]}];
    NSString* messageText = [@"Ask the world a question.\nExample: " stringByAppendingString:exampleText.string];
    NSString* message = NSLocalizedString(messageText, @"Description for user to create a question");
    
    // alert controller
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // text field for question
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    // post/cancel buttons
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Post Question", @"Post Question action") style:UIAlertActionStyleDefault handler:^(UIAlertAction*_Nonnull action) {
        
        // posting question to backend
        Firebase* postReference = [[DataSource onlySource].questionsReference childByAutoId];
        NSDictionary* post = [[DataSource onlySource] createPostWithText:alertController.textFields[0].text];
        [postReference setValue:post];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:defaultAction];
    
    // present dialog
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction) unwindBackToQuestionsViewController:(UIStoryboardSegue*)segue {
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
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"simpleQuestionCell" forIndexPath:indexPath];
    QuestionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"questionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    FDataSnapshot* questionData = [DataSource onlySource].questions[indexPath.row];
    //cell.textLabel.text = questionData.value[@"text"];
    cell.questionText.text = questionData.value[@"text"];
    
    //cell.detailTextLabel.text = questionData.value[@"uid"];
    
    NSString* uid = questionData.value[@"uid"];
    if (uid) {
        Firebase* uidReference = [[DataSource onlySource].usersReference childByAppendingPath:uid];
        [uidReference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
            //cell.detailTextLabel.text = snapshot.value[@"email"];
            //cell.detailTextLabel.text = [self createNameFromEmail:snapshot.value[@"email"]];
            [cell.askerButton setTitle:[self createNameFromEmail:snapshot.value[@"email"]] forState:UIControlStateNormal];
            cell.askerButton.userReference = uidReference;
            
            // necessary for new posts since initially set to NO when first created somehow
            cell.askerButton.enabled = YES;
            
            // this won't work since action needs to know the userID
            //[cell.askerButton addTarget:<#(nullable id)#> action:<#(nonnull SEL)#> forControlEvents:<#(UIControlEvents)#>]
            
            [self downloadImageAt:snapshot.value[@"imageUrl"] andSetImageView:cell.userImageView];

        }];
    } else {
        //cell.detailTextLabel.text = @"Anony of House Mous";
        [cell.askerButton setTitle:@"Anony of House Mous" forState:UIControlStateNormal];
        cell.askerButton.enabled = NO;
        
        // if image not set to nil, will have leftover image from previous cell
        cell.userImageView.image = nil;
    }
    
    return cell;
}

- (NSString*) createNameFromEmail:(NSString*)email {
    NSRange atSymbolRange = [email rangeOfString:@"@"];
    NSString* username = [email substringToIndex:atSymbolRange.location];
    NSString* domain = [email substringFromIndex:atSymbolRange.location+atSymbolRange.length];
    
    NSString* houseWithDots = [domain substringToIndex:[domain rangeOfString:@"." options:NSBackwardsSearch].location];
    NSString* house = [houseWithDots stringByReplacingOccurrencesOfString:@"." withString:@" "];
    return [username.capitalizedString stringByAppendingFormat:@" of House %@", house.capitalizedString];
}

- (void) downloadImageAt:(NSString*)imageUrlString andSetImageView:(UIImageView*)imageView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* imageURL = [NSURL URLWithString:imageUrlString];
        NSURLRequest* request = [NSURLRequest requestWithURL:imageURL];
        NSURLResponse* response;
        NSError* error;
        
        NSData* imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (imageData) {
            UIImage* image = [UIImage imageWithData:imageData];
            if (image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                });
            } else {
                NSLog(@"Image downloaded but couldn't be turned into UIImage");
            }
        } else { // no imageData
            NSLog(@"No image was able to be downloaded");
        }
    });
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
    } else if ([segue.identifier isEqualToString:@"viewProfile"]) {
        NSLog(@"segue sender: %@", sender);
        if ([sender isKindOfClass:[UserButton class]]) {
            UserButton* button = sender;
            ((ProfileViewController*)segue.destinationViewController).userReference = button.userReference;
            ((ProfileViewController*)segue.destinationViewController).userName = button.titleLabel.text;
        }
    } else if ([segue.identifier isEqualToString:@"editProfile"]) {
        UINavigationController* navigationController = segue.destinationViewController;
        ((EditProfileViewController*)navigationController.viewControllers[0]).userReference = [DataSource onlySource].loggedInUserReference;
    }
}


@end
