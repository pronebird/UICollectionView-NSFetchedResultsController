//
//  UICollectionView+AggregateUpdates.m
//
//  A simple category on UICollectionView to perform content changes in UITableView fashion.
//  Comes handy with NSFetchedResultsController.
//
//  Created by pronebird on 20/04/14.
//  Copyright (c) 2014 pronebird. All rights reserved.
//

#import "UICollectionView+NSFetchedResultsController.h"
#import <objc/runtime.h>

static const void* kHasBegunUpdatesKey = &kHasBegunUpdatesKey;
static const void* kBatchUpdateBlocksKey = &kBatchUpdateBlocksKey;

static void PBSwizzleMethod(Class c, SEL original, SEL alternate) {
	Method origMethod = class_getInstanceMethod(c, original);
	Method newMethod = class_getInstanceMethod(c, alternate);
	
	if(class_addMethod(c, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
		class_replaceMethod(c, alternate, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	} else {
		method_exchangeImplementations(origMethod, newMethod);
	}
}

@implementation UICollectionView (NSFetchedResultsController)

- (NSMutableArray*)pb_batchUpdateBlocks {
	NSMutableArray* blocks = objc_getAssociatedObject(self, kBatchUpdateBlocksKey);
	
	if(blocks == nil) {
		blocks = [NSMutableArray new];
		objc_setAssociatedObject(self, kBatchUpdateBlocksKey, blocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return blocks;
}

- (void)pb_addBatchUpdateBlock:(void(^)(void))block {
	[[self pb_batchUpdateBlocks] addObject:block];
}

- (void)pb_removeAllBatchUpdateBlocks {
	[[self pb_batchUpdateBlocks] removeAllObjects];
}

- (void)pb_setBeginUpdates:(BOOL)flag {
	objc_setAssociatedObject(self, kHasBegunUpdatesKey, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pb_hasBegunUpdates {
	NSNumber* flag = objc_getAssociatedObject(self, kHasBegunUpdatesKey);
	
	return [flag boolValue];
}

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PBSwizzleMethod(self, @selector(insertSections:), @selector(pb_insertSections:));
		PBSwizzleMethod(self, @selector(deleteSections:), @selector(pb_deleteSections:));
		PBSwizzleMethod(self, @selector(reloadSections:), @selector(pb_reloadSections:));
		PBSwizzleMethod(self, @selector(moveSection:toSection:), @selector(pb_moveSection:toSection:));
		PBSwizzleMethod(self, @selector(insertItemsAtIndexPaths:), @selector(pb_insertItemsAtIndexPaths:));
		PBSwizzleMethod(self, @selector(deleteItemsAtIndexPaths:), @selector(pb_deleteItemsAtIndexPaths:));
		PBSwizzleMethod(self, @selector(reloadItemsAtIndexPaths:), @selector(pb_reloadItemsAtIndexPaths:));
		PBSwizzleMethod(self, @selector(moveItemAtIndexPath:toIndexPath:), @selector(pb_moveItemAtIndexPath:toIndexPath:));
	});
}

- (void)pb_insertSections:(NSIndexSet *)sections {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_insertSections:sections];
		}];
		return;
	}
	
	[self pb_insertSections:sections];
}

- (void)pb_deleteSections:(NSIndexSet *)sections {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_deleteSections:sections];
		}];
		return;
	}
	
	[self pb_deleteSections:sections];
}

- (void)pb_reloadSections:(NSIndexSet *)sections {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_reloadSections:sections];
		}];
		return;
	}
	
	[self pb_reloadSections:sections];
}

- (void)pb_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_moveSection:section toSection:newSection];
		}];
		return;
	}
	
	[self pb_moveSection:section toSection:newSection];
}

- (void)pb_insertItemsAtIndexPaths:(NSArray *)indexPaths {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_insertItemsAtIndexPaths:indexPaths];
		}];
		return;
	}
	
	[self pb_insertItemsAtIndexPaths:indexPaths];
}

- (void)pb_deleteItemsAtIndexPaths:(NSArray *)indexPaths {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_deleteItemsAtIndexPaths:indexPaths];
		}];
		return;
	}
	
	[self pb_deleteItemsAtIndexPaths:indexPaths];
}

- (void)pb_reloadItemsAtIndexPaths:(NSArray *)indexPaths {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_reloadItemsAtIndexPaths:indexPaths];
		}];
		return;
	}
	
	[self pb_reloadItemsAtIndexPaths:indexPaths];
}

- (void)pb_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
	if([self pb_hasBegunUpdates]) {
		[self pb_addBatchUpdateBlock:^{
			[self pb_moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
		}];
		return;
	}
	
	[self pb_moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)beginUpdates {
	[self pb_removeAllBatchUpdateBlocks];
	[self pb_setBeginUpdates:YES];
}

- (void)endUpdatesWithCompletion:(void(^)(BOOL finished))completion {
	NSArray* blocks = [self pb_batchUpdateBlocks];
	
	[self performBatchUpdates:^{
		for(void(^block)(void) in blocks) {
			block();
		}
	} completion:completion];
	
	[self pb_removeAllBatchUpdateBlocks];
	[self pb_setBeginUpdates:NO];
}

@end
