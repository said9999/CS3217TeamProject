//
//  AudioPlayer.m
//  dsrunner
//
//  Created by sai on 4/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
@implementation AudioPlayer

+ (AVAudioPlayer*)playAudio:(NSString*)filename audioFormat:(NSString*)format{
    NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:format];
    NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
    AVAudioPlayer *myPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    myPlayer.volume = 1;
    myPlayer.numberOfLoops = 0;
    return myPlayer;
}

@end
