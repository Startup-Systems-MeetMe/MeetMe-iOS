//
//  SettingsViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 22/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+Additions.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation SettingsViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Tableview -
//------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    if (indexPath.section == 0) {
        [cell.textLabel setText:@"Logout"];
        [cell.textLabel setTextColor:[UIColor rdvIgniterColor]];
        
    } else {
        
        [cell.textLabel setTextColor:[UIColor rdvTertiaryColor]];
        
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"Contact Us"];
        } else {
            [cell.textLabel setText:@"Help"];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Handle Logout
        
    } else {
        
        if (indexPath.row == 0) {
            // Email team

        } else {
            // Show FAQ
        }
    }
}

@end
