//
//  FavoritesViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 29/11/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "FavoritesViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Contacts/Contacts.h>
#import "Contacts.h"
#import <Parse/Parse.h>

@interface FavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init arrays
    self.contactsArray      = [[NSMutableArray alloc] init];
    self.friends            = [[NSMutableArray alloc] init];
    
    [self fetchContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchContacts
{
    // Go back to main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"Loading Contacts"];
        
        // Get contacts access
        [[Contacts sharedInstance] askForContactsAccess:^(BOOL granted) {
            
            if (!granted) return;
            
            // Then fetch all contacts
            [[Contacts sharedInstance] fetchContactsFromPhone:^(NSArray *phoneContacts) {
                
                _contactsArray = [NSMutableArray arrayWithArray:phoneContacts];
                [_myTableView reloadData];
                
                // Send Parse the phone numbers
                [[Contacts sharedInstance] fetchContactsFromParse:^(NSArray *parseContacts) {
                    _friends = [NSMutableArray arrayWithArray:parseContacts];
                    
                    [SVProgressHUD dismiss];
                    [_myTableView reloadData];
                }];
            }];
        }];
    });
}

//------------------------------------------------------------------------------------------
#pragma mark - UITableView -
//------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return self.friends.count;
    else return self.contactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue prototype cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:101];
    UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:100];
    [profileImageView.layer setCornerRadius:(profileImageView.bounds.size.width/2)];
    [profileImageView setClipsToBounds:YES];
    
    // Section 0: Contacts from Parse
    if (indexPath.section == 0) {
        
        if (self.friends.count > 0) {
            
            // Contact to display
            NSDictionary *contact = [self.friends objectAtIndex:indexPath.row];
            
            nameLabel.text            = [[contact objectForKey:@"name"] capitalizedString];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            // Fetch image on background thread
            [(PFFile*)[contact objectForKey:@"profilePicture"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (!error) {
                    profileImageView.image = [UIImage imageWithData:data];
                }
            } progressBlock:nil];
        }
        
    // Section 1: Contacts from Address Book
    } else {
        
        CNContact *contact = (CNContact*)[self.contactsArray objectAtIndex:indexPath.row];
        
        nameLabel.text            = [NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName];
        UIImage *image            = [UIImage imageWithData:[contact valueForKey:@"thumbnailImageData"]];
        profileImageView.image    = image ?: [UIImage imageNamed:@"No-Avatar"];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.friends.count > 0 ? @"Contacts in RendezVous" : @"";
    } else {
        return self.contactsArray.count > 0 ? @"Contacts on Phone" : @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
