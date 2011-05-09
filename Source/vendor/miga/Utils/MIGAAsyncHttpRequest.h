//
//  MIGAAsyncHttpRequest.h
//  MIGAUtils
//
//  Created by impact on 2/26/10.
//  Adapted for MIGA by Darryl H. Thomas on 7/23/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MIGAAsyncHttpRequest;

@protocol MIGAAsyncHttpRequestDelegate <NSObject>

@required
- (void)asyncHttpRequest:(MIGAAsyncHttpRequest *)request didFinishWithContent:(NSData *)responseContent;

@optional
- (void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)request;

@end
    

/*!
 @class MIGAAsyncHttpRequest
 
 @abstract A MIGAAsyncHttpRequest object performs an asynchronous HTTP GET of a
 resource.
 
 @discussion Upon successful completion of the request, the MIGAAsyncHttpRequest's
 delegate's asyncHttpRequest:didFinishWithContent: method will be called.
 
 MIGAAsyncHttpRequest retains its delegate.  When the request completes or is
 deallocated, the delegate is released.

*/
@interface MIGAAsyncHttpRequest : NSObject {
    @private
    NSURL *requestedURL;
    NSMutableData *receivedData;
    NSString *receivedMIMEContentType;
    NSStringEncoding receivedStringEncoding;

    NSURLConnection *connection;
    NSTimeInterval timeoutInterval;
    BOOL backgroundTaskSupported;
    NSUInteger backgroundTaskIdentifier;
    
    NSDictionary *postDictionary;

    id<MIGAAsyncHttpRequestDelegate> delegate;
}

@property (nonatomic, retain) id<MIGAAsyncHttpRequestDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, retain, readonly) NSURL *requestedURL;
@property (nonatomic, retain, readonly) NSString *receivedMIMEContentType;
@property (nonatomic, assign, readonly) NSStringEncoding receivedStringEncoding;
@property (nonatomic, copy) NSDictionary *postDictionary;

+ (MIGAAsyncHttpRequest *)requestWithURL:(NSURL *)url delegate:(id<MIGAAsyncHttpRequestDelegate>)delegate;
+ (MIGAAsyncHttpRequest *)requestWithURLString:(NSString *)URLString delegate:(id<MIGAAsyncHttpRequestDelegate>)delegate;
+ (MIGAAsyncHttpRequest *)requestWithURL:(NSURL *)url postDictionary:(NSDictionary *)postValuesAndNames delegate:(id<MIGAAsyncHttpRequestDelegate>)delegate;

- (void)startRequestWithURL:(NSURL *)url;
- (void)startRequestWithURLString:(NSString *)URLString;

- (void)cancel;

@end
