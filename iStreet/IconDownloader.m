// IconDownloader.m
// iStreet
//
// See .h for credits

#import "IconDownloader.h"

@implementation IconDownloader

@synthesize targetObject;
@synthesize imageKey;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize receivedData;
@synthesize imageConnection;

#pragma mark
#pragma mark Public methods

/* Start the icon download from imageURL which will set object.key to the image data once it has downloaded.*/
- (void)startDownloadFromURL:(NSURL *)imageURL forImageKey:(NSString *)key ofObject:(NSObject *)object forDisplayAtIndexPath:(NSIndexPath *)indexPath atDelegate:(id <IconDownloaderDelegate>)d
{
    [self setTargetObject:object];
    [self setImageKey:key];
    [self setIndexPathInTableView:indexPath];
    [self setDelegate:d];
    [self setReceivedData:[NSMutableData data]];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:imageURL] delegate:self];
    self.imageConnection = conn;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

// Connection received data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

// Connection failed
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the received data to allow later attempts
    self.receivedData = nil;
    self.imageConnection = nil;
}

//Connection finished loading – tell the delegate to refresh the cell containing this icon
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set the event icon and clear temporary data/image
    [self.targetObject setValue:self.receivedData forKey:imageKey];
    
    self.receivedData = nil;
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    [delegate iconDidLoad:self.indexPathInTableView];
}

@end

