//  IconDownloader.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//
// Much of the IconDownloader code is borrowed from Apple – However, many modifications were made, including it making much more general so that it does not apply to only one class.

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    NSObject  *targetObject;
    NSString *imageKey;
    
    NSIndexPath *indexPathInTableView;
    
    NSMutableData *receivedData;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) NSObject *targetObject;
@property (nonatomic, retain) NSString *imageKey;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *imageConnection;

@property __weak id <IconDownloaderDelegate> delegate;

- (void)startDownloadFromURL:(NSURL *)imageURL forImageKey:(NSString *)imageKey ofObject:(NSObject *)object forDisplayAtIndexPath:(NSIndexPath *)indexPath atDelegate:(id <IconDownloaderDelegate>)delegate;

@end

@protocol IconDownloaderDelegate 
- (void)iconDidLoad:(NSIndexPath *)indexPath;
@end