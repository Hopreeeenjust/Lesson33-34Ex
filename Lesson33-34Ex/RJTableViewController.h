//
//  RJTableViewController.h
//  Lesson33-34Ex
//
//  Created by Hopreeeeenjust on 27.01.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UITextField *sizeField;

- (IBAction)addRepository:(UIBarButtonItem *)sender;
@end
