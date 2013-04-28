//
//  AudioPlayer.h
//  dsrunner
//
//  Created by sai on 4/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioPlayer : NSObject

+(id)playAudio :(NSString*)filename audioFormat:(NSString*)format;
//EFFECTS: Play the music by given name and format
@end
