//
//  InvocationHelper.h
//  dsrunner
//
//  Created by Light on 19/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvocationHelper : NSObject
// OVERVIEW: this class provides utility methods for dynamic method invocation

+ (id)invoke:(SEL)selector on:(id)obj withArgs:(id)arg, ... NS_REQUIRES_NIL_TERMINATION;
// EFFECTS: invoke the specified selector on obj
    
@end
