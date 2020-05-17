#import <stdio.h>
#import <Foundation/Foundation.h>

#import "Graphic.h"

int main( int argc, const char * argv[] ) 
{
    @autoreleasepool 
    {
        NSString* nsStr = [[NSString alloc] init];
        NSLog(@"say: hello world\n");
        NSLog(@"use the foudation\n");
        NSLog(@"NSlog Object C\n");
        NSLog(@"%@", nsStr);

        Graphic* graphic = [[Graphic alloc] init];
        NSLog(@"%s", graphic.people->getName().c_str());
    }
    
    return 0;

}