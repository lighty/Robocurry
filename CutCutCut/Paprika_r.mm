//
//  Papurika_r.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/08/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Paprika_r.h"


@implementation Paprika_r

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"paprika_r.png";
    b2Vec2 vertices[] = {
        b2Vec2(87.0 / PTM_RATIO, 128.0 / PTM_RATIO),
        b2Vec2(44.0 / PTM_RATIO, 127.0 / PTM_RATIO),
        b2Vec2(10.25 / PTM_RATIO, 63.0 / PTM_RATIO),
        b2Vec2(9.0 / PTM_RATIO, 31.0   / PTM_RATIO),
        b2Vec2(36.0 / PTM_RATIO, 0.0 / PTM_RATIO),
        b2Vec2(56.0 / PTM_RATIO, 0.0 / PTM_RATIO),
        b2Vec2(110.0 / PTM_RATIO, 44.0 / PTM_RATIO),
        b2Vec2(120.0 / PTM_RATIO, 75.0 / PTM_RATIO)
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
        _tag = kTagVegePaprika_r;
    }
    return self;
}

@end
