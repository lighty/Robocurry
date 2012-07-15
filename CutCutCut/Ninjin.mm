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
    int count = 6;
    NSString* file = @"ninjin_200x.png";
    b2Vec2 vertices[] = {
        b2Vec2(-26.5f / PTM_RATIO, 47.7f / PTM_RATIO),
        b2Vec2(-37.1f / PTM_RATIO, 29.3f / PTM_RATIO),
        b2Vec2(-4.6f / PTM_RATIO, -90.9f / PTM_RATIO),
        b2Vec2(8.8f / PTM_RATIO, -93.7f / PTM_RATIO),
        b2Vec2(39.2f / PTM_RATIO, 31.5f / PTM_RATIO),
        b2Vec2(27.2f / PTM_RATIO, 47.7f / PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld:world
                                   position:b2Vec2(screen.width/2/PTM_RATIO, screen.height/2/PTM_RATIO) 
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
