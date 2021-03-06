//
//  MGTwitterEngine+TH.m
//  TwitHunter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "STTwitterOS.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation STTwitterOS

- (BOOL)canVerifyCredentials {
    return YES;
}

- (BOOL)hasAccessToTwitter {
#if TARGET_OS_IPHONE
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
#else
    return YES; // error will be detected later..
#endif
}

- (NSString *)username {
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    ACAccount *twitterAccount = [accounts lastObject];
    return twitterAccount.username;
}

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    if([self hasAccessToTwitter] == NO) {
        NSString *message = @"Twitter is not available.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:NULL
                                       completion:^(BOOL granted, NSError *error) {
                                           
                                           if(granted) {
                                               
                                               NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                                               ACAccount *twitterAccount = [accounts lastObject];
                                               
                                               successBlock(twitterAccount.username);
                                           } else {
                                               errorBlock(error);
                                           }
                                           
                                       }];
}

- (void)requestAccessWithCompletionBlock:(void(^)(ACAccount *twitterAccount))completionBlock errorBlock:(void(^)(NSError *))errorBlock {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(granted) {
                
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                
                // TODO: let the user choose the account he wants
                ACAccount *twitterAccount = [accounts lastObject];
                
                //                id cred = [twitterAccount credential];
                
                completionBlock(twitterAccount);
            } else {
                NSError *e = error;
                if(e == nil) {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Cannot access OS X Twitter account." };
                    e = [NSError errorWithDomain:@"STTwitterOSX" code:0 userInfo:userInfo];
                }
                errorBlock(e);
            }
        }];
    }];
}

- (void)fetchAPIResource:(NSString *)resource
           baseURLString:(NSString *)baseURLString
              httpMethod:(NSInteger)httpMethod
              parameters:(NSDictionary *)params
         completionBlock:(void (^)(id json))completionBlock
              errorBlock:(void (^)(NSError *error))errorBlock {
    
    NSData *mediaData = [params valueForKey:@"media[]"];
    
    NSMutableDictionary *paramsWithoutMedia = [[params mutableCopy] autorelease];
    [paramsWithoutMedia removeObjectForKey:@"media[]"];
    
    [self requestAccessWithCompletionBlock:^(ACAccount *twitterAccount) {
        NSString *urlString = [baseURLString stringByAppendingString:resource];
        NSURL *url = [NSURL URLWithString:urlString];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:httpMethod URL:url parameters:paramsWithoutMedia];
        request.account = twitterAccount;
        
        if(mediaData) {
            [request addMultipartData:mediaData withName:@"media[]" type:@"application/octet-stream" filename:@"media.jpg"];
        }
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if(responseData == nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(nil);
                }];
                return;
            }
            
            NSError *jsonError = nil;
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if(json == nil) {
                
                //                NSString *s = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                //                NSLog(@"-- %@", s);
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonError);
                }];
                return;
            }
            
            /**/
            
            if([json isKindOfClass:[NSArray class]] == NO && [json valueForKey:@"error"]) {
                
                NSString *message = [json valueForKey:@"error"];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
                NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonErrorFromResponse);
                }];
                
                return;
            }
            
            /**/
            
            id jsonErrors = [json valueForKey:@"errors"];
            
            if(jsonErrors != nil && [jsonErrors isKindOfClass:[NSArray class]] == NO) {
                if(jsonErrors == nil) jsonErrors = @"";
                jsonErrors = [NSArray arrayWithObject:@{@"message":jsonErrors, @"code" : @(0)}];
            }
            
            if([jsonErrors count] > 0 && [jsonErrors lastObject] != [NSNull null]) {
                
                NSDictionary *jsonErrorDictionary = [jsonErrors lastObject];
                NSString *message = jsonErrorDictionary[@"message"];
                NSInteger code = [jsonErrorDictionary[@"code"] intValue];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
                NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:userInfo];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonErrorFromResponse);
                }];
                
                return;
            }
            
            /**/
            
            if(json) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock((NSArray *)json);
                }];
                
            } else {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonError);
                }];
            }
        }];
        
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)fetchResource:(NSString *)resource
           HTTPMethod:(NSString *)HTTPMethod
        baseURLString:(NSString *)baseURLString
           parameters:(NSDictionary *)params
        progressBlock:(void (^)(id))progressBlock // TODO: handle progressBlock?
         successBlock:(void (^)(id))successBlock
           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert(([ @[@"GET", @"POST"] containsObject:HTTPMethod]), @"unsupported HTTP method");
    
    NSInteger slRequestMethod = SLRequestMethodGET;
    
    NSDictionary *d = params;
    
    if([HTTPMethod isEqualToString:@"POST"]) {
        if (d == nil) d = @{};
        slRequestMethod = SLRequestMethodPOST;
    }
    
    NSString *baseURLStringWithTrailingSlash = baseURLString;
    if([baseURLString hasSuffix:@"/"] == NO) {
        baseURLStringWithTrailingSlash = [baseURLString stringByAppendingString:@"/"];
    }
    
    [self fetchAPIResource:resource
             baseURLString:baseURLStringWithTrailingSlash
                httpMethod:slRequestMethod
                parameters:d
           completionBlock:successBlock
                errorBlock:errorBlock];
}

@end
