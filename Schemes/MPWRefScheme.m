//
//  MPWRefScheme.m
//  MPWTalk
//
//  Created by Marcel Weiher on 25.12.09.
//  Copyright 2009 Marcel Weiher. All rights reserved.
//

#import "MPWRefScheme.h"
#import "MPWBinding.h"
#import "MPWEvaluator.h"
#import "MPWRecursiveIdentifier.h"

@implementation MPWRefScheme

-bindingForName:(NSString*)variableName inContext:(MPWEvaluator*)aContext
{
	MPWBinding* originalBinding = [[aContext schemeForName:@"var"]  bindingForName:variableName inContext:aContext];
	id binding = [[[MPWBinding alloc] initWithValue:originalBinding] autorelease];
	return binding;
}

-bindingWithIdentifier:(MPWRecursiveIdentifier*)anIdentifier withContext:(MPWEvaluator*)aContext
{
	MPWIdentifier* nextIdentifer = [anIdentifier nextIdentifer];
	NSAssert1( [nextIdentifer scheme], @"nextIdentifer", nil );
	id originalBinding = [[nextIdentifer scheme] bindingWithIdentifier:nextIdentifer withContext:aContext];
//	NSLog(@"eval ref, original binding: %@",originalBinding);
	id binding = [[[MPWBinding alloc] initWithValue:originalBinding] autorelease];
//	NSLog(@"eval ref, ref binding: %@",binding);
	return binding;
}


@end
