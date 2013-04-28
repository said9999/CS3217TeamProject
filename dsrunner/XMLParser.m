//
//  XMLParser.m
//  dsrunner
//
//  Created by Chen Zeyu on 13-4-6.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import "XMLParser.h"
#import "XMLReader.h"
#import "Constants.h"
//OVERVIEW: this class reads a file with given fileName into dictionary.

@implementation XMLParser

+ (NSDictionary *)parseXML:(NSString *)fileName{
//EFFECT: parse the given xml file and return a parsed dictionary that
//        contains the contents of the xml file.
    NSError *error=nil;
    NSString *path;
    if([fileName hasPrefix:@"user_"]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
    }
    else path = [[NSBundle mainBundle] bundlePath];
    NSString *xmlPath = [path stringByAppendingPathComponent:fileName];
    NSString *xmlString = [NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dict = [XMLReader dictionaryForXMLString:xmlString error:&error];
    return dict;
}
@end
