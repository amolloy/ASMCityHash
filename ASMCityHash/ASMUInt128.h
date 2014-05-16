//
//  ASMUInt128.h
//  ASMCityHash
//
//  Created by Andrew Molloy on 5/16/14.
//  Copyright (c) 2014 Andrew Molloy. All rights reserved.
//

#ifndef ASMCityHash_ASMUInt128_h
#define ASMCityHash_ASMUInt128_h

typedef struct
{
	UInt64 first;
	UInt64 second;
} ASMUInt128;

#define ASMUInt128Low64(x) (x.first)
#define ASMUInt128High64(x) (x.second)

#endif
