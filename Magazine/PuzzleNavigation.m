//
//  PuzzleNavigation.m
//  Magazine
//
//  Created by MBPro on 6/24/16.
//  Copyright © 2016 MBPro. All rights reserved.
//

#import "PuzzleNavigation.h"
#import "Puzzle.h"
#import "IGCMenu.h"
#import <libpq/libpq-fe.h>
#import "News.h"
@import WebImage;

@implementation PuzzleNavigation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    UIStoryboard *mainStoryboard = self.storyboard;
    
    _puzzleController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PuzzleScene"];
    _puzzleController.currentTopic = _currentTopic;
    _puzzleController.fileName = _fileName;
    
    _puzzleController.view.frame = CGRectMake (0,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
    NSLog(@"width: %f height: %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    _puzzleController.view.contentMode = UIViewContentModeScaleToFill;
    

    [self addChildViewController:_puzzleController];
    [_puzzleController didMoveToParentViewController:self];
    _puzzleController.view.autoresizesSubviews = YES;
    [self.scrollView addSubview:_puzzleController.view];
    

}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showNews"]) {
        News* controller = [segue destinationViewController];
        controller.fileName = @"article";
        controller.currentTopic = _currentTopic;
    } else if([segue.identifier isEqualToString:@"showPuzzle"]) {
        PuzzleNavigation* controller = [segue destinationViewController];
        controller.currentTopic = _currentTopic;
        controller.fileName = @"wordsearch.png";
        NSLog(@"Segue to Puzzle Nav");
    } else if([segue.identifier isEqualToString:@"showWorld"]) {
        News* controller = [segue destinationViewController];
        controller.currentTopic = _currentTopic;
    }
}

-(void) connectToDatabase {
    _connectionString = "user=labs2025 password=engrRgr8 dbname=iOSDatabase  port=5432 host=labs2025ios.clygqyctjtg6.us-west-2.rds.amazonaws.com";
    _connection = PQconnectdb(_connectionString);
    
    if(PQstatus(_connection) != CONNECTION_OK) {
        NSLog(@"Error: Couldn't connect to the database");
        NSLog(@"Error message: %s", PQerrorMessage(_connection));
    }
    
}

-(NSMutableArray*) getImageFilesFromDatabase {
    _result = PQexec(_connection, "begin");
    if(PQresultStatus(_result) != PGRES_COMMAND_OK) {
        NSLog(@"Begin command failed");
    }
    PQclear(_result);
    
    NSString *tempQuery = [NSString stringWithFormat:@"SELECT * FROM images WHERE filename = '%@' AND topic = '%@'", _fileName, _currentTopic];
    const char *query = [tempQuery cStringUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"Query: %s", query);
    _result = PQexec(_connection, query);
    if(PQresultStatus(_result) !=PGRES_TUPLES_OK) {
        NSLog(@"Couldn't fetch anything");
    }
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    //If successful, this should be a hashed password
    for(int i =0; i < PQntuples(_result); i++) {
        NSLog(@"value: %s ",PQgetvalue(_result, i, 2));
        NSString *temp = [NSString stringWithUTF8String:PQgetvalue(_result, i, 2)];
        [resultArray addObject:temp];
    }
    NSString *userDefaultKey = [NSString stringWithFormat:@"%@,%@", _fileName, _currentTopic];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:resultArray forKey:userDefaultKey];
    [defaults synchronize];
    
    PQclear(_result);
    return resultArray;
}

-(IBAction)changeToFillInTheBlank:(id)sender {
    NSLog(@"start change to fillintheblank");
    _puzzleController.fileName = @"fillintheblank.png";
    _puzzleController.currentTopic = @"computing";
    [self notifyWithReason:@"reload"];
}

-(IBAction)changeToWordsearch:(id)sender {
    _puzzleController.fileName = @"wordsearch.png";
    _puzzleController.currentTopic = @"computing";
    [self notifyWithReason:@"reload"];
    
}

-(IBAction)changeToMaterial:(id)sender {
    _puzzleController.fileName = @"material.png";
    _puzzleController.currentTopic = @"computing";
    [self notifyWithReason:@"reload"];
}

-(IBAction)changeToCipher:(id)sender {
    _puzzleController.fileName = @"cipher.png";
    _puzzleController.currentTopic = @"computing";
    [self notifyWithReason:@"reload"];
}

-(void) notifyWithReason: (NSString*) reason {
    [[NSNotificationCenter defaultCenter]postNotificationName:reason object:nil];
    NSLog(@"Called notification with reason: %@", reason);
}


@end
