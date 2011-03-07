//
//  MPWStatementList.h
//  MPWTalk
//
//  Created by Marcel Weiher on 11/22/04.
//  Copyright 2004 Marcel Weiher. All rights reserved.
//

#import <MPWTalk/MPWExpression.h>


@interface MPWStatementList : MPWExpression {
	id statements;
}

idAccessor_h( statements, setStatements )

-(void)addStatement:aStatement;
+statementList;

@end
