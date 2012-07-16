//
//  Potato.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Potato.h"


@implementation Potato

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"potato.png";
    b2Vec2 vertices[] = {
        b2Vec2(6.0 / PTM_RATIO, 69.0 / PTM_RATIO),
        b2Vec2(43.0 / PTM_RATIO, 49.0 / PTM_RATIO),
        b2Vec2(68.0 / PTM_RATIO, 59.0 / PTM_RATIO),
        b2Vec2(70.0 / PTM_RATIO, 79.0 / PTM_RATIO),
        b2Vec2(71.8 / PTM_RATIO, 109.0 / PTM_RATIO),
        b2Vec2(54.0 / PTM_RATIO, 127.0 / PTM_RATIO),
        b2Vec2(21.0 / PTM_RATIO, 127.0 / PTM_RATIO),
        b2Vec2(4.0 / PTM_RATIO, 106.0 / PTM_RATIO)
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
        
    }
    return self;
}

@end
