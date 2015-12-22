//
//  ViewController.m
//  SampleAppObjc
//
//  Created by Markus Gasser on 26.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "ObjcViewController.h"
#import "ObjcImageCell.h"

@import Matisse;



@interface ObjcViewController ()

@property (nonatomic, readonly) CGFloat itemSize;
@property (nonatomic, readonly) NSArray<NSURL*> *imageURLs;

@end

@implementation ObjcViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _itemSize = 150.0f;
    _imageURLs = @[
        [NSURL URLWithString:@"https://artseer.files.wordpress.com/2014/04/050rt_1.jpg"],
        [NSURL URLWithString:@"https://worldonaforkdotcom.files.wordpress.com/2013/10/untitled-126.jpg"],
        [NSURL URLWithString:@"https://bellaremyphotography.files.wordpress.com/2015/02/bma7feb15-01118.jpg"],
    ];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat itemsPerRow = (CGFloat)floorf(self.view.bounds.size.width / self.itemSize);
    CGFloat exactItemSize = (CGFloat)floorf(self.view.bounds.size.width / itemsPerRow);
    
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = CGSizeMake(exactItemSize, exactItemSize);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ObjcImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSURL *url = self.imageURLs[indexPath.row % self.imageURLs.count];
    
    [MTSMatisse load:url].resizeTo(CGSizeMake(self.itemSize, self.itemSize), UIViewContentModeScaleAspectFill).showIn(cell.imageView);
    
    return cell;
}

@end
