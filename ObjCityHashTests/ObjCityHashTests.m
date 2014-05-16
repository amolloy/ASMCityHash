//
//  ObjCityHashTests.m
//  ObjCityHashTests
//
//  Created by Andrew Molloy on 5/16/14.
//  Copyright (c) 2014 Andrew Molloy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+ASMCityHash.h"
#import "NSString+ASMCityHash.h"

static const UInt64 k0 = 0xc3a5c85c97cb3127ULL;
static const UInt64 kSeed0 = 1234567;
static const UInt64 kSeed1 = k0;
static const ASMUInt128 kSeed128 = {kSeed0, kSeed1};
static const int kDataSize = 1 << 20;
static const int kTestSize = 300;
static const UInt64 testdata[kTestSize][16];
static NSString* testString;
static const int kStringTestSize = 48;
static const UInt64 stringTestdata[kStringTestSize][16];

@interface ObjCityHashTests : XCTestCase
@property (nonatomic, strong) NSData* data;
@end

@implementation ObjCityHashTests

- (void)setUp
{
    [super setUp];

	char tmpData[kDataSize];

	UInt64 a = 9;
	UInt64 b = 777;
	for (int i = 0; i < kDataSize; i++)
	{
		a += b;
		b += a;
		a = (a ^ (a >> 41)) * k0;
		b = (b ^ (b >> 41)) * k0 + i;
		UInt8 u = b >> 37;
		memcpy(tmpData + i, &u, 1);  // uint8 -> char
	}

	self.data = [NSData dataWithBytes:tmpData length:kDataSize];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testExpected:(const UInt64*)expected offset:(int)offset length:(int)len
{
	NSData* subdata = [self.data subdataWithRange:NSMakeRange(offset, len)];
	const ASMUInt128 u = [subdata cityHash128];
	const ASMUInt128 v = [subdata cityHash128WithSeed:kSeed128];

	XCTAssertEqual(expected[0], [subdata cityHash64], @"cityHash64 should return expected value");
	XCTAssertEqual(expected[1], [subdata cityHash64WithSeed:kSeed0], @"cityHash64WithSeed: should return expected value");
	XCTAssertEqual(expected[2], [subdata cityHash64WithSeed:kSeed0 andSeed:kSeed1], @"cityHash64WithSeed:andSeed: should return expected value");
	XCTAssertEqual(expected[3], ASMUInt128Low64(u), @"cityHash128 lower 64-bits should return expected value");
	XCTAssertEqual(expected[4], ASMUInt128High64(u), @"cityHash128 higher 64-bits should return expected value");
	XCTAssertEqual(expected[5], ASMUInt128Low64(v), @"cityHash128WithSeed: lower 64-bits should return expected value");
	XCTAssertEqual(expected[6], ASMUInt128High64(v), @"cityHash128WithSeed: higher 64-bits should return expected value");
	XCTAssertEqual(expected[7], [subdata cityHash32], @"cityHash32 should return expected value");
}

- (void)testDataHash
{
	int i = 0;
	for (; i < kTestSize - 1; i++)
	{
		[self testExpected:testdata[i] offset:i * i length:i];
	}

	[self testExpected:testdata[i] offset:0 length:kDataSize];
}

-(void)stringTestExpected:(const UInt64*)expected offset:(int)offset length:(NSUInteger)len
{
	NSString* subString = [testString substringWithRange:NSMakeRange(offset, len)];
	const ASMUInt128 u = [subString cityHash128];
	const ASMUInt128 v = [subString cityHash128WithSeed:kSeed128];

	XCTAssertEqual(expected[0], [subString cityHash64], @"cityHash64 should return expected value");
	XCTAssertEqual(expected[1], [subString cityHash64WithSeed:kSeed0], @"cityHash64WithSeed: should return expected value");
	XCTAssertEqual(expected[2], [subString cityHash64WithSeed:kSeed0 andSeed:kSeed1], @"cityHash64WithSeed:andSeed: should return expected value");
	XCTAssertEqual(expected[3], ASMUInt128Low64(u), @"cityHash128 lower 64-bits should return expected value");
	XCTAssertEqual(expected[4], ASMUInt128High64(u), @"cityHash128 higher 64-bits should return expected value");
	XCTAssertEqual(expected[5], ASMUInt128Low64(v), @"cityHash128WithSeed: lower 64-bits should return expected value");
	XCTAssertEqual(expected[6], ASMUInt128High64(v), @"cityHash128WithSeed: higher 64-bits should return expected value");
	XCTAssertEqual(expected[7], [subString cityHash32], @"cityHash32 should return expected value");
}

- (void)testStringHash
{
	int i = 0;
	for (; i < kStringTestSize - 1; i++)
	{
		[self stringTestExpected:stringTestdata[i] offset:i * i length:i];
	}

	[self stringTestExpected:stringTestdata[i] offset:0 length:testString.length];
}

@end

#define C(x) 0x ## x ## ULL
static const UInt64 testdata[kTestSize][16] = {
	{C(9ae16a3b2f90404f), C(75106db890237a4a), C(3feac5f636039766), C(3df09dfc64c09a2b), C(3cb540c392e51e29), C(6b56343feac0663), C(5b7bc50fd8e8ad92), C(dc56d17a)},
	{C(541150e87f415e96), C(1aef0d24b3148a1a), C(bacc300e1e82345a), C(c3cdc41e1df33513), C(2c138ff2596d42f6), C(f58e9082aed3055f), C(162e192b2957163d), C(99929334)},
	{C(f3786a4b25827c1), C(34ee1a2bf767bd1c), C(2f15ca2ebfb631f2), C(3149ba1dac77270d), C(70e2e076e30703c), C(59bcc9659bc5296), C(9ecbc8132ae2f1d7), C(4252edb7)},
	{C(ef923a7a1af78eab), C(79163b1e1e9a9b18), C(df3b2aca6e1e4a30), C(2193fb7620cbf23b), C(8b6a8ff06cda8302), C(1a44469afd3e091f), C(8b0449376612506), C(ebc34f3c)},
	{C(11df592596f41d88), C(843ec0bce9042f9c), C(cce2ea1e08b1eb30), C(4d09e42f09cc3495), C(666236631b9f253b), C(d28b3763cd02b6a3), C(43b249e57c4d0c1b), C(26f2b463)},
	{C(831f448bdc5600b3), C(62a24be3120a6919), C(1b44098a41e010da), C(dc07df53b949c6b), C(d2b11b2081aeb002), C(d212b02c1b13f772), C(c0bed297b4be1912), C(b042c047)},
	{C(3eca803e70304894), C(d80de767e4a920a), C(a51cfbb292efd53d), C(d183dcda5f73edfa), C(3a93cbf40f30128c), C(1a92544d0b41dbda), C(aec2c4bee81975e1), C(e73bb0a8)},
	{C(1b5a063fb4c7f9f1), C(318dbc24af66dee9), C(10ef7b32d5c719af), C(b140a02ef5c97712), C(b7d00ef065b51b33), C(635121d532897d98), C(532daf21b312a6d6), C(91dfdd75)},
	{C(a0f10149a0e538d6), C(69d008c20f87419f), C(41b36376185b3e9e), C(26b6689960ccf81d), C(55f23b27bb9efd94), C(3a17f6166dd765db), C(c891a8a62931e782), C(c87f95de)},
	{C(fb8d9c70660b910b), C(a45b0cc3476bff1b), C(b28d1996144f0207), C(98ec31113e5e35d2), C(5e4aeb853f1b9aa7), C(bcf5c8fe4465b7c8), C(b1ea3a8243996f15), C(3f5538ef)},
	{C(236827beae282a46), C(e43970221139c946), C(4f3ac6faa837a3aa), C(71fec0f972248915), C(2170ec2061f24574), C(9eb346b6caa36e82), C(2908f0fdbca48e73), C(70eb1a1f)},
	{C(c385e435136ecf7c), C(d9d17368ff6c4a08), C(1b31eed4e5251a67), C(df01a322c43a6200), C(298b65a1714b5a7e), C(933b83f0aedf23c), C(157bcb44d63f765a), C(cfd63b83)},
	{C(e3f6828b6017086d), C(21b4d1900554b3b0), C(bef38be1809e24f1), C(d93251758985ee6c), C(32a9e9f82ba2a932), C(3822aacaa95f3329), C(db349b2f90a490d8), C(894a52ef)},
	{C(851fff285561dca0), C(4d1277d73cdf416f), C(28ccffa61010ebe2), C(77a4ccacd131d9ee), C(e1d08eeb2f0e29aa), C(70b9e3051383fa45), C(582d0120425caba), C(9cde6a54)},
	{C(61152a63595a96d9), C(d1a3a91ef3a7ba45), C(443b6bb4a493ad0c), C(a154296d11362d06), C(d0f0bf1f1cb02fc1), C(ccb87e09309f90d1), C(b24a8e4881911101), C(6c4898d5)},
	{C(44473e03be306c88), C(30097761f872472a), C(9fd1b669bfad82d7), C(3bab18b164396783), C(47e385ff9d4c06f), C(18062081bf558df), C(63416eb68f104a36), C(13e1978e)},
	{C(3ead5f21d344056), C(fb6420393cfb05c3), C(407932394cbbd303), C(ac059617f5906673), C(94d50d3dcd3069a7), C(2b26c3b92dea0f0), C(99b7374cc78fc3fb), C(51b4ba8)},
	{C(6abbfde37ee03b5b), C(83febf188d2cc113), C(cda7b62d94d5b8ee), C(a4375590b8ae7c82), C(168fd42f9ecae4ff), C(23bbde43de2cb214), C(a8c333112a243c8c), C(b6b06e40)},
	{C(943e7ed63b3c080), C(1ef207e9444ef7f8), C(ef4a9f9f8c6f9b4a), C(6b54fc38d6a84108), C(32f4212a47a4665), C(6b5a9a8f64ee1da6), C(9f74e86c6da69421), C(240a2f2)},
	{C(d72ce05171ef8a1a), C(c6bd6bd869203894), C(c760e6396455d23a), C(f86af0b40dcce7b), C(8d3c15d613394d3c), C(491e400491cd4ece), C(7c19d3530ea3547f), C(5dcefc30)},
	{C(4182832b52d63735), C(337097e123eea414), C(b5a72ca0456df910), C(7ebc034235bc122f), C(d9a7783d4edd8049), C(5f8b04a15ae42361), C(fc193363336453dd), C(7a48b105)},
	{C(d6cdae892584a2cb), C(58de0fa4eca17dcd), C(43df30b8f5f1cb00), C(9e4ea5a4941e097d), C(547e048d5a9daaba), C(eb6ecbb0b831d185), C(e0168df5fad0c670), C(fd55007b)},
	{C(5c8e90bc267c5ee4), C(e9ae044075d992d9), C(f234cbfd1f0a1e59), C(ce2744521944f14c), C(104f8032f99dc152), C(4e7f425bfac67ca7), C(9461b911a1c6d589), C(6b95894c)},
	{C(bbd7f30ac310a6f3), C(b23b570d2666685f), C(fb13fb08c9814fe7), C(4ee107042e512374), C(1e2c8c0d16097e13), C(210c7500995aa0e6), C(6c13190557106457), C(3360e827)},
	{C(36a097aa49519d97), C(8204380a73c4065), C(77c2004bdd9e276a), C(6ee1f817ce0b7aee), C(e9dcb3507f0596ca), C(6bc63c666b5100e2), C(e0b056f1821752af), C(45177e0b)},
	{C(dc78cb032c49217), C(112464083f83e03a), C(96ae53e28170c0f5), C(d367ff54952a958), C(cdad930657371147), C(aa24dc2a9573d5fe), C(eb136daa89da5110), C(7c6fffe4)},
	{C(441593e0da922dfe), C(936ef46061469b32), C(204a1921197ddd87), C(50d8a70e7a8d8f56), C(256d150ae75dab76), C(e81f4c4a1989036a), C(d0f8db365f9d7e00), C(bbc78da4)},
	{C(2ba3883d71cc2133), C(72f2bbb32bed1a3c), C(27e1bd96d4843251), C(a90f761e8db1543a), C(c339e23c09703cd8), C(f0c6624c4b098fd3), C(1bae2053e41fa4d9), C(c5c25d39)},
	{C(f2b6d2adf8423600), C(7514e2f016a48722), C(43045743a50396ba), C(23dacb811652ad4f), C(c982da480e0d4c7d), C(3a9c8ed5a399d0a9), C(951b8d084691d4e4), C(b6e5d06e)},
	{C(38fffe7f3680d63c), C(d513325255a7a6d1), C(31ed47790f6ca62f), C(c801faaa0a2e331f), C(491dbc58279c7f88), C(9c0178848321c97a), C(9d934f814f4d6a3c), C(6178504e)},
	{C(b7477bf0b9ce37c6), C(63b1c580a7fd02a4), C(f6433b9f10a5dac), C(68dd76db9d64eca7), C(36297682b64b67), C(42b192d71f414b7a), C(79692cef44fa0206), C(bd4c3637)},
	{C(55bdb0e71e3edebd), C(c7ab562bcf0568bc), C(43166332f9ee684f), C(b2e25964cd409117), C(a010599d6287c412), C(fa5d6461e768dda2), C(cb3ce74e8ec4f906), C(6e7ac474)},
	{C(782fa1b08b475e7), C(fb7138951c61b23b), C(9829105e234fb11e), C(9a8c431f500ef06e), C(d848581a580b6c12), C(fecfe11e13a2bdb4), C(6c4fa0273d7db08c), C(1fb4b518)},
	{C(c5dc19b876d37a80), C(15ffcff666cfd710), C(e8c30c72003103e2), C(7870765b470b2c5d), C(78a9103ff960d82), C(7bb50ffc9fac74b3), C(477e70ab2b347db2), C(31d13d6d)},
	{C(5e1141711d2d6706), C(b537f6dee8de6933), C(3af0a1fbbe027c54), C(ea349dbc16c2e441), C(38a7455b6a877547), C(5f97b9750e365411), C(e8cde7f93af49a3), C(26fa72e3)},
	{C(782edf6da001234f), C(f48cbd5c66c48f3), C(808754d1e64e2a32), C(5d9dde77353b1a6d), C(11f58c54581fa8b1), C(da90fa7c28c37478), C(5e9a2eafc670a88a), C(6a7433bf)},
	{C(d26285842ff04d44), C(8f38d71341eacca9), C(5ca436f4db7a883c), C(bf41e5376b9f0eec), C(2252d21eb7e1c0e9), C(f4b70a971855e732), C(40c7695aa3662afd), C(4e6df758)},
	{C(c6ab830865a6bae6), C(6aa8e8dd4b98815c), C(efe3846713c371e5), C(a1924cbf0b5f9222), C(7f4872369c2b4258), C(cd6da30530f3ea89), C(b7f8b9a704e6cea1), C(d57f63ea)},
	{C(44b3a1929232892), C(61dca0e914fc217), C(a607cc142096b964), C(f7dbc8433c89b274), C(2f5f70581c9b7d32), C(39bf5e5fec82dcca), C(8ade56388901a619), C(52ef73b3)},
	{C(4b603d7932a8de4f), C(fae64c464b8a8f45), C(8fafab75661d602a), C(8ffe870ef4adc087), C(65bea2be41f55b54), C(82f3503f636aef1), C(5f78a282378b6bb0), C(3cb36c3)},
	{C(4ec0b54cf1566aff), C(30d2c7269b206bf4), C(77c22e82295e1061), C(3df9b04434771542), C(feddce785ccb661f), C(a644aff716928297), C(dd46aee73824b4ed), C(72c39bea)},
	{C(ed8b7a4b34954ff7), C(56432de31f4ee757), C(85bd3abaa572b155), C(7d2c38a926dc1b88), C(5245b9eb4cd6791d), C(fb53ab03b9ad0855), C(3664026c8fc669d7), C(a65aa25c)},
	{C(5d28b43694176c26), C(714cc8bc12d060ae), C(3437726273a83fe6), C(864b1b28ec16ea86), C(6a78a5a4039ec2b9), C(8e959533e35a766), C(347b7c22b75ae65f), C(74740539)},
	{C(6a1ef3639e1d202e), C(919bc1bd145ad928), C(30f3f7e48c28a773), C(2e8c49d7c7aaa527), C(5e2328fc8701db7c), C(89ef1afca81f7de8), C(b1857db11985d296), C(c3ae3c26)},
	{C(159f4d9e0307b111), C(3e17914a5675a0c), C(af849bd425047b51), C(3b69edadf357432b), C(3a2e311c121e6bf2), C(380fad1e288d57e5), C(bf7c7e8ef0e3b83a), C(f29db8a2)},
	{C(cc0a840725a7e25b), C(57c69454396e193a), C(976eaf7eee0b4540), C(cd7a46850b95e901), C(c57f7d060dda246f), C(6b9406ead64079bf), C(11b28e20a573b7bd), C(1ef4cbf4)},
	{C(a2b27ee22f63c3f1), C(9ebde0ce1b3976b2), C(2fe6a92a257af308), C(8c1df927a930af59), C(a462f4423c9e384e), C(236542255b2ad8d9), C(595d201a2c19d5bc), C(a9be6c41)},
	{C(d8f2f234899bcab3), C(b10b037297c3a168), C(debea2c510ceda7f), C(9498fefb890287ce), C(ae68c2be5b1a69a6), C(6189dfba34ed656c), C(91658f95836e5206), C(fa31801)},
	{C(584f28543864844f), C(d7cee9fc2d46f20d), C(a38dca5657387205), C(7a0b6dbab9a14e69), C(c6d0a9d6b0e31ac4), C(a674d85812c7cf6), C(63538c0351049940), C(8331c5d8)},
	{C(a94be46dd9aa41af), C(a57e5b7723d3f9bd), C(34bf845a52fd2f), C(843b58463c8df0ae), C(74b258324e916045), C(bdd7353230eb2b38), C(fad31fced7abade5), C(e9876db8)},
	{C(9a87bea227491d20), C(a468657e2b9c43e7), C(af9ba60db8d89ef7), C(cc76f429ea7a12bb), C(5f30eaf2bb14870a), C(434e824cb3e0cd11), C(431a4d382e39d16e), C(27b0604e)},
	{C(27688c24958d1a5c), C(e3b4a1c9429cf253), C(48a95811f70d64bc), C(328063229db22884), C(67e9c95f8ba96028), C(7c6bf01c60436075), C(fa55161e7d9030b2), C(dcec07f2)},
	{C(5d1d37790a1873ad), C(ed9cd4bcc5fa1090), C(ce51cde05d8cd96a), C(f72c26e624407e66), C(a0eb541bdbc6d409), C(c3f40a2f40b3b213), C(6a784de68794492d), C(cff0a82a)},
	{C(1f03fd18b711eea9), C(566d89b1946d381a), C(6e96e83fc92563ab), C(405f66cf8cae1a32), C(d7261740d8f18ce6), C(fea3af64a413d0b2), C(d64d1810e83520fe), C(fec83621)},
	{C(f0316f286cf527b6), C(f84c29538de1aa5a), C(7612ed3c923d4a71), C(d4eccebe9393ee8a), C(2eb7867c2318cc59), C(1ce621fd700fe396), C(686450d7a346878a), C(743d8dc)},
	{C(297008bcb3e3401d), C(61a8e407f82b0c69), C(a4a35bff0524fa0e), C(7a61d8f552a53442), C(821d1d8d8cfacf35), C(7cc06361b86d0559), C(119b617a8c2be199), C(64d41d26)},
	{C(43c6252411ee3be), C(b4ca1b8077777168), C(2746dc3f7da1737f), C(2247a4b2058d1c50), C(1b3fa184b1d7bcc0), C(deb85613995c06ed), C(cbe1d957485a3ccd), C(acd90c81)},
	{C(ce38a9a54fad6599), C(6d6f4a90b9e8755e), C(c3ecc79ff105de3f), C(e8b9ee96efa2d0e), C(90122905c4ab5358), C(84f80c832d71979c), C(229310f3ffbbf4c6), C(7c746a4b)},
	{C(270a9305fef70cf), C(600193999d884f3a), C(f4d49eae09ed8a1), C(2e091b85660f1298), C(bfe37fae1cdd64c9), C(8dddfbab930f6494), C(2ccf4b08f5d417a), C(b1047e99)},
	{C(e71be7c28e84d119), C(eb6ace59932736e6), C(70c4397807ba12c5), C(7a9d77781ac53509), C(4489c3ccfda3b39c), C(fa722d4f243b4964), C(25f15800bffdd122), C(d1fd1068)},
	{C(b5b58c24b53aaa19), C(d2a6ab0773dd897f), C(ef762fe01ecb5b97), C(9deefbcfa4cab1f1), C(b58f5943cd2492ba), C(a96dcc4d1f4782a7), C(102b62a82309dde5), C(56486077)},
	{C(44dd59bd301995cf), C(3ccabd76493ada1a), C(540db4c87d55ef23), C(cfc6d7adda35797), C(14c7d1f32332cf03), C(2d553ffbff3be99d), C(c91c4ee0cb563182), C(6069be80)},
	{C(b4d4789eb6f2630b), C(bf6973263ce8ef0e), C(d1c75c50844b9d3), C(bce905900c1ec6ea), C(c30f304f4045487d), C(a5c550166b3a142b), C(2f482b4e35327287), C(2078359b)},
	{C(12807833c463737c), C(58e927ea3b3776b4), C(72dd20ef1c2f8ad0), C(910b610de7a967bf), C(801bc862120f6bf5), C(9653efeed5897681), C(f5367ff83e9ebbb3), C(9ea21004)},
	{C(e88419922b87176f), C(bcf32f41a7ddbf6f), C(d6ebefd8085c1a0f), C(d1d44fe99451ef72), C(ec951ba8e51e3545), C(c0ca86b360746e96), C(aa679cc066a8040b), C(9c9cfe88)},
	{C(105191e0ec8f7f60), C(5918dbfcca971e79), C(6b285c8a944767b9), C(d3e86ac4f5eccfa4), C(e5399df2b106ca1), C(814aadfacd217f1d), C(2754e3def1c405a9), C(b70a6ddd)},
	{C(a5b88bf7399a9f07), C(fca3ddfd96461cc4), C(ebe738fdc0282fc6), C(69afbc800606d0fb), C(6104b97a9db12df7), C(fcc09198bb90bf9f), C(c5e077e41a65ba91), C(dea37298)},
	{C(d08c3f5747d84f50), C(4e708b27d1b6f8ac), C(70f70fd734888606), C(909ae019d761d019), C(368bf4aab1b86ef9), C(308bd616d5460239), C(4fd33269f76783ea), C(8f480819)},
	{C(2f72d12a40044b4b), C(889689352fec53de), C(f03e6ad87eb2f36), C(ef79f28d874b9e2d), C(b512089e8e63b76c), C(24dc06833bf193a9), C(3c23308ba8e99d7e), C(30b3b16)},
	{C(aa1f61fdc5c2e11e), C(c2c56cd11277ab27), C(a1e73069fdf1f94f), C(8184bab36bb79df0), C(c81929ce8655b940), C(301b11bf8a4d8ce8), C(73126fd45ab75de9), C(f31bc4e8)},
	{C(9489b36fe2246244), C(3355367033be74b8), C(5f57c2277cbce516), C(bc61414f9802ecaf), C(8edd1e7a50562924), C(48f4ab74a35e95f2), C(cc1afcfd99a180e7), C(419f953b)},
	{C(358d7c0476a044cd), C(e0b7b47bcbd8854f), C(ffb42ec696705519), C(d45e44c263e95c38), C(df61db53923ae3b1), C(f2bc948cc4fc027c), C(8a8000c6066772a3), C(20e9e76d)},
	{C(b0c48df14275265a), C(9da4448975905efa), C(d716618e414ceb6d), C(30e888af70df1e56), C(4bee54bd47274f69), C(178b4059e1a0afe5), C(6e2c96b7f58e5178), C(646f0ff8)},
	{C(daa70bb300956588), C(410ea6883a240c6d), C(f5c8239fb5673eb3), C(8b1d7bb4903c105f), C(cfb1c322b73891d4), C(5f3b792b22f07297), C(fd64061f8be86811), C(eeb7eca8)},
	{C(4ec97a20b6c4c7c2), C(5913b1cd454f29fd), C(a9629f9daf06d685), C(852c9499156a8f3), C(3a180a6abfb79016), C(9fc3c4764037c3c9), C(2890c42fc0d972cf), C(8112bb9)},
	{C(5c3323628435a2e8), C(1bea45ce9e72a6e3), C(904f0a7027ddb52e), C(939f31de14dcdc7b), C(a68fdf4379df068), C(f169e1f0b835279d), C(7498e432f9619b27), C(85a6d477)},
	{C(c1ef26bea260abdb), C(6ee423f2137f9280), C(df2118b946ed0b43), C(11b87fb1b900cc39), C(e33e59b90dd815b1), C(aa6cb5c4bafae741), C(739699951ca8c713), C(56f76c84)},
	{C(6be7381b115d653a), C(ed046190758ea511), C(de6a45ffc3ed1159), C(a64760e4041447d0), C(e3eac49f3e0c5109), C(dd86c4d4cb6258e2), C(efa9857afd046c7f), C(9af45d55)},
	{C(ae3eece1711b2105), C(14fd3f4027f81a4a), C(abb7e45177d151db), C(501f3e9b18861e44), C(465201170074e7d8), C(96d5c91970f2cb12), C(40fd28c43506c95d), C(d1c33760)},
	{C(376c28588b8fb389), C(6b045e84d8491ed2), C(4e857effb7d4e7dc), C(154dd79fd2f984b4), C(f11171775622c1c3), C(1fbe30982e78e6f0), C(a460a15dcf327e44), C(c56bbf69)},
	{C(58d943503bb6748f), C(419c6c8e88ac70f6), C(586760cbf3d3d368), C(b7e164979d5ccfc1), C(12cb4230d26bf286), C(f1bf910d44bd84cb), C(b32c24c6a40272), C(abecfb9b)},
	{C(dfff5989f5cfd9a1), C(bcee2e7ea3a96f83), C(681c7874adb29017), C(3ff6c8ac7c36b63a), C(48bc8831d849e326), C(30b078e76b0214e2), C(42954e6ad721b920), C(8de13255)},
	{C(7fb19eb1a496e8f5), C(d49e5dfdb5c0833f), C(c0d5d7b2f7c48dc7), C(1a57313a32f22dde), C(30af46e49850bf8b), C(aa0fe8d12f808f83), C(443e31d70873bb6b), C(a98ee299)},
	{C(5dba5b0dadccdbaa), C(4ba8da8ded87fcdc), C(f693fdd25badf2f0), C(e9029e6364286587), C(ae69f49ecb46726c), C(18e002679217c405), C(bd6d66e85332ae9f), C(3015f556)},
	{C(688bef4b135a6829), C(8d31d82abcd54e8e), C(f95f8a30d55036d7), C(3d8c90e27aa2e147), C(2ec937ce0aa236b4), C(89b563996d3a0b78), C(39b02413b23c3f08), C(5a430e29)},
	{C(d8323be05433a412), C(8d48fa2b2b76141d), C(3d346f23978336a5), C(4d50c7537562033f), C(57dc7625b61dfe89), C(9723a9f4c08ad93a), C(5309596f48ab456b), C(2797add0)},
	{C(3b5404278a55a7fc), C(23ca0b327c2d0a81), C(a6d65329571c892c), C(45504801e0e6066b), C(86e6c6d6152a3d04), C(4f3db1c53eca2952), C(d24d69b3e9ef10f3), C(27d55016)},
	{C(2a96a3f96c5e9bbc), C(8caf8566e212dda8), C(904de559ca16e45e), C(f13bc2d9c2fe222e), C(be4ccec9a6cdccfd), C(37b2cbdd973a3ac9), C(7b3223cd9c9497be), C(84945a82)},
	{C(22bebfdcc26d18ff), C(4b4d8dcb10807ba1), C(40265eee30c6b896), C(3752b423073b119a), C(377dc5eb7c662bdb), C(2b9f07f93a6c25b9), C(96f24ede2bdc0718), C(3ef7e224)},
	{C(627a2249ec6bbcc2), C(c0578b462a46735a), C(4974b8ee1c2d4f1f), C(ebdbb918eb6d837f), C(8fb5f218dd84147c), C(c77dd1f881df2c54), C(62eac298ec226dc3), C(35ed8dc8)},
	{C(3abaf1667ba2f3e0), C(ee78476b5eeadc1), C(7e56ac0a6ca4f3f4), C(f1b9b413df9d79ed), C(a7621b6fd02db503), C(d92f7ba9928a4ffe), C(53f56babdcae96a6), C(6a75e43d)},
	{C(3931ac68c5f1b2c9), C(efe3892363ab0fb0), C(40b707268337cd36), C(a53a6b64b1ac85c9), C(d50e7f86ee1b832b), C(7bab08fdd26ba0a4), C(7587743c18fe2475), C(235d9805)},
	{C(b98fb0606f416754), C(46a6e5547ba99c1e), C(c909d82112a8ed2), C(dbfaae9642b3205a), C(f676a1339402bcb9), C(f4f12a5b1ac11f29), C(7db8bad81249dee4), C(f7d69572)},
	{C(7f7729a33e58fcc4), C(2e4bc1e7a023ead4), C(e707008ea7ca6222), C(47418a71800334a0), C(d10395d8fc64d8a4), C(8257a30062cb66f), C(6786f9b2dc1ff18a), C(bacd0199)},
	{C(42a0aa9ce82848b3), C(57232730e6bee175), C(f89bb3f370782031), C(caa33cf9b4f6619c), C(b2c8648ad49c209f), C(9e89ece0712db1c0), C(101d8274a711a54b), C(e428f50e)},
	{C(6b2c6d38408a4889), C(de3ef6f68fb25885), C(20754f456c203361), C(941f5023c0c943f9), C(dfdeb9564fd66f24), C(2140cec706b9d406), C(7b22429b131e9c72), C(81eaaad3)},
	{C(930380a3741e862a), C(348d28638dc71658), C(89dedcfd1654ea0d), C(7e7f61684080106), C(837ace9794582976), C(5ac8ca76a357eb1b), C(32b58308625661fb), C(addbd3e3)},
	{C(94808b5d2aa25f9a), C(cec72968128195e0), C(d9f4da2bdc1e130f), C(272d8dd74f3006cc), C(ec6c2ad1ec03f554), C(4ad276b249a5d5dd), C(549a22a17c0cde12), C(e66dbca0)},
	{C(b31abb08ae6e3d38), C(9eb9a95cbd9e8223), C(8019e79b7ee94ea9), C(7b2271a7a3248e22), C(3b4f700e5a0ba523), C(8ebc520c227206fe), C(da3f861490f5d291), C(afe11fd5)},
	{C(dccb5534a893ea1a), C(ce71c398708c6131), C(fe2396315457c164), C(3f1229f4d0fd96fb), C(33130aa5fa9d43f2), C(e42693d5b34e63ab), C(2f4ef2be67f62104), C(a71a406f)},
	{C(6369163565814de6), C(8feb86fb38d08c2f), C(4976933485cc9a20), C(7d3e82d5ba29a90d), C(d5983cc93a9d126a), C(37e9dfd950e7b692), C(80673be6a7888b87), C(9d90eaf5)},
	{C(edee4ff253d9f9b3), C(96ef76fb279ef0ad), C(a4d204d179db2460), C(1f3dcdfa513512d6), C(4dc7ec07283117e4), C(4438bae88ae28bf9), C(aa7eae72c9244a0d), C(6665db10)},
	{C(941993df6e633214), C(929bc1beca5b72c6), C(141fc52b8d55572d), C(b3b782ad308f21ed), C(4f2676485041dee0), C(bfe279aed5cb4bc8), C(2a62508a467a22ff), C(9c977cbf)},
	{C(859838293f64cd4c), C(484403b39d44ad79), C(bf674e64d64b9339), C(44d68afda9568f08), C(478568ed51ca1d65), C(679c204ad3d9e766), C(b28e788878488dc1), C(ee83ddd4)},
	{C(c19b5648e0d9f555), C(328e47b2b7562993), C(e756b92ba4bd6a51), C(c3314e362764ddb8), C(6481c084ee9ec6b5), C(ede23fb9a251771), C(bd617f2643324590), C(26519cc)},
	{C(f963b63b9006c248), C(9e9bf727ffaa00bc), C(c73bacc75b917e3a), C(2c6aa706129cc54c), C(17a706f59a49f086), C(c7c1eec455217145), C(6adfdc6e07602d42), C(a485a53f)},
	{C(6a8aa0852a8c1f3b), C(c8f1e5e206a21016), C(2aa554aed1ebb524), C(fc3e3c322cd5d89b), C(b7e3911dc2bd4ebb), C(fcd6da5e5fae833a), C(51ed3c41f87f9118), C(f62bc412)},
	{C(740428b4d45e5fb8), C(4c95a4ce922cb0a5), C(e99c3ba78feae796), C(914f1ea2fdcebf5c), C(9566453c07cd0601), C(9841bf66d0462cd), C(79140c1c18536aeb), C(8975a436)},
	{C(658b883b3a872b86), C(2f0e303f0f64827a), C(975337e23dc45e1), C(99468a917986162b), C(7b31434aac6e0af0), C(f6915c1562c7d82f), C(e4071d82a6dd71db), C(94ff7f41)},
	{C(6df0a977da5d27d4), C(891dd0e7cb19508), C(fd65434a0b71e680), C(8799e4740e573c50), C(9e739b52d0f341e8), C(cdfd34ba7d7b03eb), C(5061812ce6c88499), C(760aa031)},
	{C(a900275464ae07ef), C(11f2cfda34beb4a3), C(9abf91e5a1c38e4), C(8063d80ab26f3d6d), C(4177b4b9b4f0393f), C(6de42ba8672b9640), C(d0bccdb72c51c18), C(3bda76df)},
	{C(810bc8aa0c40bcb0), C(448a019568d01441), C(f60ec52f60d3aeae), C(52c44837aa6dfc77), C(15d8d8fccdd6dc5b), C(345b793ccfa93055), C(932160fe802ca975), C(498e2e65)},
	{C(22036327deb59ed7), C(adc05ceb97026a02), C(48bff0654262672b), C(c791b313aba3f258), C(443c7757a4727bee), C(e30e4b2372171bdf), C(f3db986c4156f3cb), C(d38deb48)},
	{C(7d14dfa9772b00c8), C(595735efc7eeaed7), C(29872854f94c3507), C(bc241579d8348401), C(16dc832804d728f0), C(e9cc71ae64e3f09e), C(bef634bc978bac31), C(82b3fb6b)},
	{C(2d777cddb912675d), C(278d7b10722a13f9), C(f5c02bfb7cc078af), C(4283001239888836), C(f44ca39a6f79db89), C(ed186122d71bcc9f), C(8620017ab5f3ba3b), C(e500e25f)},
	{C(f2ec98824e8aa613), C(5eb7e3fb53fe3bed), C(12c22860466e1dd4), C(374dd4288e0b72e5), C(ff8916db706c0df4), C(cb1a9e85de5e4b8d), C(d4d12afb67a27659), C(bd2bb07c)},
	{C(5e763988e21f487f), C(24189de8065d8dc5), C(d1519d2403b62aa0), C(9136456740119815), C(4d8ff7733b27eb83), C(ea3040bc0c717ef8), C(7617ab400dfadbc), C(3a2b431d)},
	{C(48949dc327bb96ad), C(e1fd21636c5c50b4), C(3f6eb7f13a8712b4), C(14cf7f02dab0eee8), C(6d01750605e89445), C(4f1cf4006e613b78), C(57c40c4db32bec3b), C(7322a83d)},
	{C(b7c4209fb24a85c5), C(b35feb319c79ce10), C(f0d3de191833b922), C(570d62758ddf6397), C(5e0204fb68a7b800), C(4383a9236f8b5a2b), C(7bc1a64641d803a4), C(a645ca1c)},
	{C(9c9e5be0943d4b05), C(b73dc69e45201cbb), C(aab17180bfe5083d), C(c738a77a9a55f0e2), C(705221addedd81df), C(fd9bd8d397abcfa3), C(8ccf0004aa86b795), C(8909a45a)},
	{C(3898bca4dfd6638d), C(f911ff35efef0167), C(24bdf69e5091fc88), C(9b82567ab6560796), C(891b69462b41c224), C(8eccc7e4f3af3b51), C(381e54c3c8f1c7d0), C(bd30074c)},
	{C(5b5d2557400e68e7), C(98d610033574cee), C(dfd08772ce385deb), C(3c13e894365dc6c2), C(26fc7bbcda3f0ef), C(dbb71106cdbfea36), C(785239a742c6d26d), C(c17cf001)},
	{C(a927ed8b2bf09bb6), C(606e52f10ae94eca), C(71c2203feb35a9ee), C(6e65ec14a8fb565), C(34bff6f2ee5a7f79), C(2e329a5be2c011b), C(73161c93331b14f9), C(26ffd25a)},
	{C(8d25746414aedf28), C(34b1629d28b33d3a), C(4d5394aea5f82d7b), C(379f76458a3c8957), C(79dd080f9843af77), C(c46f0a7847f60c1d), C(af1579c5797703cc), C(f1d8ce3c)},
	{C(b5bbdb73458712f2), C(1ff887b3c2a35137), C(7f7231f702d0ace9), C(1e6f0910c3d25bd8), C(ad9e250862102467), C(1c842a07abab30cd), C(cd8124176bac01ac), C(3ee8fb17)},
	{C(3d32a26e3ab9d254), C(fc4070574dc30d3a), C(f02629579c2b27c9), C(b1cf09b0184a4834), C(5c03db48eb6cc159), C(f18c7fcf34d1df47), C(dfb043419ecf1fa9), C(a77acc2a)},
	{C(9371d3c35fa5e9a5), C(42967cf4d01f30), C(652d1eeae704145c), C(ceaf1a0d15234f15), C(1450a54e45ba9b9), C(65e9c1fd885aa932), C(354d4bc034ba8cbe), C(f4556dee)},
	{C(cbaa3cb8f64f54e0), C(76c3b48ee5c08417), C(9f7d24e87e61ce9), C(85b8e53f22e19507), C(bb57137739ca486b), C(c77f131cca38f761), C(c56ac3cf275be121), C(de287a64)},
	{C(b2e23e8116c2ba9f), C(7e4d9c0060101151), C(3310da5e5028f367), C(adc52dddb76f6e5e), C(4aad4e925a962b68), C(204b79b7f7168e64), C(df29ed6671c36952), C(878e55b9)},
	{C(8aa77f52d7868eb9), C(4d55bd587584e6e2), C(d2db37041f495f5), C(ce030d15b5fe2f4), C(86b4a7a0780c2431), C(ee070a9ae5b51db7), C(edc293d9595be5d8), C(7648486)},
	{C(858fea922c7fe0c3), C(cfe8326bf733bc6f), C(4e5e2018cf8f7dfc), C(64fd1bc011e5bab7), C(5c9e858728015568), C(97ac42c2b00b29b1), C(7f89caf08c109aee), C(57ac0fb1)},
	{C(46ef25fdec8392b1), C(e48d7b6d42a5cd35), C(56a6fe1c175299ca), C(fdfa836b41dcef62), C(2f8db8030e847e1b), C(5ba0a49ac4f9b0f8), C(dae897ed3e3fce44), C(d01967ca)},
	{C(8d078f726b2df464), C(b50ee71cdcabb299), C(f4af300106f9c7ba), C(7d222caae025158a), C(cc028d5fd40241b9), C(dd42515b639e6f97), C(e08e86531a58f87f), C(96ecdf74)},
	{C(35ea86e6960ca950), C(34fe1fe234fc5c76), C(a00207a3dc2a72b7), C(80395e48739e1a67), C(74a67d8f7f43c3d7), C(dd2bdd1d62246c6e), C(a1f44298ba80acf6), C(779f5506)},
	{C(8aee9edbc15dd011), C(51f5839dc8462695), C(b2213e17c37dca2d), C(133b299a939745c5), C(796e2aac053f52b3), C(e8d9fe1521a4a222), C(819a8863e5d1c290), C(3c94c2de)},
	{C(c3e142ba98432dda), C(911d060cab126188), C(b753fbfa8365b844), C(fd1a9ba5e71b08a2), C(7ac0dc2ed7778533), C(b543161ff177188a), C(492fc08a6186f3f4), C(39f98faf)},
	{C(123ba6b99c8cd8db), C(448e582672ee07c4), C(cebe379292db9e65), C(938f5bbab544d3d6), C(d2a95f9f2d376d73), C(68b2f16149e81aa3), C(ad7e32f82d86c79d), C(7af31199)},
	{C(ba87acef79d14f53), C(b3e0fcae63a11558), C(d5ac313a593a9f45), C(eea5f5a9f74af591), C(578710bcc36fbea2), C(7a8393432188931d), C(705cfc5ec7cc172), C(e341a9d6)},
	{C(bcd3957d5717dc3), C(2da746741b03a007), C(873816f4b1ece472), C(2b826f1a2c08c289), C(da50f56863b55e74), C(b18712f6b3eed83b), C(bdc7cc05ab4c685f), C(ca24aeeb)},
	{C(61442ff55609168e), C(6447c5fc76e8c9cf), C(6a846de83ae15728), C(effc2663cffc777f), C(93214f8f463afbed), C(a156ef06066f4e4e), C(a407b6ed8769d51e), C(b2252b57)},
	{C(dbe4b1b2d174757f), C(506512da18712656), C(6857f3e0b8dd95f), C(5a4fc2728a9bb671), C(ebb971522ec38759), C(1a5a093e6cf1f72b), C(729b057fe784f504), C(72c81da1)},
	{C(531e8e77b363161c), C(eece0b43e2dae030), C(8294b82c78f34ed1), C(e777b1fd580582f2), C(7b880f58da112699), C(562c6b189a6333f4), C(139d64f88a611d4), C(6b9fce95)},
	{C(f71e9c926d711e2b), C(d77af2853a4ceaa1), C(9aa0d6d76a36fae7), C(dd16cd0fbc08393), C(29a414a5d8c58962), C(72793d8d1022b5b2), C(2e8e69cf7cbffdf0), C(19399857)},
	{C(cb20ac28f52df368), C(e6705ee7880996de), C(9b665cc3ec6972f2), C(4260e8c254e9924b), C(f197a6eb4591572d), C(8e867ff0fb7ab27c), C(f95502fb503efaf3), C(3c57a994)},
	{C(e4a794b4acb94b55), C(89795358057b661b), C(9c4cdcec176d7a70), C(4890a83ee435bc8b), C(d8c1c00fceb00914), C(9e7111ba234f900f), C(eb8dbab364d8b604), C(c053e729)},
	{C(cb942e91443e7208), C(e335de8125567c2a), C(d4d74d268b86df1f), C(8ba0fdd2ffc8b239), C(f413b366c1ffe02f), C(c05b2717c59a8a28), C(981188eab4fcc8fb), C(51cbbba7)},
	{C(ecca7563c203f7ba), C(177ae2423ef34bb2), C(f60b7243400c5731), C(cf1edbfe7330e94e), C(881945906bcb3cc6), C(4acf0293244855da), C(65ae042c1c2a28c2), C(1acde79a)},
	{C(1652cb940177c8b5), C(8c4fe7d85d2a6d6d), C(f6216ad097e54e72), C(f6521b912b368ae6), C(a9fe4eff81d03e73), C(d6f623629f80d1a3), C(2b9604f32cb7dc34), C(2d160d13)},
	{C(31fed0fc04c13ce8), C(3d5d03dbf7ff240a), C(727c5c9b51581203), C(6b5ffc1f54fecb29), C(a8e8e7ad5b9a21d9), C(c4d5a32cd6aac22d), C(d7e274ad22d4a79a), C(787f5801)},
	{C(e7b668947590b9b3), C(baa41ad32938d3fa), C(abcbc8d4ca4b39e4), C(381ee1b7ea534f4e), C(da3759828e3de429), C(3e015d76729f9955), C(cbbec51a6485fbde), C(c9629828)},
	{C(1de2119923e8ef3c), C(6ab27c096cf2fe14), C(8c3658edca958891), C(4cc8ed3ada5f0f2), C(4a496b77c1f1c04e), C(9085b0a862084201), C(a1894bde9e3dee21), C(be139231)},
	{C(1269df1e69e14fa7), C(992f9d58ac5041b7), C(e97fcf695a7cbbb4), C(e5d0549802d15008), C(424c134ecd0db834), C(6fc44fd91be15c6c), C(a1a5ef95d50e537d), C(7df699ef)},
	{C(820826d7aba567ff), C(1f73d28e036a52f3), C(41c4c5a73f3b0893), C(aa0d74d4a98db89b), C(36fd486d07c56e1d), C(d0ad23cbb6660d8a), C(1264a84665b35e19), C(8ce6b96d)},
	{C(ffe0547e4923cef9), C(3534ed49b9da5b02), C(548a273700fba03d), C(28ac84ca70958f7e), C(d8ae575a68faa731), C(2aaaee9b9dcffd4c), C(6c7faab5c285c6da), C(6f9ed99c)},
	{C(72da8d1b11d8bc8b), C(ba94b56b91b681c6), C(4e8cc51bd9b0fc8c), C(43505ed133be672a), C(e8f2f9d973c2774e), C(677b9b9c7cad6d97), C(4e1f5d56ef17b906), C(e0244796)},
	{C(d62ab4e3f88fc797), C(ea86c7aeb6283ae4), C(b5b93e09a7fe465), C(4344a1a0134afe2), C(ff5c17f02b62341d), C(3214c6a587ce4644), C(a905e7ed0629d05c), C(4ccf7e75)},
	{C(d0f06c28c7b36823), C(1008cb0874de4bb8), C(d6c7ff816c7a737b), C(489b697fe30aa65f), C(4da0fb621fdc7817), C(dc43583b82c58107), C(4b0261debdec3cd6), C(915cef86)},
	{C(99b7042460d72ec6), C(2a53e5e2b8e795c2), C(53a78132d9e1b3e3), C(c043e67e6fc64118), C(ff0abfe926d844d3), C(f2a9fe5db2e910fe), C(ce352cdc84a964dd), C(5cb59482)},
	{C(4f4dfcfc0ec2bae5), C(841233148268a1b8), C(9248a76ab8be0d3), C(334c5a25b5903a8c), C(4c94fef443122128), C(743e7d8454655c40), C(1ab1e6d1452ae2cd), C(6ca3f532)},
	{C(fe86bf9d4422b9ae), C(ebce89c90641ef9c), C(1c84e2292c0b5659), C(8bde625a10a8c50d), C(eb8271ded1f79a0b), C(14dc6844f0de7a3c), C(f85b2f9541e7e6da), C(e24f3859)},
	{C(a90d81060932dbb0), C(8acfaa88c5fbe92b), C(7c6f3447e90f7f3f), C(dd52fc14c8dd3143), C(1bc7508516e40628), C(3059730266ade626), C(ffa526822f391c2), C(adf5a9c7)},
	{C(17938a1b0e7f5952), C(22cadd2f56f8a4be), C(84b0d1183d5ed7c1), C(c1336b92fef91bf6), C(80332a3945f33fa9), C(a0f68b86f726ff92), C(a3db5282cf5f4c0b), C(32264b75)},
	{C(de9e0cb0e16f6e6d), C(238e6283aa4f6594), C(4fb9c914c2f0a13b), C(497cb912b670f3b), C(d963a3f02ff4a5b6), C(4fccefae11b50391), C(42ba47db3f7672f), C(a64b3376)},
	{C(6d4b876d9b146d1a), C(aab2d64ce8f26739), C(d315f93600e83fe5), C(2fe9fabdbe7fdd4), C(755db249a2d81a69), C(f27929f360446d71), C(79a1bf957c0c1b92), C(d33890e)},
	{C(e698fa3f54e6ea22), C(bd28e20e7455358c), C(9ace161f6ea76e66), C(d53fb7e3c93a9e4), C(737ae71b051bf108), C(7ac71feb84c2df42), C(3d8075cd293a15b4), C(926d4b63)},
	{C(7bc0deed4fb349f7), C(1771aff25dc722fa), C(19ff0644d9681917), C(cf7d7f25bd70cd2c), C(9464ed9baeb41b4f), C(b9064f5c3cb11b71), C(237e39229b012b20), C(d51ba539)},
	{C(db4b15e88533f622), C(256d6d2419b41ce9), C(9d7c5378396765d5), C(9040e5b936b8661b), C(276e08fa53ac27fd), C(8c944d39c2bdd2cc), C(e2514c9802a5743c), C(7f37636d)},
	{C(922834735e86ecb2), C(363382685b88328e), C(e9c92960d7144630), C(8431b1bfd0a2379c), C(90383913aea283f9), C(a6163831eb4924d2), C(5f3921b4f9084aee), C(b98026c0)},
	{C(30f1d72c812f1eb8), C(b567cd4a69cd8989), C(820b6c992a51f0bc), C(c54677a80367125e), C(3204fbdba462e606), C(8563278afc9eae69), C(262147dd4bf7e566), C(b877767e)},
	{C(168884267f3817e9), C(5b376e050f637645), C(1c18314abd34497a), C(9598f6ab0683fcc2), C(1c805abf7b80e1ee), C(dec9ac42ee0d0f32), C(8cd72e3912d24663), C(aefae77)},
	{C(82e78596ee3e56a7), C(25697d9c87f30d98), C(7600a8342834924d), C(6ba372f4b7ab268b), C(8c3237cf1fe243df), C(3833fc51012903df), C(8e31310108c5683f), C(f686911)},
	{C(aa2d6cf22e3cc252), C(9b4dec4f5e179f16), C(76fb0fba1d99a99a), C(9a62af3dbba140da), C(27857ea044e9dfc1), C(33abce9da2272647), C(b22a7993aaf32556), C(3deadf12)},
	{C(7bf5ffd7f69385c7), C(fc077b1d8bc82879), C(9c04e36f9ed83a24), C(82065c62e6582188), C(8ef787fd356f5e43), C(2922e53e36e17dfa), C(9805f223d385010b), C(ccf02a4e)},
	{C(e89c8ff9f9c6e34b), C(f54c0f669a49f6c4), C(fc3e46f5d846adef), C(22f2aa3df2221cc), C(f66fea90f5d62174), C(b75defaeaa1dd2a7), C(9b994cd9a7214fd5), C(176c1722)},
	{C(a18fbcdccd11e1f4), C(8248216751dfd65e), C(40c089f208d89d7c), C(229b79ab69ae97d), C(a87aabc2ec26e582), C(be2b053721eb26d2), C(10febd7f0c3d6fcb), C(26f82ad)},
	{C(2d54f40cc4088b17), C(59d15633b0cd1399), C(a8cc04bb1bffd15b), C(d332cdb073d8dc46), C(272c56466868cb46), C(7e7fcbe35ca6c3f3), C(ee8f51e5a70399d4), C(b5244f42)},
	{C(69276946cb4e87c7), C(62bdbe6183be6fa9), C(3ba9773dac442a1a), C(702e2afc7f5a1825), C(8c49b11ea8151fdc), C(caf3fef61f5a86fa), C(ef0b2ee8649d7272), C(49a689e5)},
	{C(668174a3f443df1d), C(407299392da1ce86), C(c2a3f7d7f2c5be28), C(a590b202a7a5807b), C(968d2593f7ccb54e), C(9dd8d669e3e95dec), C(ee0cc5dd58b6e93a), C(59fcdd3)},
	{C(5e29be847bd5046), C(b561c7f19c8f80c3), C(5e5abd5021ccaeaf), C(7432d63888e0c306), C(74bbceeed479cb71), C(6471586599575fdf), C(6a859ad23365cba2), C(4f4b04e9)},
	{C(cd0d79f2164da014), C(4c386bb5c5d6ca0c), C(8e771b03647c3b63), C(69db23875cb0b715), C(ada8dd91504ae37f), C(46bf18dbf045ed6a), C(e1b5f67b0645ab63), C(8b00f891)},
	{C(e0e6fc0b1628af1d), C(29be5fb4c27a2949), C(1c3f781a604d3630), C(c4af7faf883033aa), C(9bd296c4e9453cac), C(ca45426c1f7e33f9), C(a6bbdcf7074d40c5), C(16e114f3)},
	{C(2058927664adfd93), C(6e8f968c7963baa5), C(af3dced6fff7c394), C(42e34cf3d53c7876), C(9cddbb26424dc5e), C(64f6340a6d8eddad), C(2196e488eb2a3a4b), C(d6b6dadc)},
	{C(dc107285fd8e1af7), C(a8641a0609321f3f), C(db06e89ffdc54466), C(bcc7a81ed5432429), C(b6d7bdc6ad2e81f1), C(93605ec471aa37db), C(a2a73f8a85a8e397), C(897e20ac)},
	{C(fbba1afe2e3280f1), C(755a5f392f07fce), C(9e44a9a15402809a), C(6226a32e25099848), C(ea895661ecf53004), C(4d7e0158db2228b9), C(e5a7d82922f69842), C(f996e05d)},
	{C(bfa10785ddc1011b), C(b6e1c4d2f670f7de), C(517d95604e4fcc1f), C(ca6552a0dfb82c73), C(b024cdf09e34ba07), C(66cd8c5a95d7393b), C(e3939acf790d4a74), C(c4306af6)},
	{C(534cc35f0ee1eb4e), C(b703820f1f3b3dce), C(884aa164cf22363), C(f14ef7f47d8a57a3), C(80d1f86f2e061d7c), C(401d6c2f151b5a62), C(e988460224108944), C(6dcad433)},
	{C(7ca6e3933995dac), C(fd118c77daa8188), C(3aceb7b5e7da6545), C(c8389799445480db), C(5389f5df8aacd50d), C(d136581f22fab5f), C(c2f31f85991da417), C(3c07374d)},
	{C(f0d6044f6efd7598), C(e044d6ba4369856e), C(91968e4f8c8a1a4c), C(70bd1968996bffc2), C(4c613de5d8ab32ac), C(fe1f4f97206f79d8), C(ac0434f2c4e213a9), C(f0f4602c)},
	{C(3d69e52049879d61), C(76610636ea9f74fe), C(e9bf5602f89310c0), C(8eeb177a86053c11), C(e390122c345f34a2), C(1e30e47afbaaf8d6), C(7b892f68e5f91732), C(3e1ea071)},
	{C(79da242a16acae31), C(183c5f438e29d40), C(6d351710ae92f3de), C(27233b28b5b11e9b), C(c7dfe8988a942700), C(570ed11c4abad984), C(4b4c04632f48311a), C(67580f0c)},
	{C(461c82656a74fb57), C(d84b491b275aa0f7), C(8f262cb29a6eb8b2), C(49fa3070bc7b06d0), C(f12ed446bd0c0539), C(6d43ac5d1dd4b240), C(7609524fe90bec93), C(4e109454)},
	{C(53c1a66d0b13003), C(731f060e6fe797fc), C(daa56811791371e3), C(57466046cf6896ed), C(8ac37e0e8b25b0c6), C(3e6074b52ad3cf18), C(aa491ce7b45db297), C(88a474a7)},
	{C(d3a2efec0f047e9), C(1cabce58853e58ea), C(7a17b2eae3256be4), C(c2dcc9758c910171), C(cb5cddaeff4ddb40), C(5d7cc5869baefef1), C(9644c5853af9cfeb), C(5b5bedd)},
	{C(43c64d7484f7f9b2), C(5da002b64aafaeb7), C(b576c1e45800a716), C(3ee84d3d5b4ca00b), C(5cbc6d701894c3f9), C(d9e946f5ae1ca95), C(24ca06e67f0b1833), C(1aaddfa7)},
	{C(a7dec6ad81cf7fa1), C(180c1ab708683063), C(95e0fd7008d67cff), C(6b11c5073687208), C(7e0a57de0d453f3), C(e48c267d4f646867), C(2168e9136375f9cb), C(5be07fd8)},
	{C(5408a1df99d4aff), C(b9565e588740f6bd), C(abf241813b08006e), C(7da9e81d89fda7ad), C(274157cabe71440d), C(2c22d9a480b331f7), C(e835c8ac746472d5), C(cbca8606)},
	{C(a8b27a6bcaeeed4b), C(aec1eeded6a87e39), C(9daf246d6fed8326), C(d45a938b79f54e8f), C(366b219d6d133e48), C(5b14be3c25c49405), C(fdd791d48811a572), C(bde64d01)},
	{C(9a952a8246fdc269), C(d0dcfcac74ef278c), C(250f7139836f0f1f), C(c83d3c5f4e5f0320), C(694e7adeb2bf32e5), C(7ad09538a3da27f5), C(2b5c18f934aa5303), C(ee90cf33)},
	{C(c930841d1d88684f), C(5eb66eb18b7f9672), C(e455d413008a2546), C(bc271bc0df14d647), C(b071100a9ff2edbb), C(2b1a4c1cc31a119a), C(b5d7caa1bd946cef), C(4305c3ce)},
	{C(94dc6971e3cf071a), C(994c7003b73b2b34), C(ea16e85978694e5), C(336c1b59a1fc19f6), C(c173acaecc471305), C(db1267d24f3f3f36), C(e9a5ee98627a6e78), C(4b3a1d76)},
	{C(7fc98006e25cac9), C(77fee0484cda86a7), C(376ec3d447060456), C(84064a6dcf916340), C(fbf55a26790e0ebb), C(2e7f84151c31a5c2), C(9f7f6d76b950f9bf), C(a8bb6d80)},
	{C(bd781c4454103f6), C(612197322f49c931), C(b9cf17fd7e5462d5), C(e38e526cd3324364), C(85f2b63a5b5e840a), C(485d7cef5aaadd87), C(d2b837a462f6db6d), C(1f9fa607)},
	{C(da60e6b14479f9df), C(3bdccf69ece16792), C(18ebf45c4fecfdc9), C(16818ee9d38c6664), C(5519fa9a1e35a329), C(cbd0001e4b08ed8), C(41a965e37a0c731b), C(8d0e4ed2)},
	{C(4ca56a348b6c4d3), C(60618537c3872514), C(2fbb9f0e65871b09), C(30278016830ddd43), C(f046646d9012e074), C(c62a5804f6e7c9da), C(98d51f5830e2bc1e), C(1bf31347)},
	{C(ebd22d4b70946401), C(6863602bf7139017), C(c0b1ac4e11b00666), C(7d2782b82bd494b6), C(97159ba1c26b304b), C(42b3b0fd431b2ac2), C(faa81f82691c830c), C(1ae3fc5b)},
	{C(3cc4693d6cbcb0c), C(501689ea1c70ffa), C(10a4353e9c89e364), C(58c8aba7475e2d95), C(3e2f291698c9427a), C(e8710d19c9de9e41), C(65dda22eb04cf953), C(459c3930)},
	{C(38908e43f7ba5ef0), C(1ab035d4e7781e76), C(41d133e8c0a68ff7), C(d1090893afaab8bc), C(96c4fe6922772807), C(4522426c2b4205eb), C(efad99a1262e7e0d), C(e00c4184)},
	{C(34983ccc6aa40205), C(21802cad34e72bc4), C(1943e8fb3c17bb8), C(fc947167f69c0da5), C(ae79cfdb91b6f6c1), C(7b251d04c26cbda3), C(128a33a79060d25e), C(ffc7a781)},
	{C(86215c45dcac9905), C(ea546afe851cae4b), C(d85b6457e489e374), C(b7609c8e70386d66), C(36e6ccc278d1636d), C(2f873307c08e6a1c), C(10f252a758505289), C(6a125480)},
	{C(420fc255c38db175), C(d503cd0f3c1208d1), C(d4684e74c825a0bc), C(4c10537443152f3d), C(720451d3c895e25d), C(aff60c4d11f513fd), C(881e8d6d2d5fb953), C(88a1512b)},
	{C(1d7a31f5bc8fe2f9), C(4763991092dcf836), C(ed695f55b97416f4), C(f265edb0c1c411d7), C(30e1e9ec5262b7e6), C(c2c3ba061ce7957a), C(d975f93b89a16409), C(549bbbe5)},
	{C(94129a84c376a26e), C(c245e859dc231933), C(1b8f74fecf917453), C(e9369d2e9007e74b), C(b1375915d1136052), C(926c2021fe1d2351), C(1d943addaaa2e7e6), C(c133d38c)},
	{C(1d3a9809dab05c8d), C(adddeb4f71c93e8), C(ef342eb36631edb), C(301d7a61c4b3dbca), C(861336c3f0552d61), C(12c6db947471300f), C(a679ef0ed761deb9), C(fcace348)},
	{C(90fa3ccbd60848da), C(dfa6e0595b569e11), C(e585d067a1f5135d), C(6cef866ec295abea), C(c486c0d9214beb2d), C(d6e490944d5fe100), C(59df3175d72c9f38), C(ed7b6f9a)},
	{C(2dbb4fc71b554514), C(9650e04b86be0f82), C(60f2304fba9274d3), C(fcfb9443e997cab), C(f13310d96dec2772), C(709cad2045251af2), C(afd0d30cc6376dad), C(6d907dda)},
	{C(b98bf4274d18374a), C(1b669fd4c7f9a19a), C(b1f5972b88ba2b7a), C(73119c99e6d508be), C(5d4036a187735385), C(8fa66e192fd83831), C(2abf64b6b592ed57), C(7a4d48d5)},
	{C(d6781d0b5e18eb68), C(b992913cae09b533), C(58f6021caaee3a40), C(aafcb77497b5a20b), C(411819e5e79b77a3), C(bd779579c51c77ce), C(58d11f5dcf5d075d), C(e686f3db)},
	{C(226651cf18f4884c), C(595052a874f0f51c), C(c9b75162b23bab42), C(3f44f873be4812ec), C(427662c1dbfaa7b2), C(a207ff9638fb6558), C(a738d919e45f550f), C(cce7c55)},
	{C(a734fb047d3162d6), C(e523170d240ba3a5), C(125a6972809730e8), C(d396a297799c24a1), C(8fee992e3069bad5), C(2e3a01b0697ccf57), C(ee9c7390bd901cfa), C(f58b96b)},
	{C(c6df6364a24f75a3), C(c294e2c84c4f5df8), C(a88df65c6a89313b), C(895fe8443183da74), C(c7f2f6f895a67334), C(a0d6b6a506691d31), C(24f51712b459a9f0), C(1bbf6f60)},
	{C(d8d1364c1fbcd10), C(2d7cc7f54832deaa), C(4e22c876a7c57625), C(a3d5d1137d30c4bd), C(1e7d706a49bdfb9e), C(c63282b20ad86db2), C(aec97fa07916bfd6), C(ce5e0cc2)},
	{C(aae06f9146db885f), C(3598736441e280d9), C(fba339b117083e55), C(b22bf08d9f8aecf7), C(c182730de337b922), C(2b9adc87a0450a46), C(192c29a9cfc00aad), C(584cfd6f)},
	{C(8955ef07631e3bcc), C(7d70965ea3926f83), C(39aed4134f8b2db6), C(882efc2561715a9c), C(ef8132a18a540221), C(b20a3c87a8c257c1), C(f541b8628fad6c23), C(8f9bbc33)},
	{C(ad611c609cfbe412), C(d3c00b18bf253877), C(90b2172e1f3d0bfd), C(371a98b2cb084883), C(33a2886ee9f00663), C(be9568818ed6e6bd), C(f244a0fa2673469a), C(d7640d95)},
	{C(d5339adc295d5d69), C(b633cc1dcb8b586a), C(ee84184cf5b1aeaf), C(89f3aab99afbd636), C(f420e004f8148b9a), C(6818073faa797c7c), C(dd3b4e21cbbf42ca), C(3d12a2b)},
	{C(40d0aeff521375a8), C(77ba1ad7ecebd506), C(547c6f1a7d9df427), C(21c2be098327f49b), C(7e035065ac7bbef5), C(6d7348e63023fb35), C(9d427dc1b67c3830), C(aaeafed0)},
	{C(8b2d54ae1a3df769), C(11e7adaee3216679), C(3483781efc563e03), C(9d097dd3152ab107), C(51e21d24126e8563), C(cba56cac884a1354), C(39abb1b595f0a977), C(95b9b814)},
	{C(99c175819b4eae28), C(932e8ff9f7a40043), C(ec78dcab07ca9f7c), C(c1a78b82ba815b74), C(458cbdfc82eb322a), C(17f4a192376ed8d7), C(6f9e92968bc8ccef), C(45fbe66e)},
	{C(2a418335779b82fc), C(af0295987849a76b), C(c12bc5ff0213f46e), C(5aeead8d6cb25bb9), C(739315f7743ec3ff), C(9ab48d27111d2dcc), C(5b87bd35a975929b), C(b4baa7a8)},
	{C(3b1fc6a3d279e67d), C(70ea1e49c226396), C(25505adcf104697c), C(ba1ffba29f0367aa), C(a20bec1dd15a8b6c), C(e9bf61d2dab0f774), C(f4f35bf5870a049c), C(83e962fe)},
	{C(d97eacdf10f1c3c9), C(b54f4654043a36e0), C(b128f6eb09d1234), C(d8ad7ec84a9c9aa2), C(e256cffed11f69e6), C(2cf65e4958ad5bda), C(cfbf9b03245989a7), C(aac3531c)},
	{C(293a5c1c4e203cd4), C(6b3329f1c130cefe), C(f2e32f8ec76aac91), C(361e0a62c8187bff), C(6089971bb84d7133), C(93df7741588dd50b), C(c2a9b6abcd1d80b1), C(2b1db7cc)},
	{C(4290e018ffaedde7), C(a14948545418eb5e), C(72d851b202284636), C(4ec02f3d2f2b23f2), C(ab3580708aa7c339), C(cdce066fbab3f65), C(d8ed3ecf3c7647b9), C(cf00cd31)},
	{C(f919a59cbde8bf2f), C(a56d04203b2dc5a5), C(38b06753ac871e48), C(c2c9fc637dbdfcfa), C(292ab8306d149d75), C(7f436b874b9ffc07), C(a5b56b0129218b80), C(7d3c43b8)},
	{C(1d70a3f5521d7fa4), C(fb97b3fdc5891965), C(299d49bbbe3535af), C(e1a8286a7d67946e), C(52bd956f047b298), C(cbd74332dd4204ac), C(12b5be7752721976), C(cbd5fac6)},
	{C(6af98d7b656d0d7c), C(d2e99ae96d6b5c0c), C(f63bd1603ef80627), C(bde51033ac0413f8), C(bc0272f691aec629), C(6204332651bebc44), C(1cbf00de026ea9bd), C(76d0fec4)},
	{C(395b7a8adb96ab75), C(582df7165b20f4a), C(e52bd30e9ff657f9), C(6c71064996cbec8b), C(352c535edeefcb89), C(ac7f0aba15cd5ecd), C(3aba1ca8353e5c60), C(405e3402)},
	{C(3822dd82c7df012f), C(b9029b40bd9f122b), C(fd25b988468266c4), C(43e47bd5bab1e0ef), C(4a71f363421f282f), C(880b2f32a2b4e289), C(1299d4eda9d3eadf), C(c732c481)},
	{C(79f7efe4a80b951a), C(dd3a3fddfc6c9c41), C(ab4c812f9e27aa40), C(832954ec9d0de333), C(94c390aa9bcb6b8a), C(f3b32afdc1f04f82), C(d229c3b72e4b9a74), C(a8d123c9)},
	{C(ae6e59f5f055921a), C(e9d9b7bf68e82), C(5ce4e4a5b269cc59), C(4960111789727567), C(149b8a37c7125ab6), C(78c7a13ab9749382), C(1c61131260ca151a), C(1e80ad7d)},
	{C(8959dbbf07387d36), C(b4658afce48ea35d), C(8f3f82437d8cb8d6), C(6566d74954986ba5), C(99d5235cc82519a7), C(257a23805c2d825), C(ad75ccb968e93403), C(52aeb863)},
	{C(4739613234278a49), C(99ea5bcd340bf663), C(258640912e712b12), C(c8a2827404991402), C(7ee5e78550f02675), C(2ec53952db5ac662), C(1526405a9df6794b), C(ef7c0c18)},
	{C(420e6c926bc54841), C(96dbbf6f4e7c75cd), C(d8d40fa70c3c67bb), C(3edbc10e4bfee91b), C(f0d681304c28ef68), C(77ea602029aaaf9c), C(90f070bd24c8483c), C(b6ad4b68)},
	{C(c8601bab561bc1b7), C(72b26272a0ff869a), C(56fdfc986d6bc3c4), C(83707730cad725d4), C(c9ca88c3a779674a), C(e1c696fbbd9aa933), C(723f3baab1c17a45), C(c1e46b17)},
	{C(b2d294931a0e20eb), C(284ffd9a0815bc38), C(1f8a103aac9bbe6), C(1ef8e98e1ea57269), C(5971116272f45a8b), C(187ad68ce95d8eac), C(e94e93ee4e8ecaa6), C(57b8df25)},
	{C(7966f53c37b6c6d7), C(8e6abcfb3aa2b88f), C(7f2e5e0724e5f345), C(3eeb60c3f5f8143d), C(a25aec05c422a24f), C(b026b03ad3cca4db), C(e6e030028cc02a02), C(e9fa36d6)},
	{C(be9bb0abd03b7368), C(13bca93a3031be55), C(e864f4f52b55b472), C(36a8d13a2cbb0939), C(254ac73907413230), C(73520d1522315a70), C(8c9fdb5cf1e1a507), C(8f8daefc)},
	{C(a08d128c5f1649be), C(a8166c3dbbe19aad), C(cb9f914f829ec62c), C(5b2b7ca856fad1c3), C(8093022d682e375d), C(ea5d163ba7ea231f), C(d6181d012c0de641), C(6e1bb7e)},
	{C(7c386f0ffe0465ac), C(530419c9d843dbf3), C(7450e3a4f72b8d8c), C(48b218e3b721810d), C(d3757ac8609bc7fc), C(111ba02a88aefc8), C(e86343137d3bfc2a), C(fd0076f0)},
	{C(bb362094e7ef4f8), C(ff3c2a48966f9725), C(55152803acd4a7fe), C(15747d8c505ffd00), C(438a15f391312cd6), C(e46ca62c26d821f5), C(be78d74c9f79cb44), C(899b17b6)},
	{C(cd80dea24321eea4), C(52b4fdc8130c2b15), C(f3ea100b154bfb82), C(d9ccef1d4be46988), C(5ede0c4e383a5e66), C(da69683716a54d1e), C(bfc3fdf02d242d24), C(e3e84e31)},
	{C(d599a04125372c3a), C(313136c56a56f363), C(1e993c3677625832), C(2870a99c76a587a4), C(99f74cc0b182dda4), C(8a5e895b2f0ca7b6), C(3d78882d5e0bb1dc), C(eef79b6b)},
	{C(dbbf541e9dfda0a), C(1479fceb6db4f844), C(31ab576b59062534), C(a3335c417687cf3a), C(92ff114ac45cda75), C(c3b8a627384f13b5), C(c4f25de33de8b3f7), C(868e3315)},
	{C(c2ee3288be4fe2bf), C(c65d2f5ddf32b92), C(af6ecdf121ba5485), C(c7cd48f7abf1fe59), C(ce600656ace6f53a), C(8a94a4381b108b34), C(f9d1276c64bf59fb), C(4639a426)},
	{C(d86603ced1ed4730), C(f9de718aaada7709), C(db8b9755194c6535), C(d803e1eead47604c), C(ad00f7611970a71b), C(bc50036b16ce71f5), C(afba96210a2ca7d6), C(f3213646)},
	{C(915263c671b28809), C(a815378e7ad762fd), C(abec6dc9b669f559), C(d17c928c5342477f), C(745130b795254ad5), C(8c5db926fe88f8ba), C(742a95c953e6d974), C(17f148e9)},
	{C(2b67cdd38c307a5e), C(cb1d45bb5c9fe1c), C(800baf2a02ec18ad), C(6531c1fe32bcb417), C(8c970d8df8cdbeb4), C(917ba5fc67e72b40), C(4b65e4e263e0a426), C(bfd94880)},
	{C(2d107419073b9cd0), C(a96db0740cef8f54), C(ec41ee91b3ecdc1b), C(ffe319654c8e7ebc), C(6a67b8f13ead5a72), C(6dd10a34f80d532f), C(6e9cfaece9fbca4), C(bb1fa7f3)},
	{C(f3e9487ec0e26dfc), C(1ab1f63224e837fa), C(119983bb5a8125d8), C(8950cfcf4bdf622c), C(8847dca82efeef2f), C(646b75b026708169), C(21cab4b1687bd8b), C(88816b1)},
	{C(1160987c8fe86f7d), C(879e6db1481eb91b), C(d7dcb802bfe6885d), C(14453b5cc3d82396), C(4ef700c33ed278bc), C(1639c72ffc00d12e), C(fb140ee6155f700d), C(5c2faeb3)},
	{C(eab8112c560b967b), C(97f550b58e89dbae), C(846ed506d304051f), C(276aa37744b5a028), C(8c10800ee90ea573), C(e6e57d2b33a1e0b7), C(91f83563cd3b9dda), C(51b5fc6f)},
	{C(1addcf0386d35351), C(b5f436561f8f1484), C(85d38e22181c9bb1), C(ff5c03f003c1fefe), C(e1098670afe7ff6), C(ea445030cf86de19), C(f155c68b5c2967f8), C(33d94752)},
	{C(d445ba84bf803e09), C(1216c2497038f804), C(2293216ea2237207), C(e2164451c651adfb), C(b2534e65477f9823), C(4d70691a69671e34), C(15be4963dbde8143), C(b0c92948)},
	{C(37235a096a8be435), C(d9b73130493589c2), C(3b1024f59378d3be), C(ad159f542d81f04e), C(49626a97a946096), C(d8d3998bf09fd304), C(d127a411eae69459), C(c7171590)},
	{C(763ad6ea2fe1c99d), C(cf7af5368ac1e26b), C(4d5e451b3bb8d3d4), C(3712eb913d04e2f2), C(2f9500d319c84d89), C(4ac6eb21a8cf06f9), C(7d1917afcde42744), C(240a67fb)},
	{C(ea627fc84cd1b857), C(85e372494520071f), C(69ec61800845780b), C(a3c1c5ca1b0367), C(eb6933997272bb3d), C(76a72cb62692a655), C(140bb5531edf756e), C(e1843cd5)},
	{C(1f2ffd79f2cdc0c8), C(726a1bc31b337aaa), C(678b7f275ef96434), C(5aa82bfaa99d3978), C(c18f96cade5ce18d), C(38404491f9e34c03), C(891fb8926ba0418c), C(fda1452b)},
	{C(39a9e146ec4b3210), C(f63f75802a78b1ac), C(e2e22539c94741c3), C(8b305d532e61226e), C(caeae80da2ea2e), C(88a6289a76ac684e), C(8ce5b5f9df1cbd85), C(a2cad330)},
	{C(74cba303e2dd9d6d), C(692699b83289fad1), C(dfb9aa7874678480), C(751390a8a5c41bdc), C(6ee5fbf87605d34), C(6ca73f610f3a8f7c), C(e898b3c996570ad), C(53467e16)},
	{C(4cbc2b73a43071e0), C(56c5db4c4ca4e0b7), C(1b275a162f46bd3d), C(b87a326e413604bf), C(d8f9a5fa214b03ab), C(8a8bb8265771cf88), C(a655319054f6e70f), C(da14a8d0)},
	{C(875638b9715d2221), C(d9ba0615c0c58740), C(616d4be2dfe825aa), C(5df25f13ea7bc284), C(165edfaafd2598fb), C(af7215c5c718c696), C(e9f2f9ca655e769), C(67333551)},
	{C(fb686b2782994a8d), C(edee60693756bb48), C(e6bc3cae0ded2ef5), C(58eb4d03b2c3ddf5), C(6d2542995f9189f1), C(c0beec58a5f5fea2), C(ed67436f42e2a78b), C(a0ebd66e)},
	{C(ab21d81a911e6723), C(4c31b07354852f59), C(835da384c9384744), C(7f759dddc6e8549a), C(616dd0ca022c8735), C(94717ad4bc15ceb3), C(f66c7be808ab36e), C(4b769593)},
	{C(33d013cc0cd46ecf), C(3de726423aea122c), C(116af51117fe21a9), C(f271ba474edc562d), C(e6596e67f9dd3ebd), C(c0a288edf808f383), C(b3def70681c6babc), C(6aa75624)},
	{C(8ca92c7cd39fae5d), C(317e620e1bf20f1), C(4f0b33bf2194b97f), C(45744afcf131dbee), C(97222392c2559350), C(498a19b280c6d6ed), C(83ac2c36acdb8d49), C(602a3f96)},
	{C(fdde3b03f018f43e), C(38f932946c78660), C(c84084ce946851ee), C(b6dd09ba7851c7af), C(570de4e1bb13b133), C(c4e784eb97211642), C(8285a7fcdcc7c58d), C(cd183c4d)},
	{C(9c8502050e9c9458), C(d6d2a1a69964beb9), C(1675766f480229b5), C(216e1d6c86cb524c), C(d01cf6fd4f4065c0), C(fffa4ec5b482ea0f), C(a0e20ee6a5404ac1), C(960a4d07)},
	{C(348176ca2fa2fdd2), C(3a89c514cc360c2d), C(9f90b8afb318d6d0), C(bceee07c11a9ac30), C(2e2d47dff8e77eb7), C(11a394cd7b6d614a), C(1d7c41d54e15cb4a), C(9ae998c4)},
	{C(4a3d3dfbbaea130b), C(4e221c920f61ed01), C(553fd6cd1304531f), C(bd2b31b5608143fe), C(ab717a10f2554853), C(293857f04d194d22), C(d51be8fa86f254f0), C(74e2179d)},
	{C(b371f768cdf4edb9), C(bdef2ace6d2de0f0), C(e05b4100f7f1baec), C(b9e0d415b4ebd534), C(c97c2a27efaa33d7), C(591cdb35f84ef9da), C(a57d02d0e8e3756c), C(ee9bae25)},
	{C(7a1d2e96934f61f), C(eb1760ae6af7d961), C(887eb0da063005df), C(2228d6725e31b8ab), C(9b98f7e4d0142e70), C(b6a8c2115b8e0fe7), C(b591e2f5ab9b94b1), C(b66edf10)},
	{C(8be53d466d4728f2), C(86a5ac8e0d416640), C(984aa464cdb5c8bb), C(87049e68f5d38e59), C(7d8ce44ec6bd7751), C(cc28d08ab414839c), C(6c8f0bd34fe843e3), C(d6209737)},
	{C(829677eb03abf042), C(43cad004b6bc2c0), C(f2f224756803971a), C(98d0dbf796480187), C(fbcb5f3e1bef5742), C(5af2a0463bf6e921), C(ad9555bf0120b3a3), C(b994a88)},
	{C(754435bae3496fc), C(5707fc006f094dcf), C(8951c86ab19d8e40), C(57c5208e8f021a77), C(f7653fbb69cd9276), C(a484410af21d75cb), C(f19b6844b3d627e8), C(a05d43c0)},
	{C(fda9877ea8e3805f), C(31e868b6ffd521b7), C(b08c90681fb6a0fd), C(68110a7f83f5d3ff), C(6d77e045901b85a8), C(84ef681113036d8b), C(3b9f8e3928f56160), C(c79f73a8)},
	{C(2e36f523ca8f5eb5), C(8b22932f89b27513), C(331cd6ecbfadc1bb), C(d1bfe4df12b04cbf), C(f58c17243fd63842), C(3a453cdba80a60af), C(5737b2ca7470ea95), C(a490aff5)},
	{C(21a378ef76828208), C(a5c13037fa841da2), C(506d22a53fbe9812), C(61c9c95d91017da5), C(16f7c83ba68f5279), C(9c0619b0808d05f7), C(83c117ce4e6b70a3), C(dfad65b4)},
	{C(ccdd5600054b16ca), C(f78846e84204cb7b), C(1f9faec82c24eac9), C(58634004c7b2d19a), C(24bb5f51ed3b9073), C(46409de018033d00), C(4a9805eed5ac802e), C(1d07dfb)},
	{C(7854468f4e0cabd0), C(3a3f6b4f098d0692), C(ae2423ec7799d30d), C(29c3529eb165eeba), C(443de3703b657c35), C(66acbce31ae1bc8d), C(1acc99effe1d547e), C(416df9a0)},
	{C(7f88db5346d8f997), C(88eac9aacc653798), C(68a4d0295f8eefa1), C(ae59ca86f4c3323d), C(25906c09906d5c4c), C(8dd2aa0c0a6584ae), C(232a7d96b38f40e9), C(1f8fb9cc)},
	{C(bb3fb5fb01d60fcf), C(1b7cc0847a215eb6), C(1246c994437990a1), C(d4edc954c07cd8f3), C(224f47e7c00a30ab), C(d5ad7ad7f41ef0c6), C(59e089281d869fd7), C(7abf48e3)},
	{C(2e783e1761acd84d), C(39158042bac975a0), C(1cd21c5a8071188d), C(b1b7ec44f9302176), C(5cb476450dc0c297), C(dc5ef652521ef6a2), C(3cc79a9e334e1f84), C(dea4e3dd)},
	{C(392058251cf22acc), C(944ec4475ead4620), C(b330a10b5cb94166), C(54bc9bee7cbe1767), C(485820bdbe442431), C(54d6120ea2972e90), C(f437a0341f29b72a), C(c6064f22)},
	{C(adf5c1e5d6419947), C(2a9747bc659d28aa), C(95c5b8cb1f5d62c), C(80973ea532b0f310), C(a471829aa9c17dd9), C(c2ff3479394804ab), C(6bf44f8606753636), C(743bed9c)},
	{C(6bc1db2c2bee5aba), C(e63b0ed635307398), C(7b2eca111f30dbbc), C(230d2b3e47f09830), C(ec8624a821c1caf4), C(ea6ec411cdbf1cb1), C(5f38ae82af364e27), C(fce254d5)},
	{C(b00f898229efa508), C(83b7590ad7f6985c), C(2780e70a0592e41d), C(7122413bdbc94035), C(e7f90fae33bf7763), C(4b6bd0fb30b12387), C(557359c0c44f48ca), C(e47ec9d1)},
	{C(b56eb769ce0d9a8c), C(ce196117bfbcaf04), C(b26c3c3797d66165), C(5ed12338f630ab76), C(fab19fcb319116d), C(167f5f42b521724b), C(c4aa56c409568d74), C(334a145c)},
	{C(70c0637675b94150), C(259e1669305b0a15), C(46e1dd9fd387a58d), C(fca4e5bc9292788e), C(cd509dc1facce41c), C(bbba575a59d82fe), C(4e2e71c15b45d4d3), C(adec1e3c)},
	{C(74c0b8a6821faafe), C(abac39d7491370e7), C(faf0b2a48a4e6aed), C(967e970df9673d2a), C(d465247cffa415c0), C(33a1df0ca1107722), C(49fc2a10adce4a32), C(f6a9fbf8)},
	{C(5fb5e48ac7b7fa4f), C(a96170f08f5acbc7), C(bbf5c63d4f52a1e5), C(6cc09e60700563e9), C(d18f23221e964791), C(ffc23eeef7af26eb), C(693a954a3622a315), C(5398210c)},
};

static const UInt64 stringTestdata[kStringTestSize][16] = {
{C(9ae16a3b2f90404f), C(75106db890237a4a), C(3feac5f636039766), C(3df09dfc64c09a2b), C(3cb540c392e51e29), C(6b56343feac0663), C(5b7bc50fd8e8ad92), C(dc56d17a)},
{C(dc1ece4bf56887b1), C(59e24bd4be7abc07), C(e1590f27894aebda), C(195d57ad2a55250b), C(6f499182e2ef4f18), C(fae128db684b23bf), C(94c1e304d3cac1ed), C(a3bcfea1)},
{C(248e2e6623b7e9a8), C(cbf9c6a8d73cef1), C(9713c5c0b7dc6e73), C(881142dd7747f654), C(52570474a49282c4), C(fd880db955022d70), C(e0f8ac5dca200291), C(d9ae6d32)},
{C(9236c57fd32f1f16), C(c2b174b65fb82353), C(9d4e74620e5b8c67), C(f29ef17d9acd6d48), C(7d6275f67ce494b3), C(36cfe9c85d07fb32), C(db198c413cc980ea), C(34b9b33d)},
{C(f948a1b18b43e56f), C(162a4f1ac66b96f1), C(1b87fd0d18a65ca2), C(b37f16d162479e30), C(82a9d1a208cd0563), C(4ed0a8145d6a0a58), C(1c230f1e7a642595), C(d868ce07)},
{C(3f1c7c2230aa8446), C(adb82a8ac5b2e565), C(c6de06b94803a3ac), C(a53f265759881ebc), C(56edf8d1d1150dcc), C(c11aa3d813b9ece2), C(22cbe1a8f0e1f99b), C(22573d2a)},
{C(4f97397913b351d), C(ca3f695387d63b27), C(e56b404625917d45), C(80a3972e9cbfad68), C(4507345ee821969d), C(fa84a6b0ef9d78b1), C(18fb7f9c0780b09b), C(95952b34)},
{C(4f28510a666a0aca), C(c0dfbe5b3c0e7abd), C(798150d4eb25d0e9), C(9ffb2036b56bc775), C(1ac126c6443c496), C(d3285a208dabec05), C(1897f48f9221c630), C(dc0e855f)},
{C(9fdadd4e06a0955), C(4f14d455698889b7), C(4a8e5b35579c8042), C(5a1803490c589877), C(17e90c28c73d19a0), C(831aaae40ba50fc2), C(d3721bbb361960f4), C(86deff04)},
{C(d63598df0cfebdef), C(6da4e5cc23f5bf57), C(abf274acd4587275), C(ab4890b5b9fde1b3), C(c0487a636bb15674), C(91e212e8ea806c93), C(e77c24b7815f56d4), C(1f2c3ce8)},
{C(80a381481b318818), C(2cda50ee12da9469), C(5bb6e7ce61e04b09), C(9a2d12fc02a43581), C(b5f5dc38ff2881), C(4a7453803548dc22), C(b10b48c6d0ad2a37), C(2646d918)},
{C(ba6ff67f03f6201c), C(6a2116d0406f8fcf), C(84aab94923d26a04), C(9c44769fe3d97e7d), C(290183d3767c25ed), C(d07336e0c4e8f710), C(3c525d0861723ca8), C(69eec083)},
{C(c1ef333e645831df), C(3ff011544a8f1c55), C(416bcd615088f584), C(30c5d16e6f12e295), C(d63fd3ce85ba24dd), C(49d327a3b88f34be), C(3f22d9119486b902), C(8e4cb277)},
{C(e99220e3fce5b8c4), C(cd6f4feae49b5652), C(9042683d70596c3d), C(f066aa11a46fbdac), C(b9a4e354f1364740), C(525f2ab9cdb5c443), C(740f5554493fc009), C(85bb7fad)},
{C(ee91a3553b15d628), C(1bfd2faa5cfe34bb), C(7727b1424bbf2f8e), C(492b29ef541cd8f3), C(ac3b3e72bb25d542), C(2b24e45f1a0b7fb), C(96d33c83b417de49), C(a41af7ad)},
{C(41c5b5d6d7c46b5d), C(97c46cbb4dd79568), C(4a0a943084fd4b03), C(17df58e766349209), C(83ae0357baf4d97f), C(666abfad711c20ab), C(4bc0fd49a7adeb60), C(a20b2c52)},
{C(1a121913d676e4a1), C(77d0653473641737), C(4591b9cba777fe07), C(6f9dee511c58b39f), C(6206ad87a767228c), C(b54e28f4a2c66333), C(1271700738e837d0), C(81355858)},
{C(4e5a5b8212c0f308), C(c383b3ec6f2d12d7), C(793de3195955f804), C(666c079181766f3e), C(5708d337897ef96e), C(1f0b7dd4ba4ee641), C(c04fc7a260a95bbc), C(3bf2ed90)},
{C(e48d7862edf3213c), C(b0868368221ae606), C(f804148ee3b35004), C(18abe87ff479c4bb), C(efcb09981ebaa5be), C(c3c82620dea02b02), C(fdc9f5648a4ba997), C(ae86509b)},
{C(d6af0dec128aa203), C(6504e75b813fc7f8), C(d58a979cabb027f1), C(d45f4ebe98c24833), C(6ea338210013a83), C(887402b6f042abe2), C(ad561e94f147bd2f), C(cc1018e2)},
{C(b556df411667af6f), C(77004c3c91741b24), C(79c3d46d94bc60e0), C(1d2c1ef3e5c40fae), C(2e9a7e16e815f212), C(6c4ae7f6c71748b9), C(f50b9f5b2e316a2f), C(2dda6c15)},
{C(e1d8a45d7638cc44), C(31390c2310c1754c), C(6ad20676358cf6c1), C(84284db46eb1ff60), C(31687d49fa91157), C(d48e23e66fc8194), C(e719f037d8a0f13d), C(ffdedb61)},
{C(674653079a5c8bcd), C(f693f22ca8be0393), C(aa41f2b40ca4bc23), C(b569db976150580b), C(508ee3727dcd4037), C(cb3ac21c3847244c), C(bdbd7db92f9dbf7e), C(d63f13b9)},
{C(15ac46044aca7094), C(1a21afb8e5be1bae), C(261b047c8e6f698a), C(acae0a799a551144), C(b24a247f8d04ec2f), C(40b8eed818f32766), C(94de678638052b8f), C(11c9ddd1)},
{C(940907d4280cde0e), C(b23014397e338849), C(2e9dfcccf6b20589), C(923977cdbcef9441), C(281b48d20a5c2099), C(4f89a96503a57766), C(779018d11f71158b), C(c79f92d0)},
{C(66d0a914a58c5263), C(1b1e167795099ab5), C(b1df1727fe6c61ed), C(560fdfacefb62243), C(17481f2d7dc05185), C(9e7d3df586e25789), C(ccc947bb31a0d088), C(8f5ad2df)},
{C(44cc3d58814c79bf), C(51232acf52d7d9e9), C(db86e283899aacf9), C(8a430cd704df7c5d), C(df94527701a6b2fe), C(1b518055c3740b4), C(a4ee376661075f24), C(2d6a04e3)},
{C(75e58976b937d0ed), C(c84aacf8f2aa716d), C(3451b0507aebd392), C(22008a22bc2fa942), C(2d51eb11829db1cd), C(92782833a90deeeb), C(ed639bb7233ccaec), C(cab2bbc0)},
{C(72913a6aec1ba7b1), C(2f9516a64388af8a), C(6466707ddb2af8bc), C(f3ce73b8e9989643), C(e75dd1ad0032c446), C(188496dc6500c1a0), C(f726eb969a19469), C(265a6fd6)},
{C(18399f8e8698272d), C(6b72274d8d725092), C(4bdb3ac01b98fa42), C(95f8c6e5ca3ece06), C(219c582ce2ff159b), C(98f00b39421cc31), C(dc78318d4f367e57), C(79a1cfce)},
{C(7df70023b3cd6e9a), C(d15ba1a6db9d88c3), C(eb3f754c70216f9), C(4e47519c6f08d939), C(36b3ded635a0495b), C(da75f5910376436a), C(74d5edb67b27cf27), C(522e17f5)},
{C(9a17b35824b5bf10), C(80ce859034a09ed4), C(26d2413b981be3c6), C(8183f32fe46121fc), C(2059fc14192263ea), C(ef9a16a18b7e2007), C(e17a9f8f7347ce21), C(39d70a20)},
{C(5b09440af835551a), C(970f7da6fe7ad832), C(4e8a256a514c59ab), C(191e84e4e7bed5c4), C(2946f847cded958d), C(480f4b1226071f18), C(6707f0e5d55b883a), C(6c46c97f)},
{C(c59541af005bbca8), C(297f3df4b52c02c0), C(75b80b709ac31c19), C(b3bb01cc5ed2347a), C(de207e5e54368480), C(d7333344c2c8ff9e), C(4d510fc12c5ee745), C(aeb36a1)},
{C(493bbc7df7a0c9ec), C(4dd8ad1715977bad), C(d6f2ce12c6486e96), C(91fd5baab13c506d), C(f76e3786cc956952), C(4f5cae3394f55862), C(7767ffaeccd5918d), C(30f4837d)},
{C(51214d32ee1a504d), C(e3c0c08967aaf49), C(bb33830596ca09d0), C(5ddb1db38cef7fc1), C(b7f6bfe93ad7c793), C(9f7990825083379e), C(f9eff1b9815f3573), C(ff0e03ed)},
{C(18e75353f5f2394b), C(57c413463908d7f1), C(e183cc8631a5ce41), C(348314a3367c6311), C(82ce5a540efe1449), C(203388b7cbd1beb9), C(4106206d0756d1d0), C(5ba13d87)},
{C(d042d9c14726ec8c), C(659b28c87b88831b), C(f9e90b7f77d696de), C(ffa68f56df7e4560), C(16268f4e128f46c8), C(2be942d225fa2742), C(77e1bf469324350f), C(93783246)},
{C(f816560fabc2ff49), C(6ddb058b426b8428), C(fae10514a4eaecf4), C(7fa5b51bbb21a105), C(28be77e7f13b8fbe), C(929507b75e298e19), C(28e464c06b4e1ef8), C(8b7c17b8)},
{C(e5efa0942e39eb05), C(5f33f745afefef1), C(bc85f27484f7c9cc), C(a9c282e2c281d34c), C(94d4c856cb0b5d95), C(f0b07a29c3f0b7b7), C(1aeba7de51f63fea), C(fa364290)},
{C(6ab9b737d16e250f), C(ad16908447b527d9), C(6b8f5da30303956c), C(40f15ba721702e95), C(568780691826b279), C(f70abfd2c4ad7035), C(2b4862c981fcf5e2), C(436c44a1)},
{C(16674966167a77d6), C(eed34f447b7fa403), C(f824b8f7be0e4d8b), C(c02353e3423b0604), C(ff6de60dae21515b), C(1c1a6cc020a096d8), C(f56bee82bf711738), C(ca748a40)},
{C(7bb626e7c0e29be6), C(64c562b823d62646), C(d83119d261c6dd97), C(5cbbaaee911cf330), C(d4e3e4d664a81959), C(52fafc94fd56f45c), C(abf886028b5517ac), C(d3631fab)},
{C(22d2e4aeb366c11d), C(6018b0bae8a31ec1), C(ae6179c047cdd30c), C(67cd2117eb46ab9f), C(da1e709d65b296cf), C(99b633eaadf391b3), C(1b5bcca980b210a), C(902d0855)},
{C(1b8bb3f8b007aba2), C(20fdceffc82194aa), C(f8e1d7887200e4d8), C(5f4c153aff2d5822), C(824eadb80354750c), C(ddf0a096811c248c), C(78dfc0b1cde05dc), C(ac7406d1)},
{C(ade962d1e51ce942), C(dce4f971072b59ba), C(b247bfcdc01df497), C(1633008e41472d0e), C(a4c3b58839846749), C(17a1fc9380d04f27), C(565016cc3a3c1cc8), C(5aea0408)},
{C(202fe7fee4e140ad), C(83d630e4e312a35c), C(8d07d68cf299acf1), C(c19ce61105152538), C(be68860ff4840e73), C(5ab6cf55dc7bde26), C(135a8c6d13deef31), C(af256522)},
{C(43b7e8e990dd63ef), C(26d2ef5e4dcfee85), C(efebed4476e8b50f), C(85776e8c369eea3d), C(11175c7565bdae53), C(4c6cc0d426acc12), C(252c4954d74c06b7), C(64f07140)},
};

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define TEST_STRING(text) @ STRINGIZE2(text)

static NSString* testString =
TEST_STRING
(
 Photo booth Schlitz biodiesel ugh ut dolore four loko vero umami swag. Brunch distillery Marfa tattooed kale chips cred normcore anim XOXO. Retro beard raw denim biodiesel cornhole Truffaut meggings 3 wolf moon Neutra Helvetica. Selfies brunch tempor four loko. Umami fixie Helvetica ennui ex twee cornhole Cosby sweater organic DIY mixtape biodiesel pickled normcore paleo. Ad ugh accusamus selfies. Banh mi Marfa Truffaut iPhone culpa Tonx next level vinyl street art Pitchfork polaroid.

 Art party dolore viral PBR&B crucifix locavore cupidatat biodiesel church-key street art photo booth YOLO farm-to-table. Gluten-free esse you probably havent heard of them forage try-hard actually. Pitchfork single-origin coffee fanny pack Helvetica Cosby sweater fingerstache 3 wolf moon roof party elit eiusmod retro odio. Chia mlkshk et roof party ennui placeat bicycle rights Portland Neutra. Twee you probably havent heard of them est assumenda mumblecore yr consectetur pug sapiente cray tousled minim skateboard ethnic. Normcore tempor dolor Pinterest slow-carb sartorial Marfa crucifix flexitarian. Gluten-free est pour-over messenger bag proident biodiesel kale chips banh mi butcher.

 Semiotics in laborum actually Tumblr ullamco freegan aliquip flexitarian you probably havent heard of them sriracha Austin. Brunch organic messenger bag non. Hella flexitarian retro art party eiusmod pour-over PBR&B swag literally labore quis sapiente wayfarers nihil. 90s locavore VHS reprehenderit organic Schlitz dreamcatcher ad ugh irony narwhal Wes Anderson typewriter semiotics. Semiotics messenger bag flannel Vice wayfarers ut eiusmod keffiyeh sint Kickstarter velit meh cornhole. Small batch occaecat voluptate pickled Godard nulla sunt est Odd Future anim McSweeneys. Readymade scenester sustainable synth fixie fingerstache fap.

 Intelligentsia wayfarers distillery meggings asymmetrical. Swag quinoa Portland reprehenderit crucifix cliche aliqua. VHS squid sustainable wolf. Vegan typewriter ennui hashtag reprehenderit DIY Tumblr magna synth adipisicing Schlitz banh mi keytar letterpress. Seitan church-key gluten-free cliche flexitarian in ugh esse bespoke vegan dolore letterpress typewriter. Commodo sed keytar delectus biodiesel Odd Future hashtag cupidatat sapiente. Qui salvia High Life Brooklyn 90s kale chips.
 );

