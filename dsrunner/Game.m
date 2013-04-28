//
//  Game.m
//  dsrunner
//
//  Created by Light on 19/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Game.h"
#import "Constants.h"
#import "EngineConstants.h"
#import "InvocationHelper.h"
#import "GamePath.h"
#import "GameProjectile.h"
#import "GameRunner.h"
#import "GameInk.h"
#import "GameQuestionMark.h"
#import "Line.h"

// OVERVIEW:
// This class contains basic game logic and manage physics world.
// It requires a GameControllerDelegate to handle view updates.

@interface Game () {
    int inkPoints[2];
    int inkCounter;

    PairHandlerManager *handleCollisionManager;
    PairHandlerManager *shouldCollideManager;
}

@property (weak) id<GameControllerDelegate> controller;

@property World *world;
@property NSMutableArray *foregroundObjects;
@property NSMutableArray *backgroundObjects;
@property NSMutableArray *paths;
@property NSMutableDictionary *bodyToGameObjectDict;

@property BOOL drawingLine;

@end

@implementation Game

- (id)initWithController:(id<GameControllerDelegate>)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
        [self setup];
    }
    return self;
}

- (int *)inkPoints {
    return inkPoints;
}

- (void)setup {
    // EFFECTS: initialize objects and subscribe to notifications from physics engine
    
    self.world = [[World alloc] init];
    self.world.gravity = -GRAVITY;
    
    self.foregroundObjects = [NSMutableArray array];
    self.backgroundObjects = [NSMutableArray array];
    self.bodyToGameObjectDict = [NSMutableDictionary dictionary];
    self.paths = [NSMutableArray array];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleCollision:) name:HANDLE_COLLISION_NOTIFICATION object:nil];
    [nc addObserver:self selector:@selector(shouldCollide:) name:SHOULE_COLLIDE_NOTIFICATION object:nil];
    
    handleCollisionManager = [self pairHandlerManagerWithMethodFormat:HANDLE_COLLISION_METHOD_FORMAT];
    shouldCollideManager = [self pairHandlerManagerWithMethodFormat:SHOULD_COLLIDE_METHOD_FORMAT];
    
    inkCounter = 0;
    self.drawingLine = NO;
    self.currentInkType = RED_INK;
}

- (PairHandlerManager *)pairHandlerManagerWithMethodFormat:(NSString *)selectorFormat {
    // EFFECTS: get a PairHandlerManager that uses the selectorFormat together with class name of a object
    //          in a pair to find a method in this class, invokes the method with the pair and returns the
    //          return value
    
    return [[PairHandlerManager alloc] initWithKeyCreator:^(id obj) {
        return [obj class];
    } handlerCreator:^(id key1, id key2) {
        NSString *name = [NSString stringWithFormat:selectorFormat, key1];
        if ([self respondsToSelector:NSSelectorFromString(name)])
            return name;
        return (NSString *)nil;
    } handlerApplication:^(id handler, id obj1, id obj2) {
        return [InvocationHelper invoke:NSSelectorFromString(handler) on:self withArgs:obj1, obj2, nil];
    }];
}

- (void)handleCollision:(NSNotification *)notification {
    // EFFECTS: use handleCollisionManager to handle collisions from world
    
    CollisionInfo *c = notification.object;
    GameObject *obj1 = [self gameObjectForBody:c.top];
    GameObject *obj2 = [self gameObjectForBody:c.bottom];
    [handleCollisionManager handle:obj1 with:obj2];
}

- (id)handleGameRunnerCollision:(GameRunner *)gameRunner with:(GameObject *)obj {
    switch (obj.model.modelType) {
        case GameModelDestination:
            [self.controller clearGame];
            break;
            
        case GameModelEnemy:
        case GameModelProjectile:
            gameRunner.isDead = YES;
            break;
            
        case GameModelRedInk:
        case GameModelGreenInk: {
            int type = obj.model.modelType == GameModelRedInk ? RED_INK : GREEN_INK;
            inkPoints[type] = MIN(self.maxInkPoint, inkPoints[type] + INK_INCREASEMENT);
            [self.controller didIncreaseInkPoints];
            [self removeGameObjectFromBackground:(RectGameObject *)obj];
            break;
        }
            
        case GameModelGift:
            [self.controller didSendGift];
            [self removeGameObjectFromBackground:(RectGameObject *)obj];
            break;
        default:
            break;
    }
    return nil;
}

- (id)handleGameProjectileCollision:(GameProjectile *)projectile with:(GameObject *)obj {
    switch (obj.model.modelType) {
        case GameModelRunner:
            ((GameRunner *)obj).isDead = YES;
            break;
            
        case GameModelEnemy:
        case GameModelProjectile:
            [self removeGameObjectFromForeground:projectile];
            [self removeGameObjectFromForeground:(RectGameObject *)obj];
            break;
            
        case GameModelGround:
        case GameModelBlockPath:
            [self removeGameObjectFromForeground:projectile];
            break;
            
        default:
            break;
    }
    return nil;
}

- (void)shouldCollide:(NSNotification *)notification {
    // EFFECTS: update world's collisionList to cancel collisions that are not supposed to happen due to game logic
    
    for (CollisionInfo *info in self.world.collisionList) {
        GameObject *obj1 = [self gameObjectForBody:info.body1];
        GameObject *obj2 = [self gameObjectForBody:info.body2];
        NSNumber *res = [shouldCollideManager handle:obj1 with:obj2];
        info.shouldCollide = (res == nil || res.boolValue);
    }
}

- (id)shouldGamePathCollide:(GamePath *)path with:(GameObject *)obj {
    // EFFECTS: reflecting path only collides with GameProjectile
    
    BOOL shouldCollide = path.model.modelType != GameModelReflectPath || obj.model.modelType == GameModelProjectile;
    return [NSNumber numberWithBool:shouldCollide];
}

- (id)shouldGameInkCollide:(GameInk *)ink with:(GameObject *)obj {
    // EFFECTS: GameInk only collides with GameRunner
    
    return [NSNumber numberWithBool:obj.model.modelType == GameModelRunner];
}

- (id)shouldGameQuestionMarkCollide:(GameQuestionMark *)ink with:(GameObject *)obj {
    // EFFECTS: GameQuestionMark only collides with GameRunner
    return [NSNumber numberWithBool:obj.model.modelType == GameModelRunner];
}

- (void)addGameObjectToForeground:(RectGameObject *)obj {
    // EFFECTS: add obj to foreground layer, obj's view will be added to game view
    
    [self.foregroundObjects addObject:obj];
    [self.world addBodyToForeground:obj.body];
    self.bodyToGameObjectDict[obj.body] = obj;
    [self.controller addGameView:obj.view];
}

- (void)addGameObjectToBackground:(RectGameObject *)obj {
    // EFFECTS: add obj to background layer, obj's view will be added to game view
    
    [self.backgroundObjects addObject:obj];
    [self.world addBodyToBackground:obj.body];
    self.bodyToGameObjectDict[obj.body] = obj;
    [self.controller addGameView:obj.view];
}

- (void)removeGameObjectFromForeground:(RectGameObject *)obj {
    // EFFECTS: remove obj from foreground layer, obj's view will be removed from game view
    
    [self.foregroundObjects removeObject:obj];
    [self.world removeBodyFromForeground:obj.body];
    [self.bodyToGameObjectDict removeObjectForKey:obj.body];
    [obj.view removeFromSuperview];
}

- (void)removeGameObjectFromBackground: (RectGameObject *)obj {
    // EFFECTS: remove obj from background layer, obj's view will be removed from game view
    
    [self.backgroundObjects removeObject:obj];
    [self.world removeBodyFromBackground:obj.body];
    [self.bodyToGameObjectDict removeObjectForKey:obj.body];
    [obj.view removeFromSuperview];
}

- (GameObject *)gameObjectForBody:(Body *)body {
    // EFFECTS: get game object associated with the specified body
    
    return self.bodyToGameObjectDict[body];
}

- (void)startGameObjectsAnimation {
    // EFFECTS: start animations of game objects
    
    for (RectGameObject *obj in self.foregroundObjects)
        [obj startAnimation];
    for (RectGameObject *obj in self.backgroundObjects)
        [obj startAnimation];
}

- (void)stopGameObjectsAnimation {
    // EFFECTS: stop animations of game objects
    
    for (RectGameObject *obj in self.foregroundObjects)
        [obj stopAnimation];
    for (RectGameObject *obj in self.backgroundObjects)
        [obj stopAnimation];
}

- (void)step:(double)dt {
    // EFFECTS: advance the game world by time dt
    
    [self updateInkPoints];
    
    GamePath *path = self.paths.lastObject;
    [path refreshView];
    
    // removed stale paths
    for (GamePath *path in [self.paths copy]) {
        path.life--;
        if (path.life == 0) {
            for (Line *l in path.lines) {
                [self.world removeBodyFromBackground:l];
                [self.bodyToGameObjectDict removeObjectForKey:l];
            }
            [path fadeOutView];
            [self.paths removeObject:path];
        }
    }
    
    [self.world step:dt];
    
    // let game objects do some updates
    NSMutableArray *newObjects = [NSMutableArray array];
    for (GameObject *obj in self.foregroundObjects)
        [obj update:newObjects];
    
    // add newly created game objects
    for (RectGameObject *obj in newObjects)
        [self addGameObjectToForeground:obj];
}

- (void)end {
    // EFFECTS: end the game
    
    [self stopGameObjectsAnimation];
}

- (void)cleanUp {
    // EFFECTS: clean up all game objects
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    for (GamePath *path in self.paths)
        [path.view removeFromSuperview];
    
    for(GameObject *obj in self.foregroundObjects)
        [obj.view removeFromSuperview];
    
    for(GameObject *obj in self.backgroundObjects)
        [obj.view removeFromSuperview];
    
    [self.paths removeAllObjects];
    [self.foregroundObjects removeAllObjects];
    [self.backgroundObjects removeAllObjects];
    [self.bodyToGameObjectDict removeAllObjects];
    
    handleCollisionManager = nil;
    shouldCollideManager = nil;
    self.paths = nil;
    self.foregroundObjects = nil;
    self.backgroundObjects = nil;
    self.bodyToGameObjectDict = nil;
    self.world = nil;
}

- (void)updateInkPoints {
    // EFFECTS: increase/decrease inkPoints
    
    inkCounter = (inkCounter + 1) % INK_INC_INTERVAL;
    if (self.drawingLine) {
        if (self.currentInkPoints > 0) {
            self.currentInkPoints--;
        } else if (self.currentInkPoints == 0) {
            [self.controller didUseUpInk];
        }
    } else if (!self.drawingLine && inkCounter == 0) {
        for (int i = 0; i < KINDS_OF_INK; i++) {
            self.inkPoints[i] = MIN(self.maxInkPoint, self.inkPoints[i] + 1);
        }
    }
}

- (int)currentInkPoints {
    return self.inkPoints[self.currentInkType];
}

- (void)setCurrentInkPoints:(int)value {
    self.inkPoints[self.currentInkType] = value;
}

- (GamePath *)startDrawPath:(CGPoint)point {
    // EFFECTS: start drawing path using the specified point as the starting point.
    // RETURNS: the GamePath that is currently being drawn
    
    GameModel *m = [[GameModel alloc] init];
    if (self.currentInkType == GREEN_INK) {
        m.modelType = GameModelReflectPath;
    } else {
        m.modelType = GameModelBlockPath;
    }
    GamePath *path = [[GamePath alloc] initWithModel:m];
    // add first point
    [path addLineTo:CGPointMake(point.x, point.y)];
    
    [self.controller addGameView:path.view];
    [self.paths addObject:path];
    
    self.drawingLine = YES;
    return path;
}

- (void)endDrawPath {
    // EFFECTS: end drawing path
    
    GamePath *path = self.paths.lastObject;
    if (path.lines.count == 0) {
        [path.view removeFromSuperview];
        [self.paths removeObject:path];
    } else {
        path.life = PATH_LIFESPAN;
    }
    self.drawingLine = NO;
}

@end
