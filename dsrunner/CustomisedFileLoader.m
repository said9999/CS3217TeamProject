//
//  CustomisedFileLoader.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-4-23.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "CustomisedFileLoader.h"

@implementation CustomisedFileLoader
+ (NSArray*)getAllFilesUnderGameDirectory{
    //EFFECTS: return an array of strings of the fileNames under the document directory
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *browseError;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory
                                                      error:&browseError];
    
    return files;
}

+ (NSString*)getLevelPath:(NSString*)levelName{
    //EFFECTS: return the full path of given levelName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:levelName];
    return filePath;
}
@end
