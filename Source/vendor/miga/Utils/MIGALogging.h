/*
 *  MIGALogging.h
 *  MIGAUtils
 *
 *  Created by Darryl H. Thomas on 7/31/10.
 *  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
 *
 */

/*!
 @function MIAGDLog
 
 @abstract Conditionally logs an error message to the Apple System Log facility. (using the same arguments as NSLog).
 
 @discussion If the DEBUG preprocessor macro is defined (typically by
 adding a DEBUG definition to the Preprocessor Macros setting in the
 Debug build configuration for your project), MIGADLog() will log the
 supplied format string and arguments.  The __PRETTY_FUNCTION__ string
 is prepended to the supplied format string, making it easy to see where
 the output came from.
 
 If DEBUG is *not* defined, calls to MIGADLog() will effectively output
 nothing.
 */

/*!
 @function MIAGALog
 
 @abstract Conditionally raises an assertion failure or logs an error message to the Apple System Log facility. (using the same arguments as NSLog).
 
 @discussion If the DEBUG preprocessor macro is defined (typically by
 adding a DEBUG definition to the Preprocessor Macros setting in the
 Debug build configuration for your project), MIGAALog() will make the
 current assertion handler handle a failure at the point at which
 MIGAALog() was called with the format string supplied as arguments.
 
 If DEBUG is *not* defined, calls to MIGAALog() simply behaves the way
 MIGADLog() behaves when DEBUG is defined (logs to the Apple System Log
 facility).
 
 Note: It is up to the developer to set NS_BLOCK_ASSERTIONS in
 release builds if this is the desired behavior.  MIGALogging does not
 make this assumption for you.
 */

#ifndef MIGALOGGING_H_
#define MIGALOGGING_H_

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define MIGADLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat: __VA_ARGS__])
#define MIGAALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction: [NSString stringWithCString: __PRETTY_FUNCTION__ encoding: NSUTF8StringEncoding] file: [NSString stringWithCString: __FILE__ encoding: NSUTF8StringEncoding] lineNumber: __LINE__ description: __VA_ARGS__]

#else

#define MIGADLog(...) do { } while (0)
#define MIGAALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat: __VA_ARGS__])

#endif

#endif