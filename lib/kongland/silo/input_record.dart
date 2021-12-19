import 'dart:typed_data';

import '../util.dart';

class InputRecord {
  final Uint8List commandCode;
  final Uint8List externalRandomNumber;
  final Uint8List blockHash;
  final Uint8List combinedHash;

  InputRecord({
    required this.commandCode,
    required this.externalRandomNumber,
    required this.blockHash,
    required this.combinedHash,
  });

  factory InputRecord.fromBytes(Uint8List data){
    return InputRecord(
      commandCode: data.sublist(0,1),
      externalRandomNumber: data.sublist(1,33),
      blockHash: data.sublist(33,65),
      combinedHash: data.sublist(65,97),
    );
  }

  void printDebug(){
    print('Input Record');
    print('commandCode: ${bytesToHex(commandCode)}');
    print('externalRandomNumber: ${bytesToHex(externalRandomNumber)}');
    print('blockHash: ${bytesToHex(blockHash)}');
    print('combinedHash: ${bytesToHex(combinedHash)}');
  }
}