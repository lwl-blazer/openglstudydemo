//
//  UtilityModel.m
//  OpenGLES_7
//
//  Created by luowailin on 2019/7/11.
//  Copyright © 2019 luowailin. All rights reserved.
//

#import "UtilityModel.h"

@interface UtilityModel ()

@property(copy, nonatomic, readwrite) NSString *name;
@property(strong, nonatomic, readwrite) UtilityMesh *mesh;

@property(assign, nonatomic, readwrite) NSUInteger indexOfFirstCommand;
@property(assign, nonatomic, readwrite) NSUInteger numberOfCommands;

@property(assign, nonatomic, readwrite) AGLKAxisAllignedBoundingBox axisAlignedBoundingBox;

@end

@implementation UtilityModel

static AGLKAxisAllignedBoundingBox UtilityBoundingBoxFromString(NSString *aString){
    NSCParameterAssert(nil != aString);
    
    aString = [aString stringByReplacingOccurrencesOfString:@"{"
                                                 withString:@""];
    
    aString = [aString stringByReplacingOccurrencesOfString:@"}"
                                                 withString:@""];
    
    NSArray *coordsArray = [aString componentsSeparatedByString:@","];
    
    NSCAssert(6 == [coordsArray count],
              @"invalid AGLKAxisAllignedBoundingBox");
    
    AGLKAxisAllignedBoundingBox result;
    
    result.min.x = [[coordsArray objectAtIndex:0] floatValue];
    result.min.y = [[coordsArray objectAtIndex:1] floatValue];
    result.min.z = [[coordsArray objectAtIndex:2] floatValue];
    
    result.max.x = [[coordsArray objectAtIndex:3] floatValue];
    result.max.y = [[coordsArray objectAtIndex:4] floatValue];
    result.max.z = [[coordsArray objectAtIndex:5] floatValue];
    
    return result;
}

- (instancetype)init{
    NSAssert(NO, @"Invalid initializer");
    return nil;
}

- (instancetype)initWithName:(NSString *)aName
                        mesh:(UtilityMesh *)aMesh
         indexOfFirstCommand:(NSUInteger)aFirstIndex
            numberOfCommands:(NSUInteger)count axisAlignedBoundingBox:(AGLKAxisAllignedBoundingBox)aBoundingBox{
    self = [super init];
    if (self) {
        self.mesh = aMesh;
        self.name = aName;
        self.indexOfFirstCommand = aFirstIndex;
        self.numberOfCommands = count;
        self.axisAlignedBoundingBox = aBoundingBox;
    }
    return self;
}

- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary
                                       mesh:(UtilityMesh *)aMesh{
    NSString *name = [aDictionary objectForKey:UtilityModelName];
    NSUInteger aFirstIndex = [[aDictionary objectForKey:UtilityModelIndexOfFirstCommand] unsignedIntegerValue];
    NSUInteger aNumberOfCommands = [[aDictionary objectForKey:UtilityModelNumberOfCommands] unsignedIntegerValue];
    
    NSString *anAxisAlignedBoundingBoxString = [aDictionary objectForKey:UtilityModelAxisAlignedBoundingBox];
    
    AGLKAxisAllignedBoundingBox box = UtilityBoundingBoxFromString(anAxisAlignedBoundingBoxString);
    
    return [self initWithName:name
                         mesh:aMesh
          indexOfFirstCommand:aFirstIndex
             numberOfCommands:aNumberOfCommands
       axisAlignedBoundingBox:box];
}

@end

NSString *const UtilityModelName = @"name";
NSString *const UtilityModelIndexOfFirstCommand = @"indexOfFirstCommand";
NSString *const UtilityModelNumberOfCommands = @"numberOfCommands";
NSString *const UtilityModelAxisAlignedBoundingBox = @"axisAlignedBoundingBox";
NSString *const UtilityModelDrawingCommand = @"command";
