//
//  QuestionsViewController.m
//  QnA
//
//  Created by Jack Li on 4/9/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "QuestionsViewController.h"
#import <Firebase.h>
#import <FirebaseTableViewDataSource.h>

@interface QuestionsViewController () <UITableViewDelegate>
@property (nonatomic) Firebase* questionsRef;
@property (nonatomic) FirebaseTableViewDataSource* dataSource;
// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Firebase* ref = [[Firebase alloc] initWithUrl:@"https://qna-app.firebaseio.com"];
    Firebase* appRef = [ref childByAppendingPath:@"web/data"];
    self.questionsRef = [appRef childByAppendingPath:@"questions"];
    
    self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:self.questionsRef cellReuseIdentifier:@"simpleQuestionCell" view:self.tableView];
    
    [self.dataSource populateCellWithBlock:^(__kindof UITableViewCell*_Nonnull cell, __kindof NSObject*_Nonnull object) {
        cell.textLabel.text = ((FDataSnapshot*)object).value;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:8.0]; // so this works, seems cell gets reset somehow
    }];
    
    [self.tableView setDataSource:self.dataSource];
    
    //self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
//    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpleQuestionCell"];
//    //cell.textLabel.text = ;
//    return 100.0;
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
