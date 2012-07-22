//
//  Lue.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Roo.h"


@implementation Roo

-(id)initWithWorld:(b2World*)world
{
    int count = 6;
    NSString* file = @"roo.png";
    b2Vec2 vertices[] = {
        b2Vec2(127.0 / PTM_RATIO, 14.5 / PTM_RATIO),
        b2Vec2(118.0 / PTM_RATIO, 112.0 / PTM_RATIO),
        b2Vec2(112.0 / PTM_RATIO, 114.0 / PTM_RATIO),
        b2Vec2(35.0 / PTM_RATIO, 114.0   / PTM_RATIO),
        b2Vec2(7.0 / PTM_RATIO, 112.0 / PTM_RATIO),
        b2Vec2(0.0 / PTM_RATIO, 15.0 / PTM_RATIO)
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
        _tag = kTagRoo;
    }
    return self;
}

@end
