import 'package:kong_land/kongland/util.dart';

import '../number_theory.dart';

var secp256r1 = Curve(secp256r1Params);

const secp256r1Params = {
  'p': 'FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF',
  'a': 'FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC',
  'b': '5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B',
  'Gx': '6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296',
  'Gy': '4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5',
  'n': 'FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551',
  'h': '01',
};

// The curve equation for secp256r1 is: y^2 = x^3 + ax + b.
class Curve {
  late BigInt p;
  late BigInt a;
  late BigInt b;
  late BigInt n;
  late BigInt h;

  late List<BigInt> G;

  Curve(Map params) {
    p = BigInt.parse(params['p'], radix: 16);
    a = BigInt.parse(params['a'], radix: 16);
    b = BigInt.parse(params['b'], radix: 16);
    n = BigInt.parse(params['n'], radix: 16);
    h = BigInt.parse(params['h'], radix: 16);
    G = [
      BigInt.parse(secp256r1Params['Gx']!, radix: 16),
      BigInt.parse(secp256r1Params['Gy']!, radix: 16)
    ];
  }
}


List<BigInt> bigIntToPoint(BigInt n) {
  return hexToPoint(n.toRadixString(16));
}

List<BigInt> hexToPoint(String hex) {
  final len = 130;
  if (hex.length != len) {
    throw ('point length must be $len!');
  }

  if (hex.substring(0, 2) != '04') {
    throw ('point prefix incorrect!');
  }

  return [
    BigInt.parse(hex.substring(2, 66), radix: 16),
    BigInt.parse(hex.substring(66, 130), radix: 16),
  ];
}

List<BigInt> addSamePoint(BigInt x1, BigInt y1, BigInt modNum, BigInt a) {
  var ru = positiveMod(
      (BigInt.from(3) * x1.pow(2) + a) * inverseMulti(BigInt.two * y1, modNum),
      modNum);
  var x3 = positiveMod(ru.pow(2) - (BigInt.two * x1), modNum);
  var y3 = positiveMod(ru * (x1 - x3) - y1, modNum);
  return [x3, y3];
}

List<BigInt> addDiffPoint(
    BigInt x1, BigInt y1, BigInt x2, BigInt y2, BigInt modNum) {
  var ru = positiveMod((y2 - y1) * inverseMulti(x2 - x1, modNum), modNum);
  var x3 = positiveMod(ru.pow(2) - x1 - x2, modNum);
  var y3 = positiveMod(ru * (x1 - x3) - y1, modNum);
  return [x3, y3];
}

List<BigInt> getPointByBigInt(
    BigInt n, BigInt p, BigInt a, List<BigInt> pointG) {
  var bin = n.toRadixString(2);
  var nextPoint = pointG;
  List<BigInt>? nowPoint;
  for (var i = bin.length - 1; i >= 0; i--) {
    if (bin[i] == '1') {
      if (nowPoint == null) {
        nowPoint = nextPoint;
      } else {
        nowPoint = addDiffPoint(
            nowPoint[0], nowPoint[1], nextPoint[0], nextPoint[1], p);
      }
    }

    nextPoint = addSamePoint(nextPoint[0], nextPoint[1], p, a);
  }

  return nowPoint!;
}

List<BigInt> hexToPointFromCompress(String hex) {
  final len = 66;
  if (hex.length != len) {
    throw ('point length must be $len!');
  }

  var firstByte = int.parse(hex.substring(0, 2), radix: 16);

  if ((firstByte & ~1) != 2) {
    throw ('point prefix incorrect!');
  }


  var x = BigInt.parse(hex.substring(2, 66), radix: 16);

  var ySqared =
      ((x.modPow(BigInt.from(3), secp256r1.p)) + hexToBigInt(secp256r1Params['b'] as String)) % secp256r1.p;

  // power = (p+1) // 4
  var p1 = secp256r1.p + BigInt.from(1); // p+1
  var power = (p1 - p1 % BigInt.from(4)) ~/ BigInt.from(4);
  var y = ySqared.modPow(power, secp256r1.p);

  var sq = y.pow(2) % secp256r1.p;
  if (sq != ySqared) {
    throw ('failed to retrieve y of public key from hex');
  }

  var firstBit = (y & BigInt.one).toInt();
  if (firstBit != (firstByte & 1)) {
    y = secp256r1.p - y;
  }

  return [x, y];
}

String pointToHexInCompress(List<BigInt> point) {
  // var byteLen = 32; //(256 + 7) >> 3 //  => so len of str is (32+1) * 2 = 66;
  var firstBit = 2 + (point[1] & BigInt.one).toInt();
  var prefix = firstBit.toRadixString(16).padLeft(2, '0');

  return prefix + point[0].toRadixString(16).padLeft(64, '0');
}