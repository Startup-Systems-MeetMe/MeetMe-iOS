//
//  Meeting.h
//  MeetMe
//
//  Created by Anas Bouzoubaa on 01/12/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meeting : NSObject

- (id)initWithDictionary;

@property (strong, nonatomic) NSString *name;
//@property (strong, nonatomic) NSString *name;

@end
