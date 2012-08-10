//
//  PXDetailViewController.h
//  PXAPITest
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PXDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@end
