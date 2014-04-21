//
//  UICollectionView+AggregateUpdates.h
//
//  Created by pronebird on 20/04/14.
//  Copyright (c) 2014 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (AggregateUpdates)

- (void)beginUpdates;
- (void)endUpdatesWithCompletion:(void(^)(BOOL finished))completion;

@end
