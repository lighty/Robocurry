//
//  TitleLayer.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TitleLayer.h"
#import "GameLayer.h"
#import "CreatorLayer.h"

@implementation TitleLayer

+(id) scene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	CCScene* scene = [CCScene node];
	TitleLayer* layer = [TitleLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
		CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:@"ロボカレー" fontName:@"Marker Felt" fontSize:32];
		titleLabel.color = ccGREEN;
		CGSize size = [[CCDirector sharedDirector] winSize];
		titleLabel.position = CGPointMake(size.width / 2, size.height / 4 * 3);
		[self addChild:titleLabel];
		
        // setup menu
        CCMenuItem *startItem = [CCMenuItemFont itemWithString:@"start" target:self selector:@selector(onStart:)];
        CCMenuItem *createrItem = [CCMenuItemFont itemWithString:@"作った人たち" target:self selector:@selector(onCreator:)];
        CCMenu *menu = [CCMenu menuWithItems:startItem, createrItem, nil];
        menu.position = ccp(size.width / 2, size.height / 4 * 2);
        [menu alignItemsVertically];
        [self addChild:menu];
        
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) onStart:(id)item
{
    CCTransitionSlideInL* transition = [CCTransitionSlideInL transitionWithDuration:0.5 scene:[GameLayer scene]];
    [[CCDirector sharedDirector] pushScene:transition];
}

-(void) onCreator:(id)item
{
    CCScene *scene;
    scene = [CreatorLayer scene];
    //[self addChild:scene];
    CCTransitionSlideInL* transition = [CCTransitionSlideInL transitionWithDuration:0.5 scene:scene];
    [[CCDirector sharedDirector] pushScene:transition];
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}



@end
