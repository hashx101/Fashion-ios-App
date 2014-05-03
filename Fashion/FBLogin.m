//
//  FBLogin.m
//  Fashion
//
//  Created by Ralf Cheung on 2/13/14.
//  Copyright (c) 2014 Ralf Cheung. All rights reserved.
//

#import "FBLogin.h"
@implementation FBLogin
@synthesize accountStore;
@synthesize userName;


- (BOOL)userHasAccessToTwitter
{
    accountStore = [[ACAccountStore alloc] init];
    
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}




@end
