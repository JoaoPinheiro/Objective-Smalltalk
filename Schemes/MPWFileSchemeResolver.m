//
//  MPWFileSchemeResolver.m
//  MPWShellScriptKit
//
//  Created by Marcel Weiher on 6/7/08.
//  Copyright 2008 Apple. All rights reserved.
//

#import "MPWFileSchemeResolver.h"
#import "MPWFileBinding.h"
#import "MPWDirectoryBinding.h"
#import "MPWFileWatcher.h"

@implementation MPWFileSchemeResolver


-(void)startWatching:(MPWFileBinding*)binding
{
    NSString *path=[binding path];
    NSString *dir=[path stringByDeletingLastPathComponent];
    
    [[MPWFileWatcher watcher] watchFile:path withDelegate:binding];
    [[MPWFileWatcher watcher] watchFile:dir withDelegate:binding];
    
}



-bindingForName:aName inContext:aContext
{
//	id binding = [MPWBinding bindingWithValue:[NSString stringWithContentsOfFile:aName]];
	id binding = [[[MPWFileBinding alloc] initWithPath:aName] autorelease];
	return binding;
}

-valueForBinding:aBinding
{
    if ( [aBinding isKindOfClass:[MPWFileBinding class]] ) {
        return [aBinding value];
    } else {
//        return [[[self bindingForName:[aBinding name] inContext:nil] value] rawData];
        return [[self bindingForName:[aBinding name] inContext:nil] value];
    }
}


-(NSArray*)childrenOf:(MPWBinding*)binding
{
    return [binding children];
}

-(NSArray *)completionsForPartialName:(NSString *)partialName inContext:aContext
{
    NSArray *childNames = [[self bindingForName:@"." inContext:aContext] childNames];
    NSMutableArray *names=[NSMutableArray array];
    for ( NSString *name in childNames) {
        if ( !partialName || [partialName length]==0 || [name hasPrefix:partialName]) {
            [names addObject:name];
        }
    }
    return names;
}


@end
#import "MPWStCompiler.h"

@implementation MPWFileSchemeResolver(testing)


+(void)testGettingASimpleFile
{
	NSString *tempUrlString = @"file:/tmp/fileSchemeTest.txt";
	NSString *textString = @"hello world!";
	[textString writeToURL:[NSURL URLWithString:tempUrlString] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	IDEXPECT([[MPWStCompiler evaluate:tempUrlString] stringValue],textString, @"get test file");
}


+testSelectors
{
	return [NSArray arrayWithObjects:
			@"testGettingASimpleFile",
			nil];
}


@end

