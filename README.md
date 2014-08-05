UICollectionView-NSFetchedResultsController
=================================

A simple category on UICollectionView to perform content changes in UITableView fashion. Comes handy with NSFetchedResultsController. 

Each `-[UICollectionView beginUpdates]` must be balanced with `-[UICollectionView endUpdatesWithCompletion:]`. You can do any changes to UICollectionView in between.

Example use case with NSFetchedResultsController:

```objective-c
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.collectionView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.collectionView endUpdatesWithCompletion:^(BOOL finished) {}];
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath 
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
			break;
		case NSFetchedResultsChangeDelete:
			[self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
			break;
		case NSFetchedResultsChangeMove:
			[self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
			break;
		case NSFetchedResultsChangeUpdate:
			[self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
			break;
		}
}
```
