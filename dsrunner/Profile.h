//
//  Profile.h
//  dsrunner
//
//  Created by Light on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

// OVERVIEW: this header file is used for profiling

#ifndef dsrunner_Profile_h
#define dsrunner_Profile_h

#include <sys/time.h>

unsigned long getMSTime () {
    struct timeval time;
    gettimeofday(&time, NULL);
    return (time.tv_sec * 1000) + (time.tv_usec / 1000);
}

#endif
