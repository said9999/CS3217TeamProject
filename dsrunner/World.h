//
//  World.h
//

#import <Foundation/Foundation.h>
#import "Body.h"
#import "CollisionInfo.h"

@interface World : NSObject
// OVERVIEW:
// This class implements a physics world which contains a set of physical bodies.
// Bodies are put in the two group: foreground (moving bodies), background (static bodies)

@property (readonly) NSArray *foreground;
@property (readonly) NSArray *background;
@property (readonly) NSArray *collisionList;

@property double gravity;

- (void)addBodyToBackground:(Body*)body;
    // EFFECTS: add body to background layer

- (void)removeBodyFromBackground:(Body*)body;
    // EFFECTS: remove body from background layer

- (void)addBodyToForeground:(Body*)body;
    // EFFECTS: add body to foreground layer

- (void)removeBodyFromForeground:(Body*)body;
    // EFFECTS: remove body from foreground layer

- (void)step:(double)dt;
    // EFFECTS: simulate a time step in the world

- (void)findCollisionsFor:(Body *)x in:(NSArray *)bodies at:(double)dt do:(void (^)(CollisionInfo *))action;
    // EFFECTS: find bodies that collide with x at time dt and perform action with the collected CollisionInfo
    
@end
