#import "Graphic.h"

@implementation Graphic
@synthesize ID, people;

-(id)init
{
    self = [super init];
    if (self)
    {
        self.ID = 1;
        self.people = new People();
    }
    return self;
}

@end