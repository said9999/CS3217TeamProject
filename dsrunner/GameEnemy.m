//
//  GameEnemy.m
//  dsrunner
//
//  Created by Light on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameEnemy.h"
#import "GameProjectile.h"
#import "EngineConstants.h"

@interface GameEnemy () {
    int speed;
    int projectileCounter;
}

@end

@implementation GameEnemy

- (id)initWithModel:(GameModel *)m {
    self = [super initWithModel:m];
    if (self) {
        self.body.width = ENEMY_WIDTH;
        self.body.height = ENEMY_HEIGHT;
        self.body.velocity.x = speed = -ENEMY_VELOCITY;
        projectileCounter = 0;
    }
    return self;
}

- (void)update:(NSMutableArray *)newObjects {
    [self moveForwardAndTurnAroundIfStopped:&speed];
    [super update:newObjects];
    
    if (self.body.velocity.x > 0) {
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        self.view.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    projectileCounter++;
    if (projectileCounter == PROJECTILE_GENERATION_INTERVAL) {
        projectileCounter = 0;
        
        CGSize size = CGSizeMake(PROJECTILE_WIDTH, PROJECTILE_HEIGHT);
        double pos = self.body.center.x;
        pos += (speed > 0 ? 1 : -1) * (self.body.width / 2 + size.width / 2);
        CGPoint center = CGPointMake(pos, self.body.center.y);
        
        GameModel *m = [[GameModel alloc] initWithType:GameModelProjectile center:center size:size];
        GameProjectile *projectile = [[GameProjectile alloc] initWithModel:m];
        projectile.body.velocity.x = projectile.velocity.x = speed * 2;
        projectile.body.isGravityAware = NO;
        projectile.body.canMoveAlongLine = NO;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor blackColor];
        projectile.view = view;
        
        [newObjects addObject:projectile];
    }
}
@end
