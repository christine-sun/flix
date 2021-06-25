//
//  MoviesViewController.m
//  Flix
//
//  Created by Christine Sun on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
 
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchMovies {
    
    // Start the activity indicator
    [self.activityIndicator startAnimating];
    
    // Fetch the movies
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Network request comes back
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            
            // Handle Network error
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                message:@"The internet connection appears to be offline."
                preferredStyle:(UIAlertControllerStyleAlert)];
            
            // Create a Try Again action that tries fetching movies again
            UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * _Nonnull action) {
                    [self fetchMovies];
            }];
            
            [alert addAction:tryAgainAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else {
            // Get the array of movies
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
            // Store movies
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
            
            // Reload table view data
            [self.tableView reloadData];
            
            // Stop the activity indicator
            [self.activityIndicator stopAnimating];
               
        }
        
        [self.refreshControl endRefreshing];
    }];
    [task resume];
    
}

// How many rows you have
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

// Create and configure a cell to have movie title based on its indexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier: @"MovieCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    // Find the URL for the image of this movie poster
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    // Fill in information for each movie in a movie cell
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    cell.posterView.image = nil; // clear out prev image
    //[cell.posterView setImageWithURL:posterURL];
    
    // Fade images in as they are downloaded
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    __weak MovieCell *weakSelf = cell;
    
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil
        success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
            // imageResponse will be nil if the image is cached
            if (imageResponse) {
                NSLog(@"Image was NOT cached, fade in image");
                weakSelf.posterView.alpha = 0.0;
                weakSelf.posterView.image = image;
                                                
                // Animate UIImageView back to alpha 1 over 0.3sec
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.posterView.alpha = 1.0;
                }];
            }
            else {
                NSLog(@"Image was cached so just update the image");
                weakSelf.posterView.image = image;
            }
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
            NSLog(@"fail to load");
        }];
    // Image fade end
    
    return cell;
}

// Update what TableView displays based on text in searchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   
   if (searchText.length != 0) {
       
       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)", searchText];
       
       self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
       
       NSLog(@"%@", self.filteredMovies);
       
   }
   else {
       self.filteredMovies = self.movies;
   }
   
   [self.tableView reloadData];

}

// Show cancel button when user starts editing search text
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

// clear existing text and hide keyboard when cancel button is clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // sender is tableViewCell that got tapped on
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    // pass the movie that was tapped
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}

@end
