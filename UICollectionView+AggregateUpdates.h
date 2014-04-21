//
//  UICollectionView+AggregateUpdates.h
//
//  A simple category on UICollectionView to perform content changes in UITableView fashion.
//  Comes handy with NSFetchedResultsController.
//
//  Created by pronebird on 20/04/14.
//  Copyright (c) 2014 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (AggregateUpdates)

- (void)beginUpdates;
- (void)endUpdatesWithCompletion:(void(^)(BOOL finished))completion;

@end
