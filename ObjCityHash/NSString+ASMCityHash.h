//
//  NSString+ASMCityHash.h
//  ObjCityHash
//
//  Created by Andrew Molloy on 5/16/14.
//  Copyright (c) 2014 Andrew Molloy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASMUInt128.h"

@interface NSString (ASMCityHash)

/**
 *	Compute CityHash64 for this string.
 *
 *	@return CityHash64 for this string.
 */
-(UInt64)cityHash64;

/**
 *	Compute CityHash64 for this string with a 64-bit seed hashed into the result.
 *
 *	@param seed Seed to hash into the result.
 *
 *	@return CityHash64 for this string with seed hashed into the result.
 */
-(UInt64)cityHash64WithSeed:(UInt64)seed;

/**
 *	Compute CityHash64 for this string with two 64-bit seeds hashed into the result.
 *
 *	@param seed0 Seed to hash into the result.
 *	@param seed1 Seed to hash into the result.
 *
 *	@return CityHash64 for this string with two seeds hashed into the result.
 */
-(UInt64)cityHash64WithSeed:(UInt64)seed0 andSeed:(UInt64)seed1;

/**
 *	Compute CityHash128 for this string.
 *
 *	@return CityHash128 for this string.
 */
-(ASMUInt128)cityHash128;

/**
 *	Compute CityHash128 for this string with a 128-bit seed hashed into the result.
 *
 *	@param seed Seed to hash into the result.
 *
 *	@return CityHash128 for this string with seed hashed into the result.
 */
-(ASMUInt128)cityHash128WithSeed:(ASMUInt128)seed;

@end
