//
//  RequestsViewController.m
//  Playground
//
//  Created by Pankaj Nathani on 07/05/18.
//  Copyright © 2018 Pankaj Nathani. All rights reserved.
//

#import "NLRequestDetailViewController.h"
#import "NetRecorder.h"
#import "NLConstants.h"
#import "ResponseBodyTableViewCell.h"

#define REQ_URL @"URL"
#define REQ_TYPE @"HTTP type"
#define REQ_HEADERS @"Request Headers"
#define REQ_TIME @"Request time"
#define REQ_STATUS @"Request status"

#define RES_CODE @"HTTP Response code"
#define RES_TIME @"Response Time"
#define RES_HEADERS @"Response Headers"
#define REQ_BODY @"Request Body"
#define RES_BODY @"Response Body"

#define GEN_DURATION @"Roundtrip duration"
#define REQ_SIZE @"Request Size"
#define RES_SIZE @"Response Size"

@interface NLRequestDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* detailsArray;
@property NSURLResponse* response;
@property NSHTTPURLResponse* httpResponse;
@property NSData* data;
@property NSError* error;
@property NSString* resId;
@end


@implementation NLRequestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.detailsArray = [[NSMutableArray alloc] init];
    
    [self.detailsArray addObject:REQ_URL];
    [self.detailsArray addObject:REQ_TYPE];
    [self.detailsArray addObject:REQ_HEADERS];
    [self.detailsArray addObject:REQ_BODY];
    [self.detailsArray addObject:REQ_TIME];
    [self.detailsArray addObject:REQ_STATUS];
    [self.detailsArray addObject:RES_CODE];
    [self.detailsArray addObject:RES_TIME];
    [self.detailsArray addObject:RES_HEADERS];
    
    [self.detailsArray addObject:RES_BODY];
    [self.detailsArray addObject:GEN_DURATION];
    [self.detailsArray addObject:REQ_SIZE];
    [self.detailsArray addObject:RES_SIZE];
    
    [self updateResponse];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    NSBundle *bundle =[NSBundle bundleForClass:self.classForCoder];
    NSURL* podBundleURL = [bundle URLForResource:@"NetLogger" withExtension:@"bundle"];
    NSBundle* podBundle = [NSBundle bundleWithURL:podBundleURL];
    
    UINib *cellNib = [UINib nibWithNibName:@"ResponseBodyTableViewCell" bundle:podBundle];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"ResponseBodyTableViewCell"];
    
}

- (void)updateResponse{
    if (self.responseDict)
    {
        self.error = [self.responseDict objectForKey:NSStringFromClass ([NSError class])];
        self.response = [self.responseDict objectForKey:NSStringFromClass ([NSURLResponse class])];
        self.data = [self.responseDict objectForKey:NSStringFromClass ([NSData class])];
        self.resId = [self.responseDict objectForKey:@"resId"];
        
        if ([self.response isKindOfClass:[NSURLResponse class]])
        {
            self.httpResponse  = (NSHTTPURLResponse *)self.response;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reqUpdated:)
                                                 name:NOTI_REQ_UPDATED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resUpdated:)
                                                 name:NOTI_RESPONSE_UPDATED
                                               object:nil];
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_RESPONSE_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_REQ_UPDATED object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) reqUpdated:(NSNotification *) notification
{
    NSDictionary* dict = notification.userInfo;
    
    if (dict)
    {
        NSString* reqId = [dict objectForKey:@"reqId"];
        if ([reqId isEqualToString:self.reqId])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
    
}
- (void) resUpdated:(NSNotification *) notification
{
    NSDictionary* dict = notification.userInfo;
    
    if (dict)
    {
        NSString* resId = [dict objectForKey:@"resId"];
        if ([resId isEqualToString:self.resId])
        {
            self.responseDict = [[[NetRecorder sharedManager] responseDict] objectForKey:self.reqId];
            [self updateResponse];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])] withRowAnimation:UITableViewRowAnimationNone];
                
                
            });
        }
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)aboutPressed:(id)sender {
    NSLog(@"aboutPressed");
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.detailsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString* title = [self.detailsArray objectAtIndex:indexPath.row];
    NSString* detail = @"N/A";
    
    if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:RES_BODY]){
        static NSString *simpleTableIdentifier = @"ResponseBodyTableViewCell";
        
        ResponseBodyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if ([self noError])
        {
            detail = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        }
        cell.titletextLabel.text = title;
        cell.detailtextLabel.text = detail;
        
        return cell;
    }
    
    
    
    NSString* cellIdentifier = @"cell";
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_URL]){
        detail = self.request.URL.absoluteString;
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_TYPE]){
        
        detail = self.request.HTTPMethod;
    }
    
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_HEADERS]){
        detail = [NSString stringWithFormat:@"%@", self.request.allHTTPHeaderFields];;
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_TIME]){
        
        double timeInterval = [self.reqId doubleValue];
        NSDate * requestDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        detail = [dateFormatter stringFromDate:requestDate];
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_STATUS]){
        if (self.responseDict)
        {
            detail = @"Completed";
        }
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:RES_CODE]){
        
        if ([self noError])
        {
            detail = [NSString stringWithFormat:@"%ld",(long)self.httpResponse.statusCode];
        }
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:RES_TIME]){
        if ([self noError])
        {
            double timeInterval = [self.resId doubleValue];
            NSDate * resDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
            detail = [dateFormatter stringFromDate:resDate];
        }
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:RES_HEADERS]){
        if ([self noError])
        {
            detail = [NSString stringWithFormat:@"%@", self.httpResponse.allHeaderFields];;
        }
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_BODY]){
        
        if (self.request.HTTPBody)
        {
            detail = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
        }
    }
    
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:GEN_DURATION]){
        if ([self noError])
        {
            
            
            double timeInterval = [self.reqId doubleValue];
            NSDate * reqDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            
            timeInterval = [self.resId doubleValue];
            NSDate * resDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            
            
            NSTimeInterval secondsBetween = [resDate timeIntervalSinceDate:reqDate];
            
            detail = [NSString stringWithFormat:@"%f secs", secondsBetween ];
            
            
        }
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:REQ_SIZE]){
        
        detail = @"N/A";
        
    }
    else if ([[self.detailsArray objectAtIndex:indexPath.row] isEqualToString:RES_SIZE]){
        if ([self noError]) {
            if (![self.data isKindOfClass:[NSNull class]])
            {
                float kilobytes = self.data.length / 1000;
                detail = [NSString stringWithFormat:@"%.2f Kb",  kilobytes];
            }
        }
        
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.numberOfLines  = 0;
    
    cell.textLabel.userInteractionEnabled = YES;
    cell.detailTextLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textPressed:)];
    [cell.textLabel addGestureRecognizer:tap];
    [cell.textLabel addGestureRecognizer:longPress];
    [cell.detailTextLabel addGestureRecognizer:tap];
    [cell.detailTextLabel addGestureRecognizer:longPress];
    
    return cell;
}

- (void) textPressed:(UILongPressGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized &&
        [gestureRecognizer.view isKindOfClass:[UILabel class]]) {
        UILabel *someLabel = (UILabel *)gestureRecognizer.view;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:someLabel.text];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info "
                                                                       message:@"Label text is added to your Pasteboard, feel free to paste it were you choose."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) textTapped:(UITapGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized &&
        [gestureRecognizer.view isKindOfClass:[UILabel class]]) {
        UILabel *someLabel = (UILabel *)gestureRecognizer.view;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:someLabel.text];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info "
                                                                       message:@"Label text is added to your Pasteboard, feel free to paste it were you choose."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        //let the user know you copied the text to the pasteboard and they can no paste it somewhere else
        NSString* detail = @"";
         NSString* line = @"**********************************************************";
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@ \n%@  \n%@", line , line, detail, REQ_URL, line];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, self.request.URL.absoluteString];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, REQ_TYPE, line];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, self.request.HTTPMethod];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, REQ_HEADERS, line];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, self.request.allHTTPHeaderFields];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, REQ_BODY, line];;
        if ([self noError])
        {
            if (self.request.HTTPBody)
            {
                NSString *res = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
                detail = [NSString stringWithFormat:@"\n%@ \n%@", detail, res];;
            }
            
        }
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, REQ_TIME, line];;
        double timeInterval = [self.reqId doubleValue];
        NSDate * requestDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        NSString* res = [dateFormatter stringFromDate:requestDate];
        detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, res];;
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, REQ_STATUS, line];;
        if (self.responseDict)
        {
            detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, @"Completed"];;
        }
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, RES_CODE, line];;
        if ([self noError])
        {
            detail = [NSString stringWithFormat:@"\n%@ \n%ld",detail, (long)self.httpResponse.statusCode];;
        }
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, RES_TIME, line];;
        if ([self noError])
        {
            double timeInterval = [self.resId doubleValue];
            NSDate * resDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
            NSString* res  = [dateFormatter stringFromDate:resDate];
            detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, res];;
        }
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, RES_HEADERS, line];;
        if ([self noError])
        {
            detail = [NSString stringWithFormat:@"\n%@ \n%@",detail, self.httpResponse.allHeaderFields];;
        }
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, RES_BODY, line];;
        if ([self noError])
        {
            NSString *res = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
            detail = [NSString stringWithFormat:@"\n%@ \n%@", detail, res];;
            
        }
        
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@",detail, GEN_DURATION, line];;
        if ([self noError])
        {
            double timeInterval = [self.reqId doubleValue];
            NSDate * reqDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            timeInterval = [self.resId doubleValue];
            NSDate * resDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSTimeInterval secondsBetween = [resDate timeIntervalSinceDate:reqDate];
            NSString* res = [NSString stringWithFormat:@"%f secs", secondsBetween ];
            detail = [NSString stringWithFormat:@"\n%@ \n%@", detail, res];;
        }
        
        detail = [NSString stringWithFormat:@"\n%@ \n%@ \n%@ \n%@",detail, REQ_SIZE, line, line];;
        if ([self noError])
        {
            if (![self.data isKindOfClass:[NSNull class]])
            {
                float kilobytes = self.data.length / 1000;
                NSString* res = [NSString stringWithFormat:@"%.2f Kb",  kilobytes];
                detail = [NSString stringWithFormat:@"\n%@ \n%@", detail, res];;
                
            }
        }
        NSLog(@"These are request Details: \n%@",detail);
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}


- (BOOL)noError{
    if (self.error == nil && self.data && self.response)
    {
        return YES;
    }
    else if ([self.error isKindOfClass:[NSNull class]] && self.data && self.response)
    {
        return YES;
    }
    return NO;
}
@end
