//
//  PictureCollectionViewController.m
//  QnA
//
//  Created by Jack Li on 4/19/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "PictureCollectionViewController.h"
#import <Photos/Photos.h>

@interface PictureCollectionViewController ()
@property (nonatomic) PHFetchResult* picturesResult;
@end

@implementation PictureCollectionViewController

static NSString*const reuseIdentifier = @"picCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // This is a mistake here. Do NOT register the class here if you have a storybaord cell
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    //self.navigationItem.title = @"Test";
}

// NOT viewDIDAppear
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // if authorization not determined, request authorization
    if (PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadAssets];
                    [self.collectionView reloadData];
                }); // end dispatch_async
            } // end if authorized to access Photo Library
        }]; // end requestAuthorization block
    }
    
    // else if authorized, just load assets
    else if (PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusAuthorized) {
        [self loadAssets];
    }
}

- (void) loadAssets {
    PHFetchOptions* options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.picturesResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark <UICollectionViewDataSource>

// default is 1 like in table?
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete implementation, return the number of sections
//    return 1;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of items
    return self.picturesResult.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    if (cell.tag != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    PHAsset* asset = self.picturesResult[indexPath.row];
    
    cell.tag = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage*_Nullable result, NSDictionary*_Nullable info) {
        // not sure it's really necessary to check if there's a cell here
        //UICollectionViewCell* cellToUpdate = [collectionView cellForItemAtIndexPath:indexPath];
        
        //if (cellToUpdate) {
            UIImageView* imageView = (UIImageView*)[cell viewWithTag:321];
            imageView.image = result;
        //}
        
    }];

    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
