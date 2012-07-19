//
//  Potato.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Potato_d.h"


@implementation Potato_d

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"pote_d.png";
    b2Vec2 vertices[] = {
        b2Vec2(	15.000  / PTM_RATIO, 47.000 / PTM_RATIO),
        b2Vec2(	60.000  / PTM_RATIO, 29.000 / PTM_RATIO),
        b2Vec2(	96.000  / PTM_RATIO, 44.000 / PTM_RATIO),
        b2Vec2(	103.000 / PTM_RATIO, 77.000 / PTM_RATIO),
        b2Vec2(	92.000  / PTM_RATIO, 99.000 / PTM_RATIO),
        b2Vec2(	58.000  / PTM_RATIO, 109.000/ PTM_RATIO),
        b2Vec2(	26.000  / PTM_RATIO, 97.000 / PTM_RATIO),
        b2Vec2(	16.000  / PTM_RATIO, 80.000 / PTM_RATIO)
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
