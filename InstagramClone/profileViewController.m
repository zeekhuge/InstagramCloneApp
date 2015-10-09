//
//  profileViewController.m
//  InstagramClone
//
//  Created by Mac-Mini Mtn on 10/7/15.
//  Copyright (c) 2015 zeekhuge. All rights reserved.
//

#import "profileViewController.h"
#import "instagramCloneViewController.h"
#import "postCell.h"

@interface profileViewController (){
    
    NSManagedObjectContext *databaseContext ;
    NSManagedObject *databaseObject_UsersnameInfo;
    NSFetchRequest *requests ;
    NSMutableArray *postsTimelineData;
    NSMutableArray* imagesData;
    NSPredicate *predicate;
    NSString* savedContentLocation;
}

@end

@implementation profileViewController

-(NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext * context =nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    
    return context;
}



-(NSManagedObject *) fetchLoggedInObject {
    
    NSError *errorObject = nil;
    NSManagedObject *obj = nil;
    requests = [NSFetchRequest fetchRequestWithEntityName:@"UsernameInfo"];
    
    predicate = [NSPredicate predicateWithFormat:@"loggedIn == %d", TRUE];
    [requests setPredicate:predicate];
    NSArray * fetchedResults = [databaseContext executeFetchRequest:requests error:&errorObject];
    
    if(errorObject != nil){
        NSLog(@"error occured for fetch %@ %@", errorObject, [errorObject localizedDescription]);
    }else{
        NSLog(@"no error occured fetched - %@",fetchedResults);
        if (fetchedResults.count  > 0){
            obj = [fetchedResults objectAtIndex:0];
            NSLog(@"will return - %@",[fetchedResults objectAtIndex:0]);
        }else{
            NSLog(@"No database exists");
        }
    }
        return obj;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"inside ViewDidload of profileView");
//    imagesData = [[NSMutableArray alloc] initWithObjects:@"home.png",@"cameraIcon.png",@"searchIcon.png",@"upArrow.png",@"listIcon.png",@"home.png",@"cameraIcon.png",@"searchIcon.png",@"upArrow.png",@"listIcon.png",@"home.png",@"cameraIcon.png",@"searchIcon.png",@"upArrow.png",@"listIcon.png", nil];
   
//    postsTimelineData = [[NSMutableArray alloc] initWithObjects:@"home.png",@"cameraIcon.png",@"searchIcon.png",@"upArrow.png",@"listIcon.png",@"home.png",@"cameraIcon.png",@"searchIcon.png",@"upArrow.png",@"listIcon.png",@"home.png",@"cameraIcon.png",@"searchIcon.png",@"upArrow.png",@"listIcon.png", nil];
    databaseContext = [self managedObjectContext];
   
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    savedContentLocation = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSManagedObject* obj = [self fetchLoggedInObject];
    NSLog(@"got %@",obj);
    if (obj != nil){
        NSLog(@"%@",[obj valueForKey:@"username"]);
        label_userName.text = [obj valueForKey:@"username"];
        navigationBarItem_topBar.title = [obj valueForKey:@"username"];
        imageView_userProfilePic.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@profilePicture",savedContentLocation,[obj valueForKey:@"username"]]];
        label_userFollowers.text = [NSString stringWithFormat:@"%@",[obj valueForKey:@"followersNumber"]];
        label_userFollowings.text = [NSString stringWithFormat:@"%@",[obj valueForKey:@"followingsNumber"]];
        label_userPosts.text = [NSString stringWithFormat:@"%@",[obj valueForKey:@"postsNumber"]];
        imagesData = [[[obj valueForKey:@"pictures"] componentsSeparatedByString:@"@"] mutableCopy];
        [imagesData removeObjectAtIndex:0];
        [imagesData removeObjectAtIndex:imagesData.count -1];
        NSLog(@"%@",imagesData);
        [collectionView_images setHidden:FALSE];
        [collectionView_images setUserInteractionEnabled:TRUE];
        [collectionView_images reloadData];
    }
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//function
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"Inside numberOfSectionsInCollectionView");
    return imagesData.count ;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"inside cellForItemAtIndexPath");
    static NSString * collectionIdentifier = @"collectionCell";
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentifier forIndexPath:indexPath];
    UIImageView *imageViewInCell = (UIImageView * ) [cell viewWithTag:100];
    
    imageViewInCell.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",savedContentLocation,[imagesData objectAtIndex:indexPath.row ]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 349.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"inside numberOfRowsInSection");
    return postsTimelineData.count /2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* tableCellIdentifier = @"tableCellHome";
    
    postCell * cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    
    if (cell == nil){
        NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"postCellForTable" owner:self options:nil];
        cell = [arr objectAtIndex:0];
    }
    NSManagedObject* obj = [self fetchLoggedInObject];
    if (obj != nil){
        cell.label_postMakerUsername.text = [obj valueForKey:@"username"];
        cell.imageView_postMakerProfile.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@profilePicture",savedContentLocation,[obj valueForKey:@"username"]]];
    }else{
        NSLog(@"logged in obj was nil");
    }
    cell.imageView_postImage.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",savedContentLocation,[postsTimelineData objectAtIndex:(indexPath.row *2)+1]]];
    cell.label_postText.text =[postsTimelineData objectAtIndex:(indexPath.row *2)];
    
    return cell;
    
}


- (IBAction)button_mediaClicked:(id)sender {
    NSLog(@"media button tapped");
    
    postsTimelineData = [[NSMutableArray alloc] init];
    
    NSManagedObject* obj = [self fetchLoggedInObject];
    if (obj != nil){
        NSLog(@"%@",[obj valueForKey:@"username"]);
        imagesData = [[[obj valueForKey:@"pictures"] componentsSeparatedByString:@"@"] mutableCopy];
        [imagesData removeObjectAtIndex:0];
        [imagesData removeObjectAtIndex:imagesData.count -1];
        NSLog(@"%@",imagesData);
    }

    [tableView_timeline setHidden:TRUE];
    [collectionView_images setHidden:FALSE];
    [tableView_timeline setUserInteractionEnabled:FALSE];
    [collectionView_images setUserInteractionEnabled:TRUE];
    [collectionView_images reloadData];
    
}



- (IBAction)button_timelineClicked:(id)sender {
    NSLog(@"timeline button tapped");
    
    imagesData = [[NSMutableArray alloc] init];
    
    NSManagedObject* obj = [self fetchLoggedInObject];
    if (obj != nil){
        NSLog(@"%@",[obj valueForKey:@"username"]);
        postsTimelineData = [[[obj valueForKey:@"posts"] componentsSeparatedByString:@"@"] mutableCopy];
    }
    NSLog(@"post data fetched - %@",postsTimelineData);
    [postsTimelineData removeObjectAtIndex:0];
    [postsTimelineData removeObjectAtIndex:postsTimelineData.count -1];
    NSLog(@"post data changed to  - %@",postsTimelineData);
    
    
    
    [tableView_timeline setHidden:FALSE];
    [collectionView_images setHidden:TRUE];
    [tableView_timeline setUserInteractionEnabled:TRUE];
    [collectionView_images setUserInteractionEnabled:FALSE];
    [tableView_timeline reloadData];
}


@end
