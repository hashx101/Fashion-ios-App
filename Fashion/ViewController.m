//
//  ViewController.m
//  Fashion
//
//  Created by Ralf Cheung on 2/13/14.
//  Copyright (c) 2014 Ralf Cheung. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CommonCrypto/CommonCryptor.h>
#define kRadius 150
#define kDamping 0.3

@interface ViewController () <FBLoginViewDelegate>
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UILabel *locationLabel;
@property UISnapBehavior *snapBehavior, *s2, *s3;
@property UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, retain) NSDictionary *questions;
@end

@implementation ViewController
@synthesize locationManager;
@synthesize locationLabel;
@synthesize snapBehavior, s2, s3;
@synthesize dynamicAnimator;
@synthesize questions;




- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self getWelcomeNote];

    
    locationLabel = [UILabel new];
    [self.view addSubview:locationLabel];
    [locationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locationLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0f
                                                      constant:15]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locationLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0f
                                                           constant:15]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locationLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:100]];

    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
    
//    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_status", @"read_friendlists", @"user_friends"]];
//    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 5);
//    loginView.delegate = self;
//    
//    [self.view addSubview:loginView];
//    [self queryStatuses];
    

    
    
    
    
//    UIImage *image = [UIImage imageNamed:@"IMGL8036.jpg"];
//    [self imageDump:@"BT2T3788.JPG"];
//    [self getRGB:image x:657 y:347];
    
}

-(void) getWelcomeNote{
    
    NSString *locationString = [NSString stringWithFormat:@"http://www.ralfcheung.com/api.php"];
    
    locationString = [locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:locationString];
    
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configCircles];
            
        });

        questions = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error]: nil;
        if (error) {
            NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
        }
        NSLog(@"%@", questions);

    }];

}

-(void) configCircles{
    

    
    CGPoint center = self.view.center;
    
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(center.x - kRadius, center.y -kRadius, kRadius, kRadius)];
    circle.layer.cornerRadius = kRadius/2;
    circle.backgroundColor = [UIColor redColor];
    [self setTextInCircle:circle text:[questions objectForKey:@"red"]];
    
    
    UIView *c2 =[[UIView alloc] initWithFrame:CGRectMake(center.x + kRadius, center.y -kRadius, kRadius, kRadius)];
    c2.layer.cornerRadius = kRadius/2;
    c2.backgroundColor = [UIColor blueColor];
    [self setTextInCircle:c2 text:[questions objectForKey:@"blue"]];
    

    UIView *c3 =[[UIView alloc] initWithFrame:CGRectMake(center.x, center.y + kRadius, kRadius, kRadius)];
    c3.layer.cornerRadius = kRadius/2;
    c3.backgroundColor = [UIColor greenColor];
    [self setTextInCircle:c3 text:[questions objectForKey:@"green"]];

    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPanning:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer: panGesture];
    
    
    
    [self.view addSubview:circle];
    [self.view addSubview:c2];
    [self.view addSubview:c3];
    

    snapBehavior = [[UISnapBehavior alloc] initWithItem:circle snapToPoint:CGPointMake(center.x - kRadius/2, center.y -kRadius/2)];
    s2 = [[UISnapBehavior alloc] initWithItem:c2 snapToPoint:CGPointMake(center.x + kRadius/2, center.y -kRadius/2)];
    s3 = [[UISnapBehavior alloc] initWithItem:c3 snapToPoint:CGPointMake(center.x, center.y + kRadius/2 - kRadius/10)];
    
    snapBehavior.damping = kDamping;
    s2.damping = kDamping;
    s3.damping = kDamping;

    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    [dynamicAnimator addBehavior:snapBehavior];
    [dynamicAnimator addBehavior:s2];
    [dynamicAnimator addBehavior:s3];
    
}

-(void) setTextInCircle: (UIView *)circle text: (NSString *)text{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kRadius-20, kRadius)];
    label.text = text;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [circle addSubview:label];
}


-(void)detectPanning:(UIPanGestureRecognizer *)gestureRecognizer{
    
    UIView* view = gestureRecognizer.view;
    CGPoint loc = [gestureRecognizer locationInView:view];
    UIView* subview = [view hitTest:loc withEvent:nil];
    [self.view bringSubviewToFront:subview];
    if (subview != self.view) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            
            [dynamicAnimator removeBehavior:s3];
            [dynamicAnimator removeBehavior:s2];
            [dynamicAnimator removeBehavior:snapBehavior];

        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            CGPoint newCenter = subview.center;
            newCenter.x += [gestureRecognizer translationInView:self.view].x;
            newCenter.y += [gestureRecognizer translationInView:self.view].y;
            
            subview.center = newCenter;
            
            [gestureRecognizer setTranslation:CGPointZero inView:self.view];
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            [dynamicAnimator addBehavior:s2];
            [dynamicAnimator addBehavior:s3];
            [dynamicAnimator addBehavior:snapBehavior];
        }
        

    }
    
    
}

-(void)getRGB:(UIImage *)image x:(int)x y:(int)y{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            int byteIndex = (bytesPerRow * j) + i * bytesPerPixel;
            int r = rawData[byteIndex], g = rawData[byteIndex + 1], b = rawData[byteIndex + 2];
            rawData[byteIndex] = MIN(255, (double)r * 0.393 + (double)g * 0.769 + (double)b * 0.189);
            rawData[byteIndex+1] = MIN(255, (double)r * 0.349 + (double)g * 0.686 + (double)b * 0.168);
            rawData[byteIndex+2] = MIN(255, (double)r * 0.272 + (double)g * 0.534 + (double)b * 0.131);
    
        }
    }
    
    
    context = CGBitmapContextCreateWithData(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGImageGetBitmapInfo(imageRef), NULL, 0);
    
    
    
    UIImage *img = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 300, 300)];
    [imageView setImage:img];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    free(rawData);
    CGContextRelease(context);


    
    
}

-(void)imageDump:(NSString*)file
{
    UIImage* image = [UIImage imageNamed:file];
    CGImageRef cgimage = image.CGImage;
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
    
    NSLog(
          @"\n"
          "===== %@ =====\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = 0x%.8X\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n",
          file,
          (int)width,
          (int)height,
          CGImageGetColorSpace(cgimage),
          (int)bpp,
          (int)bpc,
          (int)bpr,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask),
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Little) ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little) ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Big)    ? "YES" : "NO"
          );
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));

    const uint8_t* bytes = [data bytes];
    
    printf("Pixel Data:\n");
//    for(size_t row = 0; row < height; row++)
//    {
//        for(size_t col = 0; col < width; col++)
//        {
//            const uint8_t* pixel =
//            &bytes[row * bpr + col * bytes_per_pixel];
//            
//            printf("(");
//            for(size_t x = 0; x < bytes_per_pixel; x++)
//            {
//                printf("%.2X", pixel[x]);
//                if( x < bytes_per_pixel - 1 )
//                    printf(",");
//            }
//            
//            printf(")");
//            if( col < width - 1 )
//                printf(", ");
//        }
//        
//        printf("\n");
//    }
}


-(void) queryStatuses{

    NSString *query =
//    @"SELECT text, fromid FROM comment WHERE post_id in( SELECT post_id FROM stream WHERE source_id = me() LIMIT 300,100)";
    @"SELECT uid, name, pic_square FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())";
//    @"SELECT message, created_time  FROM stream  WHERE source_id = me() LIMIT 800";
    //501520061 chel
    //662519174 me
//    @"SELECT message FROM stream WHERE filter_key IN (SELECT filter_key FROM stream_filter WHERE uid = me() AND type = 'newsfeed') AND type=46 LIMIT 1000";
    
    NSDictionary *queryParam = @{ @"q": query };

    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              }else{
//                                  NSLog(@"%d", [[result valueForKey:@"data"] count]);
                                  NSLog(@"%@", result);
                              }
                          }];
    
}


-(void)queryDevices{
    NSString *query =
    //    @"SELECT uid, name, pic_square FROM user WHERE is_app_user  AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me())";
    @"SELECT uid, name, about_me, devices FROM user WHERE uid IN "
    @"(SELECT uid2 FROM friend WHERE uid1 = me() ) AND devices != ''";
    
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  //                                  NSLog(@"Result: %@", result);
                                  NSMutableSet *android = [[NSMutableSet alloc] init];
                                  NSMutableSet *iOS = [NSMutableSet new];
                                  
                                  for (NSDictionary *dict in [result objectForKey:@"data"]) {
                                      //                                      NSLog(@"%@\n %@", [dict objectForKey:@"about_me"], [dict objectForKey:@"inspirational_people"]);
                                      for (NSDictionary *dev in [dict objectForKey:@"devices"]) {
                                          NSString *OS = [dev objectForKey:@"os"];
                                          if ([OS isEqualToString:@"Android"]) {
                                              [android addObject:[dict objectForKey:@"name"]];
                                          }
                                          if([OS isEqualToString:@"iOS"]){
                                              [iOS addObject:[dict objectForKey:@"name"]];
                                          }
                                          
                                      }
                                  }
                                  NSLog(@"Android: %lu %@ ",(unsigned long)[android count], android);
                                  NSLog(@"iOS: %lu %@ ", (unsigned long)[iOS count], iOS);
                                  [android intersectSet:iOS];
                                  NSLog(@"Intersect: %lu %@", (unsigned long)[android count], android);
                                  
                              }
                          }];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
     CLPlacemark *pMark = [placemarks lastObject];
     
        NSString *locationString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@",pMark.addressDictionary[@"City"], pMark.ISOcountryCode];

        locationString = [locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSURL *url = [NSURL URLWithString:locationString];


        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            
            NSDictionary *results = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error]: nil;
            if (error) {
                NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
            }
            double temperature = [[results valueForKeyPath:@"main.temp"] doubleValue] - 273;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                locationLabel.text = [NSString stringWithFormat:@"%@ %.0f", pMark.addressDictionary[@"City"], temperature];
            });
            
        }];

        
       
    }];
    
    [locationManager stopUpdatingLocation];
    

}



- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    NSLog(@"%@", [NSString stringWithFormat:@"Hello %@ %@!", user.first_name, user.id]);
}



- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
