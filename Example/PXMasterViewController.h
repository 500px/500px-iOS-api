//
//  PXMasterViewController.h
//  PXAPITest
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PXDetailViewController;

@interface PXMasterViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) PXDetailViewController *detailViewController;

-(void)setNewObjects:(NSArray*)objects;

@end
