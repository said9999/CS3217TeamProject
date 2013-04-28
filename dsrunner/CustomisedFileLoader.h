//
//  CustomisedFileLoader.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-4-23.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
//OVERVIEW: this class serves as a helper to load all customised levels stored in iPad.
@interface CustomisedFileLoader : NSObject
+ (NSArray*)getAllFilesUnderGameDirectory;
//EFFECTS: returns all customised level names as NSString in a NSArray
+ (NSString*)getLevelPath:(NSString*)levelName;
    //EFFECTS: return the full path of given levelName;
@end
