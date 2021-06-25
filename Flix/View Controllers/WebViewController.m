//
//  WebViewController.m
//  Flix
//
//  Created by Christine Sun on 6/25/21.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSArray *videos;
@property (strong, nonatomic) NSString *urlString;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self fetchVideos];
    NSLog(@"%@", self.urlString);
    NSLog(@"%@", self.videos);
    // Fetch the videos that have been added to this movie
    NSString *baseStartURLString = @"https://api.themoviedb.org/3/movie/";
    NSString *baseEndURLString = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US";
    NSString *fullVideosURLString = [baseStartURLString stringByAppendingString:[NSString stringWithFormat:@"%@", self.movieID]];
    fullVideosURLString = [fullVideosURLString stringByAppendingString:baseEndURLString];
    NSLog(@"%@", fullVideosURLString);
    
    NSURL *url = [NSURL URLWithString:fullVideosURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Network request comes back
        NSLog(@"reached 2");
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            NSLog(@"reached 1");
        }
        else {
            // Get the array of videos for this movie
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            // Store videos
            self.videos = dataDictionary[@"results"];
            NSLog(@"reached");
            
            // Load the url for this movie
            NSString *baseURLString = @"https://www.youtube.com/watch?v=";
            NSLog(@"%@", self.videos);
            NSString *trailerKeyString = (self.videos[0])[@"key"];
            
            
            NSString *trailerURLString = [baseURLString stringByAppendingString:trailerKeyString];
            NSURL *videoURL = [NSURL URLWithString:trailerURLString];
            NSLog(@"%@", trailerURLString);
            
            // Place the URL in a URL Request.
            NSURLRequest *videoRequest = [NSURLRequest requestWithURL:videoURL
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:10.0];
            // Load Request into WebView.
            [self.webView loadRequest:videoRequest];
        }
    }];
    [task resume];
    
}
/*
- (void)fetchVideos {
    // Fetch the videos
    NSString *baseStartURLString = @"https://api.themoviedb.org/3/movie/";
    NSString *baseEndURLString = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US";
    NSString *fullVideosURLString = [baseStartURLString stringByAppendingString:[NSString stringWithFormat:@"%@", self.movieID]];
    fullVideosURLString = [fullVideosURLString stringByAppendingString:baseEndURLString];
    
    NSURL *url = [NSURL URLWithString:fullVideosURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Network request comes back
        NSLog(@"reached 2");
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            NSLog(@"reached 1");
        }
        else {
            // Get the array of videos for this movie
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            // Store videos
            self.videos = dataDictionary[@"results"];
            NSLog(@"reached");
        }
    }];
    [task resume];
}*/
/*
 -Pass the trailer url to the web view (in prepare(forSegue)) when presenting it using a modal segue.
 -Pass in the id from the movie you want to get the video for as a query parameter to the Get Videos endpoint
 -In the response back from the Get Videos endpoint, the value returned from the key, "key" is the youtube video key.
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
