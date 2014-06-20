//
//  GogobotSignature.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/19/13.
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

#import "GogobotSignature.h"
//#import "NSString+QueryString.h"
#import "NSDictionary+QueryString.h"
#import "NSData+Base64.h"

#include <CommonCrypto/CommonHMAC.h>

//TODO Generate my own client_id at Gogobot
#define GOGOBOT_OAUTH_CLIENT_ID @"0b4a01e2dd2cd6bf74f52a0e34db5626e32552ff6b86690e51fd3e73f9c6ac56"
#define GOGOBOT_OAUTH_CLIENT_SECRET @"a7894673ccf9f2f0d2db879dd5cd4b6a72bb0b18aec67b32be756faa544c65f7"

@implementation GogobotSignature

+ (NSURLRequest *)requestWithSignature:(NSURLRequest *)request {
  
  NSString *signature = [self generateSignature:request];
  
  NSMutableURLRequest *requestWithSignature = [request mutableCopy];
  
  [requestWithSignature addValue:GOGOBOT_OAUTH_CLIENT_ID forHTTPHeaderField:@"Gogobot-ClientID"];
  [requestWithSignature addValue:[signature stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forHTTPHeaderField:@"Gogobot-Signature"];

  return requestWithSignature;
}

+ (NSString *)generateSignature:(NSURLRequest *)request {
  NSMutableDictionary *params;
  
  NSURL *url = [request URL];
  
  params = [url query] ? [[NSDictionary dictionaryWithQueryString:[url query]] mutableCopy] : [NSMutableDictionary dictionary];
  [params setValue:GOGOBOT_OAUTH_CLIENT_ID forKey:@"client_id"];
  
  NSMutableString* signature = [NSMutableString stringWithCapacity:512];
  NSArray* keys = [params.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (id key in [keys objectEnumerator]) {
    id value = [params valueForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
      [signature appendFormat:@"%@%@", key, value];
    }
  }
  [signature appendString:GOGOBOT_OAUTH_CLIENT_SECRET];
  
  const char *cKey  = [GOGOBOT_OAUTH_CLIENT_SECRET cStringUsingEncoding:NSUTF8StringEncoding];
  const char *cData = [signature cStringUsingEncoding:NSUTF8StringEncoding];
  
  unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
  
  CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
  NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
  
  return [HMAC base64EncodedString];
}

@end
