//
//  MPWEnvScheme.m
//  MPWShellScriptKit
//
//  Created by Marcel Weiher on 11/25/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//

#import "MPWEnvScheme.h"
#import "MPWGenericBinding.h"
#import <MPWFoundation/DebugMacros.h>

@implementation MPWEnvScheme

-(const char*)cstringValueOfBinding:aBinding
{
    NSString *name=[aBinding name];
    if ( [name hasPrefix:@"/"]) {
        name=[name substringFromIndex:1];
    }

	return getenv([name UTF8String]);
}

extern char ***_NSGetEnviron();

+(NSArray*)getAllEnvironemntVariableNames
{
    char **environ=*_NSGetEnviron();
    NSMutableArray *env=[NSMutableArray array];
    char **envp=environ;
    while (*envp) {
        char *thisenv=*envp;
        char *equals=strchr( thisenv, '=');
        if (equals) {
            [env addObject:[[[NSString alloc] initWithBytes:*envp length:equals-*envp encoding:NSISOLatin1StringEncoding] autorelease]];
        }
        envp++;
    }
    return env;
}



-(BOOL)isBoundBinding:aBinding
{
	return [self cstringValueOfBinding:aBinding] != NULL;
}

-valueForBinding:aBinding
{
    NSString *name=[aBinding name];
//    NSLog(@"%@ valueForBinding:%@",[self class],name);
    if ( [name length]==0 || [name isEqual:@"/"]) {
        return [aBinding childNames];
    } else {
        const char *val=[self cstringValueOfBinding:aBinding];
        if ( val ) {
//            NSLog(@"got %s",val);
            return [NSString stringWithUTF8String:val];
        } else {
            return nil;
        }
    }
}

-(void)setValue:newValue forBinding:aBinding
{
	if ( [newValue isKindOfClass:[MPWBinding class]] ) {
		newValue=[newValue value];
	}
	newValue=[newValue stringValue];
	if ( newValue  ) {
		setenv( [[aBinding name] UTF8String],[newValue UTF8String], 1 );
	} else {
		unsetenv([[aBinding name] UTF8String]);
	}
}

-(BOOL)hasChildren:(MPWGenericBinding*)binding
{
//    NSLog(@"hasChildren: %@",[binding name]);
    return [[binding name] length]==0 || [[binding name] isEqual:@"/"];
}

-childWithName:(NSString*)name of:(MPWGenericBinding*)binding
{
    return nil;
}

-(NSArray*)childrenOf:(MPWGenericBinding*)binding
{
    if ( [self hasChildren:binding]) {
        NSArray *envNames = [[self class] getAllEnvironemntVariableNames];
        NSMutableArray *children=[NSMutableArray array];
        
        for ( NSString *name in envNames) {
            [children addObject:[[binding class] bindingWithName:name scheme:self]];
        }
        NSLog(@"children of '%@': %@",[binding name],children);
        return children;
    }
    return [NSArray array];
}




@end

#import "MPWStCompiler.h"

@implementation MPWEnvScheme(testing)

+(void)testEnvGetAndPut
{
//	EXPECTNIL([MPWStCompiler evaluate:@"env:myvar"] , @"myvar not in env");			   
	putenv("myvar=hi");
	IDEXPECT([MPWStCompiler evaluate:@"env:myvar"],@"hi",@"env:myvar");
	putenv("myvar=hi2");
	IDEXPECT([MPWStCompiler evaluate:@"env:myvar"],@"hi2",@"env:myvar");
	IDEXPECT([MPWStCompiler evaluate:@"env:/myvar"],@"hi2",@"env:/myvar");
	[MPWStCompiler evaluate:@"env:myvar := 42"];
	IDEXPECT( [NSString stringWithUTF8String:getenv("myvar")], @"42", @"getenv after env:myvar := 42");
	[MPWStCompiler evaluate:@"env:myvar := 44"];
	IDEXPECT( [NSString stringWithUTF8String:getenv("myvar")], @"44", @"getenv after env:myvar := 42");
}

+(NSArray*)linesFromCommand:(NSString*)command
{
	FILE *fin = popen([command UTF8String], "r");
    NSMutableArray *result=[NSMutableArray array];
	if ( fin ) {
		char buffer[16390]="";
        char *fgetsResult;
        do {
            fgetsResult=fgets(buffer, 16384, fin);
            if ( strlen(buffer)) {
                [result addObject:[NSString stringWithUTF8String:buffer]];
            }
        } while (fgetsResult!=NULL);
        pclose(fin);
	}
    return result;
}

+(void)testEnvironmentIsInherited
{
	[MPWStCompiler evaluate:@"env:myvar := 900"];
	NSString *echoResult=[[self linesFromCommand:@"/bin/echo -n $myvar"] lastObject];
	IDEXPECT( echoResult, @"900", @"inherited var");
}


+(void)testEnvironmentList
{
//	NSArray *allEnvVars=[self linesFromCommand:@"env"];
	MPWBinding *rootEnv=[MPWStCompiler evaluate:@"ref:env:/"];
    EXPECTTRUE([rootEnv hasChildren],@"root should have children");

//    INTEXPECT( [[rootEnv childNames] count],[allEnvVars count],@"number of environment variables");
}

+(void)testGetAllEnvironemntVariableNames
{
    NSArray *env=[self getAllEnvironemntVariableNames];
    EXPECTFALSE( [env containsObject:@"myCheckVar"], @"the var I put");
    putenv("myCheckVar=hi");
    env=[self getAllEnvironemntVariableNames];
    EXPECTTRUE( [env containsObject:@"myCheckVar"], @"the var I put");
}

+testSelectors
{
	return [NSArray arrayWithObjects:
			@"testEnvGetAndPut",
			@"testEnvironmentIsInherited",
			@"testEnvironmentList",
            @"testGetAllEnvironemntVariableNames",
			nil];
}

@end

