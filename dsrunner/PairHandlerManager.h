//
//  PairHandler.h
//  dsrunner
//
//  Created by Light on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^KeyCreator)(id obj);
typedef id (^HandlerCreator)(id key1, id key2);
typedef id (^HandlerApplication)(id handler, id obj1, id obj2);

@interface PairHandlerManager: NSObject
// OVERVIEW:
// This class is a utility for handling pairs of various types.
// To handle a pair: obj1 and obj2 (order is not significant)
// 1. It uses the specified KeyCreator to extract key1 and key2 from obj1 and obj2 respectively.
// 2. It then proceeds to find a handler identified by key1 and key2 using the specified HandlerCreator. If caching is enabled, the handler will be cached.
// 3. Finally, it uses the give HandlerApplication to process the handler, obj1 and obj2. When passing the args, it also ensures obj1 and obj2 are in the correct order: if the handler is identified by (key1, key2), the order is (obj1, obj2) and vice versa.

@property BOOL cached;

- (id)initWithKeyCreator:(KeyCreator)key handlerCreator:(HandlerCreator)handler
      handlerApplication:(HandlerApplication)a;
// EFFECTS: return a PairHandlerManager initialized with the specified values

- (id)handle:(id)obj1 with:(id)obj2;
// EFFECTS: handle the pairs and return result produced by the corresponding handler

@end
