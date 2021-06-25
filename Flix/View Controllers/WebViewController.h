//
//  WebViewController.h
//  Flix
//
//  Created by Christine Sun on 6/25/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController

// the movie related to this web view
//@property (nonatomic, strong) NSDictionary *movie;

// the id of this movie
@property (nonatomic, assign) NSInteger movieID;

@end

NS_ASSUME_NONNULL_END
