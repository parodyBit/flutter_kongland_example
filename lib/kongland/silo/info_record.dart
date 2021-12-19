
import 'dart:typed_data';

import '../util.dart';

class InfoRecord {
  final Uint8List primaryPublicKey;
  final Uint8List secondaryPublicKey;
  final Uint8List hardwareSerial;

  InfoRecord({
    required this.primaryPublicKey,
    required this.secondaryPublicKey,
    required this.hardwareSerial
  });
  factory InfoRecord.fromBytes(Uint8List data){

    return InfoRecord(
      primaryPublicKey: data.sublist(16,80),
      secondaryPublicKey: data.sublist(80,144),
      hardwareSerial: data.sublist(187,196),
    );
  }
}