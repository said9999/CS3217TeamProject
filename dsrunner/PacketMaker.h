//
//  PacketMaker.h
//  dsrunner
//
//  Created by sai on 4/16/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@protocol MakerDelegate <NSObject>

- (void)blinkMultiScreen;
- (void)upsideDownMultiScreen;
- (NSMutableArray*) getForegroundObjects;
- (NSMutableArray*) getPaths;
- (int) getCurrentOffset;

@end

/**OVERVIEW:
 * This class make and return data packet according specific gamedata type
 * The pattern is singleton here.
 * Its delegate is SingleViewController
 */
@interface PacketMaker : NSObject

@property (weak) id <MakerDelegate> delegate;

+ (id) sharedInstance;
//EFFECT: return a shared instance
- (NSData*)sendPacketWithType:(GAMEDATA)type;
//EFFECT: return a packet with given type

@end
