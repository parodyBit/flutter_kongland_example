




import 'dart:typed_data';

import 'package:pointycastle/api.dart';

final sha256 = Digest("SHA-256");



String bytesToHex(Uint8List bytes) {
  return bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join()
      .toLowerCase();
}

BigInt hexToBigInt(String hex) {
  return BigInt.parse(hex, radix: 16);
}