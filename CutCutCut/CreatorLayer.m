//
//  CreatorLayer.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CreatorLayer.h"
#import "TitleLayer.h"

@implementation CreatorLayer

+(id) scene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	CCScene* scene = [CCScene node];
	CreatorLayer* layer = [CreatorLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCLabelTTF* kihaLabel = [CCLabelTTF labelWithString:@"キーハ" fontName:@"Marker Felt" fontSize:32];
		kihaLabel.color = ccGREEN;
		kihaLabel.position = CGPointMake(size.width / 2, size.height / 4 * 4 - 20);
		[self addChild:kihaLabel];
        
		CCLabelTTF* lightLabel = [CCLabelTTF labelWithString:@"ライト" fontName:@"Marker Felt" fontSize:32];
		lightLabel.color = ccGREEN;
		lightLabel.position = CGPointMake(size.width / 2, size.height / 4 * 3 - 20);
		[self addChild:lightLabel];
        
		CCLabelTTF* starLabel = [CCLabelTTF labelWithString:@"スター" fontName:@"Marker Felt" fontSize:32];
		starLabel.color = ccGREEN;
		starLabel.position = CGPointMake(size.width / 2, size.height / 4 * 2 - 20);
		[self addChild:starLabel];

        CCMenuItem *returnItem = [CCMenuItemFont itemWithString:@"戻る" target:self selector:@selector(onReturn:)];
        CCMenu *menu = [CCMenu menuWithItems:returnItem, nil];
        menu.position = ccp(size.width / 2, size.height / 4 * 1 - 20);
        [self addChild:menu];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

-(void) onReturn:(id)item
{
    [[CCDirector sharedDirector] popScene];
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
