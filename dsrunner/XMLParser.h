//
//  XMLParser.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-4-6.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
//OVERVIEW: this class reads a file with given fileName into dictionary.
@interface XMLParser : NSObject

+ (NSDictionary *)parseXML:(NSString *)fileName;
//EFFECT: parse the given xml file and return a parsed dictionary that
//        contains the contents of the xml file.
@end
