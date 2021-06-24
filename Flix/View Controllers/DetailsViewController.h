//
//  DetailsViewController.h
//  Flix
//
//  Created by Christine Sun on 6/23/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

// public property so others can set what movie this is for
@property (nonatomic, strong) NSDictionary *movie;

@end

NS_ASSUME_NONNULL_END
