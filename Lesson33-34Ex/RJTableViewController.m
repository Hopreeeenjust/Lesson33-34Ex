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

static double sumSize = 0;
static BOOL isEnd = NO;

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
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.path] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    self.contents = [self makePathFromUrlInArray:self.contents];
    self.contents = [self objectsSortingInArray:self.contents andPath:self.path];
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
    
    if ([self isDirectoryAtIndexPath:indexPath inArray:self.contents andPath:self.path]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        cell.textLabel.text = fileName;
        NSString *currentDirectoryPath = [self.path stringByAppendingPathComponent:fileName];
        sumSize = 0;
        isEnd = NO;
        double folderSize = [self sizeOfDirectoryAtPath:currentDirectoryPath];
        cell.detailTextLabel.text = [self sizeRepresentationFromBytes:folderSize];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        cell.textLabel.text = fileName;
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        unsigned long long sizeInBytes = [attributes fileSize];
        cell.detailTextLabel.text = [self sizeRepresentationFromBytes:sizeInBytes];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileName = [self.contents objectAtIndex:indexPath.row];
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.contents];
        [tempArray removeObjectAtIndex:indexPath.row];
        self.contents = tempArray;
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath inArray:self.contents andPath:self.path]) {
        NSString *fileName = [self.contents objectAtIndex:indexPath.row];
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        RJTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJTableViewController"];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Actions

- (IBAction)addRepository:(UIBarButtonItem *)sender {
    [self showEnterFolderNameAlert];
}

#pragma mark - Help methods

- (BOOL)isDirectoryAtIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array andPath:(NSString *)path {
    NSString *fileName = [array objectAtIndex:indexPath.row];
    BOOL isDirectory = NO;
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
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
        if ([fileName isEqualToString:name] && [self isDirectoryAtIndexPath:indexPath inArray:self.contents andPath:self.path]) {
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

- (void) showEnterFolderNameAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose the name for new folder" message:@"Please, enter folder name" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (NSArray *)objectsSortingInArray:(NSArray *)array andPath:(NSString *)path {
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if ([self isDirectoryAtIndexPath: [NSIndexPath indexPathForRow:[array indexOfObject:obj1] inSection:0] inArray:array andPath:path] && [self isDirectoryAtIndexPath: [NSIndexPath indexPathForRow:[array indexOfObject:obj2] inSection:0] inArray:array andPath:path]) {
            return [obj1 compare:obj2];
        } else if (![self isDirectoryAtIndexPath: [NSIndexPath indexPathForRow:[array indexOfObject:obj1] inSection:0] inArray:array andPath:path] && ![self isDirectoryAtIndexPath: [NSIndexPath indexPathForRow:[array indexOfObject:obj2] inSection:0] inArray:array andPath:path]) {
            return [obj1 compare:obj2];
        } else if ([self isDirectoryAtIndexPath: [NSIndexPath indexPathForRow:[array indexOfObject:obj1] inSection:0] inArray:array andPath:path]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return sortedArray;
}

- (NSArray *)makePathFromUrlInArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < [array count]; i++) {
        NSURL *url = [array objectAtIndex:i];
        NSString *string = url.path;
        string = [string lastPathComponent];
        [tempArray addObject:string];
    }
    return tempArray;
}

- (NSString *)sizeRepresentationFromBytes:(unsigned long long)sizeInBytes {
    NSArray *array = @[@"B", @"Kb", @"Mb", @"Gb", @"Tb"];
    CGFloat size = (CGFloat)sizeInBytes;
    NSInteger i = 0;
    while (size > 1024 && i < [array count]) {
        size /= 1024;
        i++;
    }
    return [NSString stringWithFormat:@"%.2f %@", size, array[i]];
}

- (double)sizeOfDirectoryAtPath:(NSString *)path {
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    array = [self makePathFromUrlInArray:array];
    array = [self objectsSortingInArray:array andPath:path];
    for (NSInteger i = 0; i < [array count]; i++) {
        if (isEnd) {
            path = [path stringByDeletingLastPathComponent];
        }
        isEnd = NO;
        NSString *fileName = [array objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if (![self isDirectoryAtIndexPath:indexPath inArray:array andPath:path]) {
            path = [path stringByAppendingPathComponent:fileName];
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            unsigned long long sizeInBytes = [attributes fileSize];
            sumSize += sizeInBytes;
            path = [path stringByDeletingLastPathComponent];
        } else {
            path = [path stringByAppendingPathComponent:fileName];
            [self sizeOfDirectoryAtPath:path];
        }
    }
    path = [path stringByDeletingLastPathComponent];
    isEnd = YES;
    return sumSize;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Sorry"]) {
        [self showEnterFolderNameAlert];
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
