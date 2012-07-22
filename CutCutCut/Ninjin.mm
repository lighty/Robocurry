//
//  Ninjin.m
//  CutCutCut
//
//  Created by 光 渡邊 on 12/07/09.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Ninjin.h"


@implementation Ninjin

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"caro.png";
    b2Vec2 vertices[] = {
        b2Vec2(171.0 / PTM_RATIO, 195.0 / PTM_RATIO),
        b2Vec2(152.0 / PTM_RATIO, 187.0 / PTM_RATIO),
        b2Vec2(61.0 / PTM_RATIO, 61.0 / PTM_RATIO),
        b2Vec2(75.0 / PTM_RATIO, 47.0   / PTM_RATIO),
        b2Vec2(200.0 / PTM_RATIO, 150.0 / PTM_RATIO),
        b2Vec2(202.0 / PTM_RATIO, 168.0 / PTM_RATIO),
        b2Vec2(198.0 / PTM_RATIO, 180.0 / PTM_RATIO),
        b2Vec2(188.0 / PTM_RATIO, 190.0 / PTM_RATIO)
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
        _tag = kTagVegeNinjin;
    }
    return self;
}

@end
