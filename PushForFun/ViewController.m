//
//  ViewController.m
//  PushForFun
//
//  Created by Jose Raul Montemayor on 10/5/14.
//  Copyright (c) 2014 Jose Raul Montemayor. All rights reserved.
//

#import "ViewController.h"
#import "TFHpple.h"
#import "Post.h"

@interface ViewController (){
    NSMutableArray *_objects;
}


@end

@implementation ViewController

- (void)loadPosts {
    // Get the URL Content
    NSURL *PostsUrl = [NSURL URLWithString:@"http://www.reddit.com/r/funny/rising/"];
    NSData *PostsHtmlData = [NSData dataWithContentsOfURL:PostsUrl];
    
    // Create a TFHpple parser with the data
    TFHpple *PostsParser = [TFHpple hppleWithHTMLData:PostsHtmlData];
    
    //Path query and search in the page
    NSString *PostsXpathQueryString = @"//div[@class='sitetable linklisting']/div/div[@class='entry unvoted']/p[@class='title']/a";
    NSString *PostsXpathQueryString2 = @"//div[@class='sitetable linklisting']/div/a[@class='thumbnail may-blank ']/img";
    NSArray *PostsNodes = [PostsParser searchWithXPathQuery:PostsXpathQueryString];
    NSArray *PostsNodes2 = [PostsParser searchWithXPathQuery:PostsXpathQueryString2];
    
    //Add a default image for the first element that will dissaper
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:@"{nodeAttributeArray = ({attributeName = src; nodeContent = \"//b.thumbs.redditmedia.com/E8bTIBFEOtiF4n4hiYH3FP0qOG6nTkb94X35wB42w-E.jpg\";},{attributeName = width; nodeContent = 70;}, {attributeName = height; nodeContent = 39;},{attributeName = alt; nodeContent = "";});nodeName = img;}"];
    [array addObjectsFromArray:PostsNodes2];
    
    // Array to Hold all the objects
    NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:0];
    int i = 0;
    for (TFHppleElement *element in PostsNodes) {
        if (i>0) {
        TFHppleElement *titulos = [array objectAtIndex:i];
        //First create a new publication object and add it to the array.
        Post *publication = [[Post alloc] init];
        [newPosts addObject:publication];
        
        //Get the publication’s title from the node’s first child’s contents
        publication.title = [[element firstChild] content];
        
        //Get the publication’s URL from the “href” attribute of the node. It’s an <a> tag, so it gives you the linking URL. In our case, this is the publication’s URL.
            publication.imgUrl = [titulos objectForKey:@"src"];
            
        }
        i++;
    }
    
    // Set _objects on the view controller to the new Posts array you created, and ask the table view to reload its data.
    _objects = newPosts;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadPosts];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _objects.count;
            break;
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIndentifier = @"customCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath: indexPath];
    if(!cell){
        //Para crear la celda a la medida
        cell =[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier];
    }
    
    
    

    if (indexPath.section == 0) {
        
        Post *thispublication = [_objects objectAtIndex:indexPath.row];
        cell.title.text = thispublication.title;
       
        
        NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http:%@",thispublication.imgUrl]];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *imagen = [UIImage imageWithData:data];
        cell.image.image = imagen;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
