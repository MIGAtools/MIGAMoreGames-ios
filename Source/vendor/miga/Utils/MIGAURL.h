//
//  MIGAURL.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/13/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class MIGAURL
 @abstract MIGAURL is a simple subclass of NSURL which adds support for
 translating the miga-bundle: scheme to the file: scheme.
 
 @discussion MIGAURL overrides the initWithString:relativeToURL: method.
 After the object has been initialized by the superclass, the scheme is checked.
 If the scheme is "miga-bundle", this gets translated into a file url using the
 following rules:
 
 The structure of a miga-bundle URL is:
 
 miga-bundle://[bundle identifier (authority)]/<path>
 
 Examples of miga-bundle URLs include:
 
 miga-bundle:///images/myapp-screenshot.png
 miga-bundle://org.example.MyAppBundle/images/myapp-screenshot.png
 
 If no bundle identifier is included in the authority, the main bundle is used
 when resolving the path, otherwise the bundle with the specified identifier is
 used.  If the specified bundle does not exist, initWithString:relativeToURL:
 will return nil.
 
 The returned MIGAURL object will be a file url whose path is that of the bundle
 concatenated with the additional path specified in the miga-bundle url.
 
 Because initWithString:relativeToURL: is the designated initializer for NSURL,
 this behavior will also occur with the other initWithString:* methods included
 in NSURL (class methods as well).
 */
@interface MIGAURL : NSURL {

}

@end
