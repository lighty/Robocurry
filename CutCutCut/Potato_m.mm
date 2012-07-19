//
//  Potato.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Potato_m.h"


@implementation Potato_m

-(id)initWithWorld:(b2World*)world
{
    int count = 8;
    NSString* file = @"pote_m.png";
    b2Vec2 vertices[] = {
        b2Vec2(	15.000  / PTM_RATIO, 80.000 / PTM_RATIO),
        b2Vec2(	6.000   / PTM_RATIO, 52.000 / PTM_RATIO),
        b2Vec2(	14.000  / PTM_RATIO, 31.000 / PTM_RATIO),
        b2Vec2(	44.000  / PTM_RATIO, 18.000 / PTM_RATIO),
        b2Vec2(	107.000 / PTM_RATIO, 25.000 / PTM_RATIO),
        b2Vec2(	120.000 / PTM_RATIO, 40.000 / PTM_RATIO),
        b2Vec2(	120.000 / PTM_RATIO, 66.000 / PTM_RATIO),
        b2Vec2(	56.000  / PTM_RATIO, 90.000 / PTM_RATIO)
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
