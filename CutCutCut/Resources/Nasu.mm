//
//  Nasu.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/08/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Nasu.h"


@implementation Nasu

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"nasu.png";
    b2Vec2 vertices[] = {
        b2Vec2(125.0 / PTM_RATIO, 125.0 / PTM_RATIO),
        b2Vec2(89.0 / PTM_RATIO, 128.0 / PTM_RATIO),
        b2Vec2(12.0 / PTM_RATIO, 44.0 / PTM_RATIO),
        b2Vec2(2.0 / PTM_RATIO, 21.0   / PTM_RATIO),
        b2Vec2(11.0 / PTM_RATIO, 0.0 / PTM_RATIO),
        b2Vec2(48.0 / PTM_RATIO, 0.0 / PTM_RATIO),
        b2Vec2(86.0 / PTM_RATIO, 29.0 / PTM_RATIO),
        b2Vec2(120.0 / PTM_RATIO, 92.75 / PTM_RATIO)
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
        _tag = kTagVegeNasu;
    }
    return self;
}

@end
