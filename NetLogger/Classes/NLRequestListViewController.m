//
//  RequestsViewController.m
//  Playground
//
//  Created by Pankaj Nathani on 07/05/18.
//  Copyright © 2018 Pankaj Nathani. All rights reserved.
//

#import "NLRequestListViewController.h"
#import "NetRecorder.h"
#import "NLRequestDetailViewController.h"
#import "NLConstants.h"

@interface NLRequestListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NLRequestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void) resUpdated:(NSNotification *) notification
{
    [self reqUpdated:notification];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)deletePressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete? "
                                                                   message:@"This will delete all request history? Are you sure?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        [[[NetRecorder sharedManager] requestDict] removeAllObjects];
           [self.tableView reloadData];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
    handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)aboutPressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"About "
                                                                   message:@"This cocoapod is forked version of  VersionN Studios. \n\nIf you have any feedback please write to jasmin.ceco@gmail.com or say hi on the github page: https://github.com/jasminceco/NetLogger"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[[NetRecorder sharedManager] requestDict] allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* cellIdentifier = @"cell";
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.numberOfLines = 0;
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];

    
    NSArray* allKeys = [[[[NetRecorder sharedManager] requestDict] allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSString* reqTime =  [allKeys objectAtIndex:indexPath.row];
    
    NSURLRequest* req = [[[NetRecorder sharedManager] requestDict] objectForKey:reqTime];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",req.HTTPMethod, req.URL.absoluteString ];
    
    double timeInterval = [reqTime doubleValue];
    NSDate * requestDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
    
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:requestDate];
    
    UIView* accessoryView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
    
    accessoryView.layer.cornerRadius = 10;
    accessoryView.clipsToBounds = YES;
    accessoryView.alpha = 0.6;
    
    if ([[[[NetRecorder sharedManager] responseDict] allKeys] containsObject:reqTime])
    {
        NSDictionary* resDict =[[[NetRecorder sharedManager] responseDict] objectForKey:reqTime];
        NSURLResponse* res = [resDict objectForKey:NSStringFromClass ([NSURLResponse class])];
        
        NSHTTPURLResponse* httpReq =(NSHTTPURLResponse*)res ;
        
         if (![httpReq isKindOfClass:[NSNull class]] && httpReq.statusCode >= 200 && httpReq.statusCode < 300)
         {
               accessoryView.backgroundColor = [UIColor greenColor];
         }
         else{
             accessoryView.backgroundColor = [UIColor redColor];
         }
        
    }
    else{
        accessoryView.backgroundColor = [UIColor yellowColor];
    }
    

    cell.accessoryView = accessoryView;
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
return UITableViewAutomaticDimension;
}

 -(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSBundle *bundle =[NSBundle bundleForClass:self.classForCoder];
    NSURL* podBundleURL = [bundle URLForResource:@"NetLogger" withExtension:@"bundle"];
    NSBundle* podBundle = [NSBundle bundleWithURL:podBundleURL];
    
    
    NLRequestDetailViewController* rdVC = [[NLRequestDetailViewController alloc] initWithNibName:@"NLRequestDetailViewController" bundle:podBundle];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    
    
    NSArray* allKeys = [[[[NetRecorder sharedManager] requestDict] allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSString* reqTime =  [allKeys objectAtIndex:indexPath.row];
    
    NSURLRequest* req = [[[NetRecorder sharedManager] requestDict] objectForKey:reqTime];
    
    rdVC.request = req;
    rdVC.responseDict =[[[NetRecorder sharedManager] responseDict] objectForKey:reqTime];
    rdVC.reqId = reqTime;
    
    [self presentViewController:rdVC animated:YES completion:nil];
    
}

@end
