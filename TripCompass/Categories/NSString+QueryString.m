//
//  NSString+QueryString.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/17/13.
//  Copyright (c) 2014 Eduardo Sasso
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "NSString+QueryString.h"

@implementation NSString (QueryString)

- (NSString*)stringByUnescapingFromURLArgument {
	NSMutableString *resultString = [NSMutableString stringWithString:self];
	[resultString replaceOccurrencesOfString:@"+"
                                withString:@" "
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, [resultString length])];
	return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)httpParams {
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
	NSArray* components = [self componentsSeparatedByString:@"&"];
	// Use reverse order so that the first occurrence of a key replaces
	// those subsequent.
	for (NSString* component in [components reverseObjectEnumerator]) {
		if ([component length] == 0)
			continue;
		NSRange pos = [component rangeOfString:@"="];
		NSString *key;
		NSString *val;
		if (pos.location == NSNotFound) {
			key = [component stringByUnescapingFromURLArgument];
			val = @"";
		} else {
			key = [[component substringToIndex:pos.location]
             stringByUnescapingFromURLArgument];
			val = [[component substringFromIndex:pos.location + pos.length]
             stringByUnescapingFromURLArgument];
		}
		// stringByUnescapingFromURLArgument returns nil on invalid UTF8
		// and NSMutableDictionary raises an exception when passed nil values.
		if (!key) key = @"";
		if (!val) val = @"";
		[ret setObject:val forKey:key];
	}
	return ret;
}

@end
