
import 'dart:typed_data';

import 'package:kong_land/crypto/secp256r1/secp256r1.dart';
import 'package:kong_land/kongland/util.dart';

class SiLoPublicKey {

  final BigInt X;
  final BigInt Y;

  SiLoPublicKey({
    required this.X,
    required this.Y,
  });

  factory SiLoPublicKey.decode(Uint8List data){
    List<int> key = data.toList();
    if (key.first == 0x04) {
      // uncompressed key
      assert(key.length == 65, 'An uncompressed key must be 65 bytes long');
      final point = hexToPoint(bytesToHex(data));

      return SiLoPublicKey(X: point[0], Y: point[1]);
    } else {
      // compressed key
      assert(key.length == 33, 'A compressed public key must be 33 bytes');
      final point = hexToPointFromCompress(bytesToHex(data));
      return SiLoPublicKey(X: point[0], Y: point[1]);
    }
  }

}
