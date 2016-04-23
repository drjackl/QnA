//
//  PictureCollectionViewController.h
//  QnA
//
//  Created by Jack Li on 4/19/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PictureCollectionViewControllerDelegate <NSObject>
- (void) didGetImage:(UIImage*)image;
@end

@interface PictureCollectionViewController : UICollectionViewController
@property (weak, nonatomic) id<PictureCollectionViewControllerDelegate> delegate;
@end
