//
//  Game.h
//  dsrunner
//
//  Created by Light on 19/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import "PairHandlerManager.h"
#import "RectGameObject.h"
#import "GameControllerDelegate.h"
#import "GamePath.h"

@interface Game : NSObject
// OVERVIEW:
// This class contains basic game logic and manage physics world.
// It requires a GameControllerDelegate to handle view updates and game events.

- (id)initWithController:(id<GameControllerDelegate>)controller;

@property (readonly, weak) id<GameControllerDelegate> controller;

@property (readonly) World *world;
@property (readonly) NSMutableArray *foregroundObjects;
@property (readonly) NSMutableArray *backgroundObjects;
@property (readonly) NSMutableArray *paths;
@property (readonly) NSMutableDictionary *bodyToGameObjectDict;

@property (readonly) int *inkPoints;
@property (readonly) BOOL drawingLine;
@property int maxInkPoint;
@property int currentInkType;
@property int currentInkPoints;

- (void)addGameObjectToForeground:(RectGameObject *)obj;
// EFFECTS: add obj to foreground layer, obj's view will be added to game view
- (void)addGameObjectToBackground:(RectGameObject *)obj;
// EFFECTS: add obj to background layer, obj's view will be added to game view
- (void)removeGameObjectFromForeground:(RectGameObject *)obj;
// EFFECTS: remove obj from foreground layer, obj's view will be removed from game view
- (void)removeGameObjectFromBackground: (RectGameObject *)obj;
// EFFECTS: remove obj from background layer, obj's view will be removed from game view

- (GameObject *)gameObjectForBody:(Body *)body;
// EFFECTS: get game object associated with the specified body

- (void)startGameObjectsAnimation;
// EFFECTS: start animations of game objects
- (void)stopGameObjectsAnimation;
// EFFECTS: stop animations of game objects

- (void)step:(double)dt;
// EFFECTS: advance the game world by time dt
- (void)end;
// EFFECTS: end the game
- (void)cleanUp;
// EFFECTS: clean up all game objects

- (GamePath *)startDrawPath:(CGPoint)point;
// EFFECTS: start drawing path using the specified point as the starting point.
// RETURNS: the GamePath that is currently being drawn
- (void)endDrawPath;
// EFFECTS: end drawing path

@end
