//
//  PairHandler.mm
//  dsrunner
//
//  Created by Light on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PairHandlerManager.h"
#import <utility>
#import <map>

using namespace std;

typedef map<pair<id, id>, id> HandlerDict;

// OVERVIEW:
// This class is a utility for handling pairs of various types.

@interface PairHandlerManager () {
    HandlerDict handlerCache;
    HandlerCreator createHandler;
    KeyCreator createKey;
    HandlerApplication apply;
}

@end

@implementation PairHandlerManager

- (id)initWithKeyCreator:(KeyCreator)key handlerCreator:(HandlerCreator)handler
      handlerApplication:(HandlerApplication)a {
    // EFFECTS: return a PairHandlerManager initialized with the specified values
    
    self = [super init];
    if (self) {
        createKey = key;
        createHandler = handler;
        apply = a;
        self.cached = YES;
    }
    return self;
}

- (BOOL)tryHandleOrderedPair:(id)obj1 :(id)key1 :(id)obj2 :(id)key2 :(id *)ret {
    // EFFECTS: handle the specified pairs if the handler identified by the keys are already in the cache.
    //          Order of the pairs is significant.
    // RETURNS: YES if the pairs are handled and false otherwise.
    //          If YES is returned, ret will be set to be the result return by the handler
    
    pair<id, id> key = make_pair(key1, key2);
    HandlerDict::iterator it = handlerCache.find(key);
    if (it == handlerCache.end()) return NO;
    
    *ret = apply(it->second, obj1, obj2);
    return YES;
}

- (BOOL)tryHandleNewOrderedPair:(id)obj1 :(id)key1 :(id)obj2 :(id)key2 :(id *)ret {
    // EFFECTS: handle the specified pairs if a handler identified by the keys can be found.
    //          Order of the pairs is significant.
    // RETURNS: YES if the pairs are handled and false otherwise.
    //          If YES is returned, ret will be set to be the result return by the handler
    
    id handler = createHandler(key1, key2);
    if (handler == nil) return NO;
    
    if (self.cached)
        handlerCache[make_pair(key1, key2)] = handler;
    
    *ret = apply(handler, obj1, obj2);
    return YES;
}

- (id)handle:(id)obj1 with:(id)obj2 {
    // EFFECTS: handle the pairs and return result produced by the corresponding handler
    
    id key1 = createKey(obj1);
    id key2 = createKey(obj2);
    id ret = nil;
    
    if (self.cached) {
        if ([self tryHandleOrderedPair:obj1 :key1 :obj2 :key2 :&ret])
            return ret;
        
        if ([self tryHandleOrderedPair:obj2 :key2 :obj1 :key1 :&ret])
            return ret;
    }
    
    // cache is not enabled or handler doesn't exist, create it
    if ([self tryHandleNewOrderedPair:obj1 :key1 :obj2 :key2 :&ret])
        return ret;
    
    [self tryHandleNewOrderedPair:obj2 :key2 :obj1 :key1 :&ret];
    return ret;
}

@end
