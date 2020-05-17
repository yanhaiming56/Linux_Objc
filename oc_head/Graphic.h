/*
 * @Author: your name
 * @Date: 2020-05-16 21:08:59
 * @LastEditTime: 2020-05-17 08:52:32
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /MyOC/oc_head/Graphic.h
 */

#import <Foundation/Foundation.h>

#import "People.h"

@interface Graphic : NSObject
{
    int ID;
    People *people;
}

@property(nonatomic, assign) int ID;
@property(nonatomic, assign) People *people;

@end