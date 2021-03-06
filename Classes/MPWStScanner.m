/* MPWStScanner.m created by marcel on Tue 04-Jul-2000 */

#import "MPWStScanner.h"

@interface MPWStName  : NSString
{
    NSString *realString;
}

@end

@implementation MPWStName

objectAccessor(NSString, realString, setRealString)

-initWithString:(NSString*)newString
{
    self=[super init];
    [self setRealString:newString];
    return self;
}

-(unichar)characterAtIndex:(NSUInteger)index
{
    return [realString characterAtIndex:index];
}

-(NSUInteger)length
{
    return [realString length];
}

-(void)dealloc
{
    [realString release];
    [super dealloc];
}

-(BOOL)isLiteral
{
    return NO;
}

@end



@implementation NSObject(isLiteral)


-(BOOL)isLiteral
{
    return YES;
}

-(BOOL)isToken
{
    return ![self isLiteral];
}

-(BOOL)isKeyword
{
    return NO;
}

-(BOOL)isBinary
{
    return NO;
}

@end

@implementation NSString(isKeyword)

-(BOOL)isKeyword
{
    return [self hasSuffix:@":"];
}

-(BOOL)isBinary
{
    unichar start=[self characterAtIndex:0];
    return start=='@' || start=='+' || start=='-' ||
        start=='*' || start=='/' || start==',' || start=='>' || start=='<' || start=='=' || start > 256;
}

-(BOOL)isScheme
{
	return [self isKeyword];
}

@end

@implementation MPWSubData(isLiteral)

-(BOOL)isLiteral
{
    return NO;
}

@end

@implementation MPWStScanner

scalarAccessor( Class, intClass, setIntClass )
scalarAccessor( Class, floatClass, setFloatClass )
scalarAccessor( Class, stringClass, setStringClass )
idAccessor( tokens, setTokens )
boolAccessor( noNumbers, setNoNumbers )

-(Class)defaultIntClass
{
	return [NSNumber class];
}

-(Class)defaultFloatClass
{
	return [NSNumber class];
}

-(Class)defaultStringClass
{
	return [NSString class];
}

-initWithDataSource:aDataSource
{
	self = [super initWithDataSource:aDataSource];
	[self setIntClass:[self defaultIntClass]];
	[self setFloatClass:[self defaultFloatClass]];
	[self setStringClass:[self defaultStringClass]];
	[self setTokens:[NSMutableArray array]];
	return self;
}


-(void)_initCharSwitch
{
    unsigned int i;

    [super _initCharSwitch];
    for (i=0;i<128;i++) {
        if ( isalpha(i)  ) {
            charSwitch[i]=(IMP0)[self methodForSelector:@selector(scanASCIIName)];
        } else if (isdigit(i) ) {
            charSwitch[i]=(IMP0)[self methodForSelector:@selector(scanNumber)];
        } else if (isspace(i)  ) {
            charSwitch[i]=(IMP0)[self methodForSelector:@selector(skipSpace)];
//        } else if (  i=='-' ) {
//          charSwitch[i]=[self methodForSelector:@selector(scanNegativeNumber)];
        } else  {
            charSwitch[i]=(IMP0)[self methodForSelector:@selector(scanSpecial)];
        }
    }
    for (i=128;i<256;i++) {
        charSwitch[i]=(IMP0)[self methodForSelector:@selector(scanUTF8Name)];
    }
    charSwitch['\'']=(IMP0)[self methodForSelector:@selector(scanString)];
    charSwitch['\"']=(IMP0)[self methodForSelector:@selector(scanComment)];
    charSwitch['<']=(IMP0)[self methodForSelector:@selector(scanSpecial)];
    charSwitch['+']=(IMP0)[self methodForSelector:@selector(scanSpecial)];
    charSwitch['[']=(IMP0)[self methodForSelector:@selector(scanSpecial)];
    charSwitch['-']=(IMP0)[self methodForSelector:@selector(scanSpecial)];
    charSwitch[':']=(IMP0)[self methodForSelector:@selector(scanPossibleAssignment)];
    charSwitch['=']=(IMP0)[self methodForSelector:@selector(scanPossibleEquals)];
    charSwitch['_']=(IMP0)[self methodForSelector:@selector(scanASCIIName)];
    charSwitch[0]=(IMP0)[self methodForSelector:@selector(skip)];
//    charSwitch[10]=[self methodForSelector:@selector(skip)];
//    charSwitch[13]=[self methodForSelector:@selector(skip)];
}



static inline int decodeUTF8FirstByte( int ch, int *numChars)
{
    int retval=0;
    if ( ch <= 0x7f) {
        retval = ch;
        *numChars=0;
    } else if ( (ch & 0xE0) == 0xC0 ) {
        retval = ch & 31;
        *numChars=1;
    } else if ( (ch & 0xF0) == 0xE0 ) {
        retval = ch & 15;
        *numChars=2;
    } else if ( (ch & 0xF8) == 0xF0 ) {
        retval = ch & 7;
        *numChars=3;
    } else if ( (ch & 0xFC) == 0xF8 ) {
        retval = ch & 3;
        *numChars=4;
    } else if ( (ch & 0xFE) == 0xFC ) {
        retval = ch & 1;
        *numChars=5;
    } else {
        
    }
    return retval;
}


-(int)scanUTF8Char
{
    int theChar=0;
    const unsigned char *cur=(const unsigned char *)pos;
    theChar = *cur;
    int numRemainderBytes=0;
    theChar=decodeUTF8FirstByte(theChar, &numRemainderBytes);
    cur++;
    for (int i=0;i<numRemainderBytes;i++) {
        theChar=(theChar<< 6) | ((*cur++) & 0x3f);
    }
    pos=(const char*)cur;
    return theChar;
}

-(NSString*)scanUTF8Name
{
    int theChar=0;
    NSMutableString *result=[NSMutableString string];
    do {
        theChar = [self scanUTF8Char];
        if ( theChar  ) {
            [result appendFormat:@"%C",(unsigned short)theChar];
        }
    } while ( NO);
    return [[[MPWStName alloc] initWithString:result] autorelease];
}


-scanASCIIName
{
    const  char *cur=pos;

    if ( isalpha(*cur) || *cur=='_' ) {
        cur++;
        while ( SCANINBOUNDS(cur) && (isalnum(*cur) || (*cur=='_') || (*cur=='-') ||
						(*cur=='.' && SCANINBOUNDS(cur+1) && isalnum(cur[1])))) {
            cur++;
        }
        if ( SCANINBOUNDS(cur) && *cur ==':' ) {
            cur++;
			if ( SCANINBOUNDS( cur ) && (*cur=='=' || *cur==':' ) ) {
				cur--;
			}
        }
    }
//    [[[MPWStName alloc] initWithString:result] autorelease]
    
    return [self makeText:cur-pos];
}

-scanPossibleAssignment
{
    const char *cur=pos;
	cur++;
	if ( SCANINBOUNDS( cur ) &&  (*cur==':') ) {
		cur++;
	}
	if ( SCANINBOUNDS( cur ) &&  (*cur=='=') ) {
		cur++;
	}
    return [self makeText:cur-pos];     
}

-scanPossibleEquals
{
    const char *cur=pos;
    int len=3;
    if ( SCANINBOUNDS(cur+2) && cur[1] == '|' && cur[2] == '=' ) {
        return [self makeText:len];
    } else {
        return [self scanSpecial];
    }
}

-scanSpecial
{
    const char *cur=pos;
    int len=1;
    if ( *cur=='<' && SCANINBOUNDS(cur+1) && cur[1]=='-' ) {
        len++;
    } else if ( *cur=='-' && SCANINBOUNDS(cur+1) && cur[1]=='>') {
        len++;
    } else if ( *cur=='|' && SCANINBOUNDS(cur+1) && cur[1]=='=') {
        len++;
    }
    return [self makeText:len];
}

-(NSStringEncoding)stringEncoding
{
    return NSUTF8StringEncoding;
}

-scanString
{
    NSMutableArray *partialStrings=nil;
    const  char *cur=pos;
    id string=nil;
    if ( *cur =='\'' ) {
        cur++;
        pos=cur;
        while ( SCANINBOUNDS(cur) ) {
            if ( *cur=='\''  ) {
                string=[self makeString:cur-pos];
                UPDATEPOSITION(pos+1);
                if ( SCANINBOUNDS(cur+1) && cur[1] == '\'' ) {
                    if ( partialStrings == nil ) {
                        partialStrings = [NSMutableArray array];
                    }
                    [partialStrings addObject:string];
                    cur+=2;
                } else {
                    if ( partialStrings ) {
                        [partialStrings addObject:string];
                    }
                    break;
                }
            } else {
                cur++;
            }
        }
    }
    if ( partialStrings ) {
        return [partialStrings componentsJoinedByString:@""];
    } else {
        return string;
    }
}

-createDouble:(double)aFloat
{
	return [[self floatClass] numberWithDouble:aFloat];
}

-createInt:(long)anInt
{
	return [[self intClass] numberWithLong:anInt];
}

-createString:(NSString*)aString
{
	return [[self stringClass] stringWithString:aString];
}


-scanNumber
{
    const char *cur=pos;
    id string;
//	int numPeriods=0;
    while ( SCANINBOUNDS(cur) && isdigit(*cur)) {
        cur++;
    }
	if (*cur=='.' && SCANINBOUNDS(cur+1) && isdigit(cur[1])) {
		cur++;
		while ( SCANINBOUNDS(cur) && isdigit(*cur) ) {
			cur++;
		}
	}
    string=[self makeText:cur-pos];
	if ( !noNumbers ) {
		if ( [string rangeOfString:@"."].length==1 ) {
			return [self createDouble:[string doubleValue]];
		} else {
			return [self createInt:[string longValue]];
		}
	} else {
		return string;
	}
}

-(BOOL)atSpace
{
	return SCANINBOUNDS(pos) && isspace(*pos);
}

-skipSpace
{
    const char *cur=pos;
    while ( SCANINBOUNDS(cur) && isspace(*cur) ) {
//        NSLog(@"skipSpace: %c %@",*cur,self);
        cur++;
    }
    UPDATEPOSITION(cur);
    return nil;
}

-nextObject
{
    id n;
    [self skipSpace];
    n = [super nextObject];
    return n;
}

-nextToken
{
    id result;
    if ( [tokens count] ) {
        result=[tokens lastObject];
        [tokens removeLastObject];
    } else {
        result=[self nextObject];
    }
    return result;
}

-(void)pushBack:aToken
{
    if ( aToken ) {
        [tokens addObject:aToken];
    }
}
@end

@implementation MPWStScanner(testing)

+scannerWithString:(NSString*)s
{
    return [self scannerWithData:(NSData*)s];
}

+(void)testDoubleStringEscape
{
    MPWStScanner *scanner = [self scannerWithString:@"'ab''c'"];
    id string = [scanner nextToken];
    IDEXPECT( string, @"ab'c", @"should have turned double single quotes into single single quote" );
}

+(void)testConstraintEqual
{
    MPWStScanner *scanner = [self scannerWithString:@"a::=b"];
    id a = [scanner nextToken];
    id eq = [scanner nextToken];
    id b = [scanner nextToken];
    IDEXPECT( a, @"a", @"just the a" );
    IDEXPECT( eq, @"::=", @"constraint equal" );
    IDEXPECT( b, @"b", @"just the b" );
}

+(void)testURLWithUnderscores
{
	MPWStScanner *scanner=[self scannerWithString:@"http://farm1.static.flickr.com/9/86383513_f52e2fbf92.jpg"];
	NSMutableArray *tokens=[NSMutableArray array];
	id nextToken;
	while ( nil != (nextToken=[scanner nextToken] )) {
		[tokens addObject:nextToken];
	}
	INTEXPECT( [tokens count], 9 , @"number of tokens");
}

+(void)testLeftArrow
{
	MPWStScanner *scanner=[self scannerWithString:@"<-"];
    IDEXPECT([scanner nextToken], @"<-", @"single left arrow");
    
}

+(void)testSimpleLiteralString
{
	MPWStScanner *scanner=[self scannerWithString:@"'literal string'"];
    IDEXPECT([scanner nextToken], @"literal string", @"literal string");
}

+(void)singleMinusString
{
	MPWStScanner *scanner=[self scannerWithString:@"'-'"];
    IDEXPECT([scanner nextToken], @"-", @"single minus sign");
    
}

+(void)testRightArrow
{
	MPWStScanner *scanner=[self scannerWithString:@"->"];
    IDEXPECT([scanner nextToken],@"->", @"single right arrow");
}

+(void)testScanUTF8Name
{
    unichar pival=960;
    NSString *pi_string=[NSString stringWithCharacters:&pival length:1];
	MPWStScanner *scanner=[self scannerWithString:pi_string];
    NSString *token=[scanner nextToken];
    INTEXPECT([token length], 1, @"length of scanned token pi");
    
    INTEXPECT([token characterAtIndex:0], pival, @"pi");
    IDEXPECT(token, pi_string, @"the string");
}

+(NSArray*)testSelectors
{
    return [NSArray arrayWithObjects:
        @"testDoubleStringEscape",
        @"testConstraintEqual",
            @"testURLWithUnderscores",
            @"testLeftArrow",
            @"testRightArrow",
            @"testSimpleLiteralString",
            @"singleMinusString",
            @"testScanUTF8Name",
        nil];
}

@end
