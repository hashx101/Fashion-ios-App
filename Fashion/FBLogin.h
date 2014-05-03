//
//  FBLogin.h
//  Fashion
//
//  Created by Ralf Cheung on 2/13/14.
//  Copyright (c) 2014 Ralf Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface FBLogin : NSObject
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSString *userName;

@end
