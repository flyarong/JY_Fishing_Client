//
//  AutonomousStringCopy.m
//  Unity-iPhone
//
//  Created by holdenjing on 2020/5/18.
//

#import <Foundation/Foundation.h>

const char *GDTAutonomousStringCopy(const char *string);


const char *GDTAutonomousStringCopy(const char *string)
{
    if (string == NULL) {
        return NULL;
    }
    char *res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}
