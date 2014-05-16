//
//  NSString+ASMCityHash.m
//  ASMCityHash
//
//  Created by Andrew Molloy on 5/16/14.
//  Copyright (c) 2014 Andrew Molloy. All rights reserved.
//

#import "NSString+ASMCityHash.h"
#import "NSData+ASMCityHash.h"

@implementation NSString (ASMCityHash)

-(UInt32)cityHash32
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] cityHash32];
}

-(UInt64)cityHash64
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] cityHash64];
}

-(UInt64)cityHash64WithSeed:(UInt64)seed
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] cityHash64WithSeed:seed];
}

-(UInt64)cityHash64WithSeed:(UInt64)seed0 andSeed:(UInt64)seed1
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] cityHash64WithSeed:seed0 andSeed:seed1];
}

-(ASMUInt128)cityHash128
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] cityHash128];
}

-(ASMUInt128)cityHash128WithSeed:(ASMUInt128)seed
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] cityHash128WithSeed:seed];
}

@end
