//
//  InvocationHelper.m
//  dsrunner
//
//  Created by Light on 19/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "InvocationHelper.h"

// OVERVIEW: this class provides utility methods for dynamic method invocation
@implementation InvocationHelper

+ (id)invoke:(SEL)selector on:(id)obj withArgs:(id)arg, ... NS_REQUIRES_NIL_TERMINATION {
    // EFFECTS: invoke the specified selector on obj
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:selector]];
    invocation.target = obj;
    invocation.selector = selector;

    va_list args;
    va_start(args, arg);
    for (int i = 2; arg != nil; i++) {
        [invocation setArgument:&arg atIndex:i];
        arg = va_arg(args, id);
    }
    va_end(args);

    id result;
    [invocation invoke];
    [invocation getReturnValue:&result];
    return result;
}


@end
