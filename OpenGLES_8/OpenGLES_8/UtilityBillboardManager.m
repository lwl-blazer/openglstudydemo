//
//  UtilityBillboardManager.m
//  OpenGLES_8
//
//  Created by luowailin on 2019/7/22.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityBillboardManager.h"
#import "UtilityBillboard.h"

@interface UtilityBillboardManager ()

@property(nonatomic, strong, readwrite) NSMutableArray *mutableSortedBillboards;

@property(nonatomic, strong, readwrite) NSArray *sortedBillboards;

@end

@implementation UtilityBillboardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mutableSortedBillboards = [NSMutableArray array];
        self.shouldRenderSpherical = YES;
    }
    return self;
}

- (void)updateWithEyePosition:(GLKVector3)eyePosition
                lookDirection:(GLKVector3)lookDirection{
    lookDirection = GLKVector3Normalize(lookDirection);
    
    for (UtilityBillboard *currentBillboard in self.sortedBillboards) {
        [currentBillboard updateWithEyePosition:eyePosition
                                  lookDirection:lookDirection];
    }
    
    [self.mutableSortedBillboards sortUsingFunction:UtilityCompareBillboardDistance
                                            context:NULL];
}

- (NSArray *)sortedBillboards{
    return self.mutableSortedBillboards.copy;
}

static const NSInteger UtilityMaximumNumberOfBillboards = (4000);
- (void)addBillboard:(UtilityBillboard *)aBillboard{
    const NSInteger count = self.mutableSortedBillboards.count;
    if (UtilityMaximumNumberOfBillboards > count) {
        [self.mutableSortedBillboards addObject:aBillboard];
    } else {
        NSLog(@"Attempt to add too many billboards");
    }
}

- (void)addBillboardAtPosition:(GLKVector3)aPosition
                          size:(GLKVector2)aSize
              minTextureCoords:(GLKVector2)minCoords
              maxTextureCoords:(GLKVector2)maxCoords{
    UtilityBillboard *newBillboard = [[UtilityBillboard alloc] initWithPosition:aPosition
                                                                           size:aSize
                                                               minTextureCoords:minCoords
                                                               maxTextureCoords:maxCoords];
    [self addBillboard:newBillboard];
}

@end
