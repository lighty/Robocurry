//
//  Pork.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/08/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Pork.h"


@implementation Pork

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"pork.png";
    b2Vec2 vertices[] = {
        b2Vec2(126.0 / PTM_RATIO, 60.0 / PTM_RATIO),
        b2Vec2(93.0 / PTM_RATIO, 89.0 / PTM_RATIO),
        b2Vec2(28.0 / PTM_RATIO, 96.0 / PTM_RATIO),
        b2Vec2(13.0 / PTM_RATIO, 80.0   / PTM_RATIO),
        b2Vec2(2.0 / PTM_RATIO, 47.0 / PTM_RATIO),
        b2Vec2(10.0 / PTM_RATIO, 36.0 / PTM_RATIO),
        b2Vec2(69.0 / PTM_RATIO, 30.0 / PTM_RATIO),
        b2Vec2(118.0 / PTM_RATIO, 42.0 / PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld:world
                                   position:b2Vec2(screen.width/2/PTM_RATIO, screen.height/4/PTM_RATIO) 
                                   rotation:0
                                   vertices:vertices
                                vertexCount:count
                                    density:5.0
                                   friction:0.2
                                restitution:0.2];
    if((self = [super initWithFile:file body:body original:YES]))
    {
        _tag = kTagVegePork;
    }
    return self;
}

@end
