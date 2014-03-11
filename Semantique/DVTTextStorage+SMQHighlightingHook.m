//
//  DVTTextStorage+SMQHighlightingHook.m
//  Semantique
//
//  Created by Kolin Krewinkel on 3/10/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "DVTTextStorage+SMQHighlightingHook.h"
#import "SMQSwizzling.h"

static NSUInteger idx = 0;
static IMP originalColoring;

@implementation DVTTextStorage (SMQHighlightingHook)

+ (void)initialize
{
    originalColoring = SMQPoseSwizzle([DVTTextStorage class], NSSelectorFromString(@"colorAtCharacterIndex:effectiveRange:context:"), self, @selector(smq_colorAtCharacterIndex:effectiveRange:context:));
//    SMQPoseSwizzle([DVTTextStorage class], NSSelectorFromString(@"fixSyntaxColoringInRange:"), self, @selector(smq_fixSyntaxColoringInRange:));
}

- (void)smq_fixSyntaxColoringInRange:(NSRange)range
{
//    [self setAttributes:@{NSForegroundColorAttributeName: [NSColor redColor]} range:range];
}

- (void)smq_handleItem:(DVTSourceModelItem *)item
{
    NSLog(@"%@", [self.string substringWithRange:item.range]);

    if (item.children.count > 0)
    {
        for (DVTSourceModelItem *child in item.children)
        {
            [self smq_handleItem:child];
        }
    }
}

- (NSColor *)smq_colorAtCharacterIndex:(unsigned long long)index effectiveRange:(NSRangePointer)effectiveRange context:(id)context
{
    NSRange range = *effectiveRange;
    NSLog(@"Was: %@", NSStringFromRange(range));
//
//    DVTSourceModel *sourceModel = self.sourceModel;
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self smq_handleItem:sourceModel.sourceItems];
//    });

    /* Basically, Xcode calls you a given range. It seems to start with the entirety and spiral its way inward. Once given a range, its broken down by the colorAt: method. It replaces the range pointer passed, which Xcode then applies changes, and adapts the numerical changes.  So, the next thing it asks about is whatever is just beyond whatever the replaced range is. It also takes the previous length (assuming it can fit in the total text range, at which point it defaults to the max value before subtracting), and subtracts the new range length from it to determine the next passed length.     */

    NSColor *color = (NSColor *)originalColoring(self, @selector(colorAtCharacterIndex:effectiveRange:context:), index, effectiveRange, context);

    NSRange newRange = *effectiveRange;
//    effectiveRange->length++;

    NSLog(@"Changed to: %@", NSStringFromRange(newRange));


//    *effectiveRange = NSMakeRange(range.location, 1);
//
//    color = idx % 2 ? [NSColor greenColor] : [NSColor redColor];

    if ([self.sourceModel isInStringConstantAtLocation:index])
    {
        color = [NSColor purpleColor];
    }
//
    idx++;

    return color;
}

//- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
//{
//    
//}

@end