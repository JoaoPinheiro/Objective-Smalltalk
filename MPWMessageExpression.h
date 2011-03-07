/* MPWMessageExpression.h created by marcel on Tue 04-Jul-2000 */

#import <MPWTalk/MPWConnector.h>

@interface MPWMessageExpression : MPWConnector
{
    MPWExpression*	receiver;
    SEL	selector;
    id	args;
}

idAccessor_h( receiver, setReceiver )
scalarAccessor_h( SEL, selector, setSelector )
idAccessor_h( args, setArgs )
-initWithReceiver:newReceiver;


@end
