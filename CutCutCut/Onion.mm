//
//  Onion.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Onion.h"


@implementation Onion

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"onion.png";
    b2Vec2 vertices[] = {
        b2Vec2(117.0 / PTM_RATIO, 27.0 / PTM_RATIO),  
        b2Vec2(116.0 / PTM_RATIO, 54.0 / PTM_RATIO),
        b2Vec2(81.0  / PTM_RATIO, 120.0/ PTM_RATIO),
        b2Vec2(58.0  / PTM_RATIO, 115.0/ PTM_RATIO),
        b2Vec2(18.0  / PTM_RATIO, 60.0 / PTM_RATIO),
        b2Vec2(20.0  / PTM_RATIO, 30.0 / PTM_RATIO),
        b2Vec2(47.0  / PTM_RATIO, 4.0  / PTM_RATIO),
        b2Vec2(85.0  / PTM_RATIO, 4.0  / PTM_RATIO)
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
        _tag = kTagVegeOnion;
    }
    return self;
}

@end
