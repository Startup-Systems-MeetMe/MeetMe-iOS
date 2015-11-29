//
//  SelectContactsViewController.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 28/10/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "SelectContactsViewController.h"
#import <Contacts/Contacts.h>
#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NewMeetingViewController.h"
#import "UIColor+Additions.h"
#import "User.h"
#import "NSString+Additions.h"

static const int NEXT_BUTTON_HEIGHT = 75.f;

@interface SelectContactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) CNContactStore *store;

@end

@implementation SelectContactsViewController

//------------------------------------------------------------------------------------------
#pragma mark - View -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(tappedCancel)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // Init arrays
    self.contactsArray      = [[NSMutableArray alloc] init];
    self.friends            = [[NSMutableArray alloc] init];
    self.selectedContacts   = [[NSMutableArray alloc] init];
    self.selectedIndexPaths = [[NSMutableArray alloc] init];
    
    self.store = [[CNContactStore alloc] init];
    [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        // Return early if not granted access
        //TODO: Alert user
        if (!granted) return;
        
        // Fetch contacts
        [self fetchContacts];
    }];
}

- (void)tappedCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Next button frame
    CGRect bounds = self.myTableView.frame;
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bounds), CGRectGetWidth(bounds), NEXT_BUTTON_HEIGHT)];
    [self.nextButton setBackgroundColor:[UIColor rdvGreenColor]];
    [self.nextButton setImage:[UIImage imageNamed:@"Arrow"] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(goToCreateMeeting) forControlEvents:UIControlEventTouchDown];
    UIView *fakeExtensionView = [[UIView alloc] initWithFrame:CGRectMake(0, NEXT_BUTTON_HEIGHT, CGRectGetWidth(bounds), 50)];
    [fakeExtensionView setBackgroundColor:[UIColor rdvGreenColor]];
    [self.nextButton addSubview:fakeExtensionView];
    [self.view addSubview:self.nextButton];
    [self showNextButton:(self.selectedIndexPaths.count > 0)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.nextButton removeFromSuperview];
    });
}

- (void)goToCreateMeeting
{
    NewMeetingViewController *vc = (NewMeetingViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"newMeetingVC"];
    // Sort selected contacts first
    self.selectedContacts = [NSMutableArray arrayWithArray:[self.selectedContacts
                                                            sortedArrayUsingComparator:^NSComparisonResult(User *a, User *b) {
                                                                return [a.name compare:b.name];
                                                            }]];
    vc.contactsToMeetWith = self.selectedContacts;
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Getting Contacts -
//------------------------------------------------------------------------------------------

/**
 *  Fetches contacts from CNContactStore
 *  and adds them in _contactsArray to be displayed
 *  in the tableview.
 */
- (void)fetchContacts
{
    // Fetch all contacts
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:self.store.defaultContainerIdentifier];
    NSArray *keys = [NSArray arrayWithObjects:
                             CNContactGivenNameKey,
                             CNContactFamilyNameKey,
                             CNContactPhoneNumbersKey,
                             CNContactThumbnailImageDataKey, nil];
    
    // Go back to main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"Loading Contacts"];
        
        // Store all contacts
        _contactsArray = [NSMutableArray arrayWithArray:[self.store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:nil]];
        
        // Remove contacts with no name
        NSMutableArray *toDelete = [NSMutableArray array];
        for (id object in _contactsArray) {
            if ([[object givenName] length] == 0) {
                [toDelete addObject:object];
            }
        }
        [_contactsArray removeObjectsInArray:toDelete];
        
        // ... and sort them
        _contactsArray = [NSMutableArray arrayWithArray:[_contactsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [[a givenName] compare:[b givenName]];
        }]];
        
        [_myTableView reloadData];
        
        // Send Parse the phone numbers
        [self pushContactsToParse];
    });
}

- (void) pushContactsToParse
{
    // Flatten phone numbers first
    // by removing +, (, ), and '1' for US phones
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    for (CNContact *contact in self.contactsArray) {
        if (contact.phoneNumbers.count > 0) {
            for (CNLabeledValue *labeledValue in contact.phoneNumbers) {

                // Add the phone number as a string, without formatting
                CNPhoneNumber *number = [labeledValue value];
                NSString *parsedNum   = [[number stringValue] stringWithoutPhoneFormatting];
                if ([parsedNum length] > 0) {
                    [numbers addObject:parsedNum];
                }
            }
        }
    }
    
    [PFCloud callFunctionInBackground:@"getCommonContacts" withParameters:@{@"phoneNumbers":numbers} block:^(id  _Nullable object, NSError * _Nullable error) {
        
        [SVProgressHUD dismiss];
        
        // TODO: Handle Error
        if (error) return;
        
        // Add contacts in _friends array and reload table
        if ([(NSArray*)object count] > 0) {
            _friends = [NSMutableArray arrayWithArray:object];
            // ... and sort them
            _friends = [NSMutableArray arrayWithArray:[_friends sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [[a objectForKey:@"name"] compare:[b objectForKey:@"name"]];
            }]];
            [_myTableView reloadData];
        }
    }];
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
    UIImageView *checkmarkImageView = (UIImageView*)[cell viewWithTag:102];
    UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:100];
    [profileImageView.layer setCornerRadius:(profileImageView.bounds.size.width/2)];
    [profileImageView setClipsToBounds:YES];
    
    // Section 0: Contacts from Parse
    if (indexPath.section == 0) {

        if (self.friends.count > 0) {
            
            // Contact to display
            NSDictionary *contact = [self.friends objectAtIndex:indexPath.row];
            
            nameLabel.text            = [[contact objectForKey:@"name"] capitalizedString];
            checkmarkImageView.hidden = NO;
            checkmarkImageView.image  = [self.selectedIndexPaths containsObject:indexPath] ? [UIImage imageNamed:@"Checked Active"] : [UIImage imageNamed:@"Checked Inactive"];
            
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
        checkmarkImageView.hidden = YES;
        
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
    
    // Contacts from AddressBook, not RendezVous
    if (indexPath.section == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invite" message:@"Working on adding the option to invite your friends ;-)" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Alright" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // Get checkmark image view
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *checkmarkImageView = (UIImageView*)[cell viewWithTag:102];
    
    // User (de)selected
    User *user = [[User alloc] initFromDictionary:[self.friends objectAtIndex:indexPath.row]];
    
    // Already selected
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [self.selectedIndexPaths removeObject:indexPath];
        
        User *comparedUser;
        for (User *obj in self.selectedContacts) {
            if (obj.phoneNumber == user.phoneNumber) {
                comparedUser = obj;
                break;
            }
        }
        [self.selectedContacts removeObject:comparedUser];
        
        // Animate image change with cross dissolve
        [UIView transitionWithView:checkmarkImageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            checkmarkImageView.image = [UIImage imageNamed:@"Checked Inactive"];
                        } completion:nil];
        
    // Not selected yet
    } else {
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedContacts addObject:user];
        
        // Animate image change with cross dissolve
        [UIView transitionWithView:checkmarkImageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            checkmarkImageView.image = [UIImage imageNamed:@"Checked Active"];
                        } completion:nil];
    }
    
    // Show "next button" if some contacts selected, else hide
    [self showNextButton:(self.selectedIndexPaths.count > 0)];
}

- (void)showNextButton:(BOOL)visible
{
    CGFloat duration = 0.6f;
    CGFloat damping  = 0.4f;
    CGFloat velocity = 0.5f;

    if (visible) {
        
        [UIView animateWithDuration:duration delay:0.f usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            // Re-position button
            CGRect buttonFrame = self.nextButton.frame;
            buttonFrame.origin.y = CGRectGetMaxY(self.myTableView.frame) - NEXT_BUTTON_HEIGHT;
            self.nextButton.frame = buttonFrame;
            
            // Adjust tableview inset
            UIEdgeInsets contentInsets;
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, NEXT_BUTTON_HEIGHT, 0.0);
            self.myTableView.contentInset = contentInsets;
            self.myTableView.scrollIndicatorInsets = contentInsets;
            
        } completion:nil];
    
    } else {
        
        [UIView animateWithDuration:duration delay:0.f usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // Re-position button
            CGRect buttonFrame = self.nextButton.frame;
            buttonFrame.origin.y = CGRectGetMaxY(self.myTableView.frame);
            self.nextButton.frame = buttonFrame;
            
            // Adjust tableview inset
            self.myTableView.contentInset = UIEdgeInsetsZero;
            self.myTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
        } completion:nil];
    }
}

@end
