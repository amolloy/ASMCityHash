//
//  NSData+ASMCityHash.m
//  ObjCityHash
//
//  Created by Andrew Molloy on 5/16/14.
//  Copyright (c) 2014 Andrew Molloy. All rights reserved.
//

#import "NSData+ASMCityHash.h"

@implementation NSData (ASMCityHash)

#if !defined(LIKELY)
#if HAVE_BUILTIN_EXPECT
#define LIKELY(x) (__builtin_expect(!!(x), 1))
#else
#define LIKELY(x) (x)
#endif
#endif

// Some primes between 2^63 and 2^64 for various uses.
static const UInt64 k0 = 0xc3a5c85c97cb3127ULL;
static const UInt64 k1 = 0xb492b66fbe98f273ULL;
static const UInt64 k2 = 0x9ae16a3b2f90404fULL;

static UInt64 UNALIGNED_LOAD64(const char *p)
{
	UInt64 result;
	memcpy(&result, p, sizeof(result));
	return result;
}

static UInt32 UNALIGNED_LOAD32(const char *p)
{
	UInt32 result;
	memcpy(&result, p, sizeof(result));
	return result;
}

static UInt64 Fetch64(const char *p)
{
	return UNALIGNED_LOAD64(p);
}

static UInt32 Fetch32(const char *p)
{
	return UNALIGNED_LOAD32(p);
}

static UInt32 Rotate32(UInt32 val, int shift)
{
	// Avoid shifting by 32: doing so yields an undefined result.
	return shift == 0 ? val : ((val >> shift) | (val << (32 - shift)));
}

// Bitwise right rotate.  Normally this will compile to a single
// instruction, especially if the shift is a manifest constant.
static UInt64 Rotate(UInt64 val, int shift)
{
	// Avoid shifting by 64: doing so yields an undefined result.
	return shift == 0 ? val : ((val >> shift) | (val << (64 - shift)));
}

-(UInt64)shiftMix:(UInt64)val
{
	return val ^ (val >> 47);
}

// Hash 128 input bits down to 64 bits of output.
// This is intended to be a reasonably good hash function.
-(UInt64)hash128To64:(ASMUInt128)x
{
	// Murmur-inspired hashing.
	const UInt64 kMul = 0x9ddfea08eb382d69ULL;
	UInt64 a = (ASMUInt128Low64(x) ^ ASMUInt128High64(x)) * kMul;
	a ^= (a >> 47);
	UInt64 b = (ASMUInt128High64(x) ^ a) * kMul;
	b ^= (b >> 47);
	b *= kMul;
	return b;
}

-(UInt64)hashLen16U:(UInt64)u v:(UInt64)v
{
	ASMUInt128 uv = { u, v };
	return [self hash128To64:uv];
}

-(UInt64)hashLen16U:(UInt64)u v:(UInt64)v mul:(UInt64)mul
{
	// Murmur-inspired hashing.
	UInt64 a = (u ^ v) * mul;
	a ^= (a >> 47);
	UInt64 b = (v ^ a) * mul;
	b ^= (b >> 47);
	b *= mul;
	return b;
}

-(UInt64)hashLen0to16Bytes:(const char*)s length:(NSUInteger)len
{
	if (len >= 8)
	{
		UInt64 mul = k2 + len * 2;
		UInt64 a = Fetch64(s) + k2;
		UInt64 b = Fetch64(s + len - 8);
		UInt64 c = Rotate(b, 37) * mul + a;
		UInt64 d = (Rotate(a, 25) + b) * mul;
		return [self hashLen16U:c v:d mul:mul];
	}
	if (len >= 4) {
		UInt64 mul = k2 + len * 2;
		UInt64 a = Fetch32(s);
		return [self hashLen16U:len + (a << 3) v:Fetch32(s + len - 4) mul:mul];
	}
	if (len > 0) {
		UInt8 a = s[0];
		UInt8 b = s[len >> 1];
		UInt8 c = s[len - 1];
		UInt32 y = ((UInt32)a) + (((UInt32)b) << 8);
		UInt32 z = len + (((UInt32)c) << 2);
		return [self shiftMix:y * k2 ^ z * k0] * k2;
	}
	return k2;
}

// This probably works well for 16-byte strings as well, but it may be overkill
// in that case.
-(UInt64)hashLen17to32Bytes:(const char*)s length:(NSUInteger)len
{
	UInt64 mul = k2 + len * 2;
	UInt64 a = Fetch64(s) * k1;
	UInt64 b = Fetch64(s + 8);
	UInt64 c = Fetch64(s + len - 8) * mul;
	UInt64 d = Fetch64(s + len - 16) * k2;
	return [self hashLen16U:Rotate(a + b, 43) + Rotate(c, 30) + d
						  v:a + Rotate(b + k2, 18) + c
						mul:mul];
}

// Return a 16-byte hash for 48 bytes.  Quick and dirty.
// Callers do best to use "random-looking" values for a and b.
-(ASMUInt128)weakHashLen32WithSeedsW:(UInt64)w x:(UInt64)x y:(UInt64)y z:(UInt64)z a:(UInt64)a b:(UInt64)b
{
	a += w;
	b = Rotate(b + a + z, 21);
	UInt64 c = a;
	a += x;
	a += y;
	b += Rotate(a, 44);
	ASMUInt128 result = {a + z, b + c};
	return result;
}

// Return a 16-byte hash for s[0] ... s[31], a, and b.  Quick and dirty.
-(ASMUInt128)weakHashLen32WithBytes:(const char*)s seedA:(UInt64)a b:(UInt64)b
{
	return [self weakHashLen32WithSeedsW:Fetch64(s)
									   x:Fetch64(s + 8)
									   y:Fetch64(s + 16)
									   z:Fetch64(s + 24)
									   a:a
									   b:b];
}


// Return an 8-byte hash for 33 to 64 bytes.
-(UInt64)hashLen33to64Bytes:(const char*)s length:(NSUInteger)len
{
	UInt64 mul = k2 + len * 2;
	UInt64 a = Fetch64(s) * k2;
	UInt64 b = Fetch64(s + 8);
	UInt64 c = Fetch64(s + len - 24);
	UInt64 d = Fetch64(s + len - 32);
	UInt64 e = Fetch64(s + 16) * k2;
	UInt64 f = Fetch64(s + 24) * 9;
	UInt64 g = Fetch64(s + len - 8);
	UInt64 h = Fetch64(s + len - 16) * mul;
	UInt64 u = Rotate(a + g, 43) + (Rotate(b, 30) + c) * 9;
	UInt64 v = ((a + g) ^ d) + f + 1;
	UInt64 w = OSSwapInt64((u + v) * mul) + h;
	UInt64 x = Rotate(e + f, 42) + c;
	UInt64 y = (OSSwapInt64((v + w) * mul) + g) * mul;
	UInt64 z = e + f + c;
	a = OSSwapInt64((x + z) * mul + y) + b;
	b = [self shiftMix:(z + a) * mul + d + h] * mul;
	return b + x;
}

-(UInt32)cityHash32
{
	return 0;
}

-(UInt64)cityHash64
{
	const char* s = [self bytes];
	NSUInteger len = self.length;

	if (len <= 32)
	{
		if (len <= 16)
		{
			return [self hashLen0to16Bytes:s length:len];
		}
		else
		{
			return [self hashLen17to32Bytes:s length:len];
		}
	}
	else if (len <= 64)
	{
		return [self hashLen33to64Bytes:s length:len];
	}

	// For data over 64 bytes we hash the end first, and then as we
	// loop we keep 56 bytes of state: v, w, x, y, and z.
	UInt64 x = Fetch64(s + len - 40);
	UInt64 y = Fetch64(s + len - 16) + Fetch64(s + len - 56);
	UInt64 z = [self hashLen16U:Fetch64(s + len - 48) + len
							  v:Fetch64(s + len - 24)];
	ASMUInt128 v = [self weakHashLen32WithBytes:s + len - 64
										  seedA:len
											  b:z];
	ASMUInt128 w = [self weakHashLen32WithBytes:s + len - 32
										  seedA:y + k1
											  b:x];
	x = x * k1 + Fetch64(s);

	// Decrease len to the nearest multiple of 64, and operate on 64-byte chunks.
	len = (len - 1) & ~(NSUInteger)63;
	do
	{
		x = Rotate(x + y + v.first + Fetch64(s + 8), 37) * k1;
		y = Rotate(y + v.second + Fetch64(s + 48), 42) * k1;
		x ^= w.second;
		y += v.first + Fetch64(s + 40);
		z = Rotate(z + w.first, 33) * k1;
		v = [self weakHashLen32WithBytes:s
								   seedA:v.second * k1
									   b:x + w.first];
		w = [self weakHashLen32WithBytes:s + 32
								   seedA:z + w.second
									   b:y + Fetch64(s + 16)];
		UInt64 tmp = z;
		z = x;
		x = tmp;
		s += 64;
		len -= 64;
	} while (len != 0);

	return [self hashLen16U:[self hashLen16U:v.first v:w.first] + [self shiftMix:y] * k1 + z
						  v:[self hashLen16U:v.second v:w.second] + x];
}

-(UInt64)cityHash64WithSeed:(UInt64)seed
{
	return [self cityHash64WithSeed:k2 andSeed:seed];
}

-(UInt64)cityHash64WithSeed:(UInt64)seed0 andSeed:(UInt64)seed1
{
	return [self hashLen16U:[self cityHash64] - seed0
						  v:seed1];
}

// A subroutine for CityHash128().  Returns a decent 128-bit hash for strings
// of any length representable in signed long.  Based on City and Murmur.
-(ASMUInt128)cityMurmurWithBytes:(const char*)s length:(NSUInteger)len seed:(ASMUInt128)seed
{
	UInt64 a = ASMUInt128Low64(seed);
	UInt64 b = ASMUInt128High64(seed);
	UInt64 c = 0;
	UInt64 d = 0;
	signed long l = len - 16;
	if (l <= 0) // len <= 16
	{
		a = [self shiftMix:a * k1] * k1;
		c = b * k1 + [self hashLen0to16Bytes:s length:len];
		d = [self shiftMix:a + (len >= 8 ? Fetch64(s) : c)];
	}
	else  // len > 16
	{
		c = [self hashLen16U:Fetch64(s + len - 8) + k1
						   v:a];
		d = [self hashLen16U:b + len
						   v:c + Fetch64(s + len - 16)];
		a += d;
		do
		{
			a ^= [self shiftMix:Fetch64(s) * k1] * k1;
			a *= k1;
			b ^= a;
			c ^= [self shiftMix:Fetch64(s + 8) * k1] * k1;
			c *= k1;
			d ^= c;
			s += 16;
			l -= 16;
		} while (l > 0);
	}
	a = [self hashLen16U:a v:c];
	b = [self hashLen16U:d v:b];

	ASMUInt128 result = { a ^ b, [self hashLen16U:b v:a] };
	return result;
}

-(ASMUInt128)cityHash128WithBytes:(const char*)s length:(NSUInteger)len seed:(ASMUInt128)seed
{
	if (len < 128)
	{
		return [self cityMurmurWithBytes:s
								  length:len
									seed:seed];
	}

	// We expect len >= 128 to be the common case.  Keep 56 bytes of state:
	// v, w, x, y, and z.
	ASMUInt128 v;
	ASMUInt128 w;
	UInt64 x = ASMUInt128Low64(seed);
	UInt64 y = ASMUInt128High64(seed);
	UInt64 z = len * k1;
	v.first = Rotate(y ^ k1, 49) * k1 + Fetch64(s);
	v.second = Rotate(v.first, 42) * k1 + Fetch64(s + 8);
	w.first = Rotate(y + z, 35) * k1 + x;
	w.second = Rotate(x + Fetch64(s + 88), 53) * k1;

	// This is the same inner loop as CityHash64(), manually unrolled.
	do
	{
		x = Rotate(x + y + v.first + Fetch64(s + 8), 37) * k1;
		y = Rotate(y + v.second + Fetch64(s + 48), 42) * k1;
		x ^= w.second;
		y += v.first + Fetch64(s + 40);
		z = Rotate(z + w.first, 33) * k1;
		v = [self weakHashLen32WithBytes:s
								   seedA:v.second * k1
									   b:x + w.first];
		w = [self weakHashLen32WithBytes:s + 32
								   seedA:z + w.second
									   b:y + Fetch64(s + 16)];
		UInt64 tmp = z;
		z = x;
		x = tmp;

		s += 64;
		x = Rotate(x + y + v.first + Fetch64(s + 8), 37) * k1;
		y = Rotate(y + v.second + Fetch64(s + 48), 42) * k1;
		x ^= w.second;
		y += v.first + Fetch64(s + 40);
		z = Rotate(z + w.first, 33) * k1;
		v = [self weakHashLen32WithBytes:s
								   seedA:v.second * k1
									   b:x + w.first];
		w = [self weakHashLen32WithBytes:s + 32
								   seedA:z + w.second
									   b:y + Fetch64(s + 16)];
		tmp = z;
		z = x;
		x = tmp;

		s += 64;
		len -= 128;
	} while (LIKELY(len >= 128));
	x += Rotate(v.first + z, 49) * k0;
	y = y * k0 + Rotate(w.second, 37);
	z = z * k0 + Rotate(w.first, 27);
	w.first *= 9;
	v.first *= k0;
	// If 0 < len < 128, hash up to 4 chunks of 32 bytes each from the end of s.
	for (size_t tail_done = 0; tail_done < len; ) {
		tail_done += 32;
		y = Rotate(x + y, 42) * k0 + v.second;
		w.first += Fetch64(s + len - tail_done + 16);
		x = x * k0 + w.first;
		z += w.second + Fetch64(s + len - tail_done);
		w.second += v.first;
		v = [self weakHashLen32WithBytes:s + len - tail_done
								   seedA:v.first + z
									   b:v.second];
		v.first *= k0;
	}
	// At this point our 56 bytes of state should contain more than
	// enough information for a strong 128-bit hash.  We use two
	// different 56-byte-to-8-byte hashes to get a 16-byte final result.
	x = [self hashLen16U:x v:v.first];
	y = [self hashLen16U:y + z v:w.first];

	ASMUInt128 result = { [self hashLen16U:x + v.second v:w.second] + y,
						  [self hashLen16U:x + w.second v:y + v.second] };

	return result;
}

-(ASMUInt128)cityHash128WithSeed:(ASMUInt128)seed
{
	const char* s = [self bytes];
	NSUInteger len = self.length;

	return [self cityHash128WithBytes:s
							   length:len
								 seed:seed];
}

-(ASMUInt128)cityHash128
{
	NSUInteger len = self.length;

	if (len >= 16)
	{
		const char* s = [self bytes];
		ASMUInt128 seed = { Fetch64(s), Fetch64(s + 8) + k0 };
		return [self cityHash128WithBytes:s + 16
								   length:len - 16
									 seed:seed];
	}

	ASMUInt128 seed = { k0, k1 };
	return [self cityHash128WithSeed:seed];
}

@end
