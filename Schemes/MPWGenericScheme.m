//
//  MPWGenericScheme.m
//  MPWTalk
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import "MPWGenericScheme.h"
#import "MPWGenericBinding.h"

@implementation MPWGenericScheme

-contentForPath:(NSArray*)array
{
    return nil;
}

-(NSArray*)pathArrayForPathString:(NSString*)uri
{
	NSArray *pathArray = [uri componentsSeparatedByString:@"/"];
    if ( [pathArray count] > 1 && [[pathArray lastObject] length] == 0 ) {
        pathArray=[pathArray subarrayWithRange:NSMakeRange(0, [pathArray count]-1)];
    }
    return pathArray;
}

-contentForURI:uri
{
    return [self contentForPath:[self pathArrayForPathString:uri]];               
}

-(MPWBinding*)bindingForName:uriString inContext:aContext
{
	return [[[MPWGenericBinding alloc] initWithName:uriString scheme:self] autorelease];
}

-valueForBinding:(MPWGenericBinding*)aBinding
{
    return nil;
}

-(void)setValue:newValue forBinding:aBinding
{
    
}

-(BOOL)hasChildren:(MPWGenericBinding*)binding
{
    return NO;
}

-childWithName:(NSString*)name of:(MPWGenericBinding*)binding
{
    return nil;
}

-(NSArray*)childrenOf:(MPWGenericBinding*)binding
{
    return @[];
}


@end
