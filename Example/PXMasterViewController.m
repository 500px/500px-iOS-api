//
//  PXMasterViewController.m
//  PXAPITest
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXMasterViewController.h"

#import "PXDetailViewController.h"

#import <PXAPI/PXAPI.h>

@interface PXMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation PXMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [PXRequest requestForPhotosWithCompletion:^(NSDictionary *results, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (results)
        {
            [self setNewObjects:[results valueForKey:@"photos"]];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log in" style:UIBarButtonItemStyleBordered target:self action:@selector(login)];
        }
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)setNewObjects:(NSArray*)objects
{
    _objects = [NSMutableArray arrayWithArray:objects];
    [self.tableView reloadData];
}

#pragma mark - Custom Methods
-(void)login
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"500px Login" message:@"Enter in your 500px login credentials" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDate *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [object valueForKey:@"name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[PXDetailViewController alloc] initWithNibName:@"PXDetailViewController" bundle:nil];
    }
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *userName = [[alertView textFieldAtIndex:0] text];
    NSString *password = [[alertView textFieldAtIndex:1] text];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [PXRequest authenticateWithUserName:userName password:password completion:^(BOOL success) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (success)
        {
            self.navigationItem.leftBarButtonItem = nil;
            
            [PXRequest requestForCurrentlyLoggedInUserWithCompletion:^(NSDictionary *results, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Hello, %@", [results valueForKeyPath:@"user.firstname"]] message:@"Welcome to the World's Best Photography." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"YEAH!", nil];
                [alert show];
            }];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Login failed" message:@":(" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
    }];
}

@end
