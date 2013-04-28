//
//  World.m
//

#import "EngineConstants.h"
#import "World.h"
#import "Collision.h"
#import "CollisionFactory.h"
#import "rstartree.h"

using namespace rstar;

// OVERVIEW: this class implements a physics world which contains a set of physical objects
@interface World () {
    CollisionFactory *collisionFactory;
    NSMutableArray *collisionList;
    map<int, Body *> bodyDict;
    
    unsigned bodyIdSeed;
    Storage rtreeStorage;
    std::shared_ptr<RTree> rtree;
}

@property NSArray *background;
@property NSArray *foreground;

@end

@implementation World

- (NSArray *)collisionList {
    return collisionList;
}

- (id)init {
    // EFFECTS: return a physical world with properties initialized
    
    self = [super init];
    if (self) {
        self.background = [NSMutableArray array];
        self.foreground = [NSMutableArray array];
        collisionList = [NSMutableArray array];
        collisionFactory = [CollisionFactory instance];
        rtree = std::shared_ptr<RTree>(new RTree(&rtreeStorage));
        rtree->create(RTREE_BRANCH_FACTOR, RTREE_FILL_FACTOR);
        bodyIdSeed = 0;
    }
    return self;
}

+ (Rectangle)mbrFor:(Body *)body {
    // EFFECTS: return the minimum bounding rectangle for body
    
    Rectangle r;
    CGRect bb = body.boundingRect;
    r.min.x = bb.origin.x - COLLISION_ERROR;
    r.min.y = bb.origin.y - COLLISION_ERROR;
    r.max.x = bb.origin.x + bb.size.width + COLLISION_ERROR;
    r.max.y = bb.origin.y + bb.size.height + COLLISION_ERROR;
    return r;
}

- (void)addBodyToRTree:(Body *)body {
    Object obj;
    obj.id = body.id;
    obj.mbr = [World mbrFor:body];
    rtree->insertData(obj);
}

- (void)removeBodyFromRTree:(Body *)body {
    Object obj;
    obj.id = body.id;
    obj.mbr = [World mbrFor:body];
    rtree->deleteData(obj);
}

- (void)addBody:(Body *)body {
    // EFFECTS: add a physical body
    
    assert(body.id == 0);
    body.id = ++bodyIdSeed;
    bodyDict[body.id] = body;
}

- (void)removeBody:(Body *)body {
    // EFFECTS: remove a physical body
    
    assert(body.id != 0);
    bodyDict.erase(body.id);
}

- (void)addBodyToBackground:(Body *)body {
    // EFFECTS: add body to background layer
    
    body.isInBackground = YES;
    [(NSMutableArray *)self.background addObject:body];
    [self addBody:body];
    [self addBodyToRTree:body];
}

- (void)removeBodyFromBackground:(Body *)body {
    // EFFECTS: remove body from background layer
    
    [(NSMutableArray *)self.background removeObject:body];
    [self removeBody:body];
    [self removeBodyFromRTree:body];
}

- (void)addBodyToForeground:(Body *)body {
    // EFFECTS: add body to foreground layer
    
    [(NSMutableArray *)self.foreground addObject:body];
    [self addBody:body];
}

- (void)removeBodyFromForeground:(Body *)body {
    // EFFECTS: remove body from foreground layer
    
    [(NSMutableArray *)self.foreground removeObject:body];
    [self removeBody:body];
}

- (void)updateCollisionList:(double)dt {
    // EFFECTS: update collisionList to include collisions happening after time dt
    
    // calculte MBR for moving bodies and put them into rtree
    map<int, Object> mbrDict;
    for (Body *body in self.foreground) {
        Object obj;
        obj.id = body.id;
        obj.mbr = [World mbrFor:body];
        Vector2D *change = [body.velocity mul:dt];
        if (change.x > 0) {
            obj.mbr.max.x += change.x;
        } else {
            obj.mbr.min.x += change.x;
        }
        if (change.y > 0) {
            obj.mbr.max.y += change.y;
        } else {
            obj.mbr.min.y += change.y;
        }
        mbrDict[obj.id] = obj;
        rtree->insertData(obj);
    }
    
    [collisionList removeAllObjects];
    
    // find all collisions
    for (int i = 0; i < self.foreground.count; i++) {
        Body *x = self.foreground[i];
        std::vector<Object> objects;
        rtree->rangeQuery(objects, mbrDict[x.id].mbr);
        
        for (std::vector<Object>::iterator it = objects.begin(); it != objects.end(); it++) {
            if (it->id == x.id) continue;
            Body *y = bodyDict[it->id];
            if (!y.isInBackground && y.id < x.id) continue;
            
            CollisionInfo *c = [collisionFactory collisionInfoFor:x :y];
            if (c != nil)
                [collisionList addObject:c];
        }
    }
    // remove moving bodies from rtree
    for (map<int, Object>::iterator it = mbrDict.begin(); it != mbrDict.end(); it++) {
        rtree->deleteData(it->second);
    }
}

- (void)step:(double)dt {
    // EFFECTS: simulate a time step in the world
    
    [self updateCollisionList:dt];
    
    // apply gravity
    double g = self.gravity * dt;
    for (Body *body in self.foreground) {
        body.isOnGround = NO;
        body.canMoveUp = YES;
        if (body.isGravityAware)
            body.velocity.y += g;
    }
    
    // update shouldCollide
    NSNotification *notification = [NSNotification notificationWithName:SHOULE_COLLIDE_NOTIFICATION object:nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotification:notification];
    
    NSMutableArray *collisions = [NSMutableArray array];
    for (CollisionInfo *c in self.collisionList) {
        if (c.shouldCollide)
            [collisions addObject:c];
    }
    
    // find collisions that will happen after dt
    for (CollisionInfo *c in collisions) {
        [c update:dt];
        
        if (c.overlapDirection == kDirectionY) {
            if (c.bottom.isInBackground) {
                c.top.isOnGround = YES;
            } else {
                c.bottom.canMoveUp = NO;
            }
        }
    }
    
    // use notification center to notify handlers
    for (CollisionInfo *c in collisions) {
        if (!c.doCollide) continue;
        NSNotification *notification = [NSNotification notificationWithName:HANDLE_COLLISION_NOTIFICATION object:c];
        [nc postNotification:notification];
    }
    
    // remove gravity effects on bodies on the ground
    for (Body *body in self.foreground) {
        if (body.isOnGround) body.velocity.y -= g;
    }
    
    // handle collisions that will happen after dt and use that info to update velocities to avoid collisions
    for (int i = 0; i < ITERATIONS; i++) {
//        [self updateCollisionList:dt];
        for (CollisionInfo *c in collisions) {
            [c update:dt];
        }
        for (CollisionInfo *c in collisions) {
            if (c.doCollide)
                [self handleCollision:c in:dt];
        }
    }
    
    [self moveBodies:dt];
}

- (void)findCollisionsFor:(Body *)x in:(NSArray *)bodies at:(double)dt do:(void (^)(CollisionInfo *))action {
    // EFFECTS: find bodies that collide with x at time dt and perform action with the collected CollisionInfo
    
    for (Body *y in bodies) {
        if (x == y) continue;
        CollisionInfo *c =  [collisionFactory collisionInfoFor:x :y];
        [c update:dt];
        if (c.doCollide)
            action(c);
    }
}

- (void)handleCollision:(CollisionInfo *)c in:(double)dt {
    // EFFECTS: update bodies' velocity to handle collision
    
    Body *body1 = c.top;
    Body *body2 = c.bottom;
    // body1 is above body2
    Vector2D *dir;
    if (c.overlapDirection == kDirectionY) {
        dir = [Vector2D vectorWithX:0 y:1];
    } else {
        dir = [Vector2D vectorWithX:1 y:0];
    }
    
    double v1 = [body1.velocity dot:dir];
    double v2 = [body2.velocity dot:dir];;
    double dv = c.overlap / dt;
    
    if (v1 > 0) {
        if (v2 >= 0) { // both moving up
            // we make body2 move slower
            v2 = MAX(0, v2 - dv);
        }
    } else {
        if (v2 > 0) { // body1 moving down, body2 moving up
            // we make them both move slower
            double v = v2 - v1;
            v1 = MIN(0, v1 - dv * v1 / v);
            v2 = MAX(0, v2 - dv * v2 / v);
        } else { // both moving down
            // we make body1 move slower
            v1 = MIN(0, v1 + dv);
        }
    }
    
    // update velocities
    if (c.overlapDirection == kDirectionY) {
        if (!body1.isInBackground) body1.velocity.y = v1;
        if (!body2.isInBackground) body2.velocity.y = v2;
    } else {
        if (!body1.isInBackground) body1.velocity.x = v1;
        if (!body2.isInBackground) body2.velocity.x = v2;
    }
    
}

- (void)moveBodies:(double)dt {
    // EFFECTS: update object positions
    
    for (Body *body in self.foreground) {
        [body move:[body.velocity mul:dt]];
    }
}

- (void)dealloc {
    for (Body *body in [self.background copy]) {
        [self removeBodyFromBackground:body];
    }
    [(NSMutableArray *)self.foreground removeAllObjects];
    [(NSMutableArray *)collisionList removeAllObjects];
    
    self.background = nil;
    self.foreground = nil;
    collisionList = nil;
    collisionFactory = nil;
}

@end
