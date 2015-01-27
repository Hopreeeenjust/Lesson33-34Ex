//
//  RJTableViewController.m
//  Lesson33-34Ex
//
//  Created by Hopreeeeenjust on 27.01.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJTableViewController.h"

@interface RJTableViewController () <UITableViewDelegate, UITableViewDataSource, NSFileManagerDelegate>
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) NSString *folderName;
@end

@implementation RJTableViewController

#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)path {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.path = path;
    }
    return self;
}

#pragma mark - Setters

- (void)setPath:(NSString *)path {
    _path = path;
    
    NSError *error = nil;
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path
                                                                        error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self.tableView reloadData];
    self.navigationItem.title = [self.path lastPathComponent];
}

#pragma mark - View

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSFileManager defaultManager].delegate = self;
    
    self.navigationItem.title = [self.path lastPathComponent];
    
    if (!self.path) {
        self.path = @"/Users/roma/Documents/iOS dev course";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *fileIdentifier = @"FileCell";
    static NSString *folderIdentifier = @"FolderCell";
    
    NSString *fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        cell.textLabel.text = fileName;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        cell.textLabel.text = fileName;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileName = [self.contents objectAtIndex:indexPath.row];
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        NSFileManager *manager = [NSFileManager defaultManager];
        [self fileManager:manager shouldRemoveItemAtPath:path];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        NSString *fileName = [self.contents objectAtIndex:indexPath.row];
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        RJTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJTableViewController"];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Actions

- (IBAction)addRepository:(UIBarButtonItem *)sender {
    [self showEnterFolderNmaeAlert];
}

#pragma mark - Help methods

- (BOOL)isDirectoryAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [self.contents objectAtIndex:indexPath.row];
    BOOL isDirectory = NO;
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

- (void)createNewFolderWithName:(NSString *)name {
    NSString *folderName = name;
    if (![self isFreeNameForFolder:folderName]) {
        [self showNameInUseAlert];
    } else {
        [self addNewFolderToDirectoryWithName:folderName];
    }

}

- (BOOL)isFreeNameForFolder:(NSString *)name {
    BOOL breakFlag = NO;
    for (NSString *fileName in self.contents) {
        NSInteger i = [self.contents indexOfObject:fileName];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([fileName isEqualToString:name] && [self isDirectoryAtIndexPath:indexPath]) {
            breakFlag = YES;
            break;
        }
    }
    if (breakFlag) {
        return NO;
    } else {
        return YES;
    }
}

- (void)addNewFolderToDirectoryWithName:(NSString *)folderName {
    NSString *path = [self.path stringByAppendingPathComponent:folderName];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.contents];
    [tempArray addObject:folderName];
    self.contents = tempArray;
    [self.tableView reloadData];
}

- (void)showNameInUseAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This folder name is already in use. Please, choose another name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) showEnterFolderNmaeAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Folder name needed" message:@"Please, enter folder name" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Sorry"]) {
        [self showEnterFolderNmaeAlert];
    } else {
        NSString *folderName = [alertView textFieldAtIndex:0].text;
        [self createNewFolderWithName:folderName];
    }
}

#pragma mark - NSFileManagerDelegate

- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path {
    return YES;
}

@end
