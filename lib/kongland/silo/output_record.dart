import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../util.dart';

class OutputRecord {
  final Uint8List commandCode;
  final Uint8List externalRandomNumber;
  final Uint8List blockHash;
  final Uint8List combinedHash;
  final Uint8List internalRandomNumber;
  final Uint8List externalSignature;
  final Uint8List internalSignature;

  OutputRecord({
    required this.commandCode,
    required this.externalRandomNumber,
    required this.blockHash,
    required this.combinedHash,
    required this.internalRandomNumber,
    required this.externalSignature,
    required this.internalSignature,
  });
  factory OutputRecord.fromBytes(Uint8List data){
    return OutputRecord(
        commandCode: data.sublist(0,1),
        externalRandomNumber: data.sublist(1,33),
        blockHash: data.sublist(33,65),
        combinedHash: data.sublist(65,97),
        internalRandomNumber: data.sublist(97,129),
        externalSignature: data.sublist(129,193),
        internalSignature: data.sublist(193,257)
    );
  }
  void printDebug(){
    print('Output Record:');
    print('commandCode: ${bytesToHex(commandCode)}');
    print('externalRandomNumber: ${bytesToHex(externalRandomNumber)}');
    print('blockHash: ${bytesToHex(blockHash)}');
    print('combinedHash: ${bytesToHex(combinedHash)}');
    print('internalRandomNumber: ${bytesToHex(internalRandomNumber)}');
    print('externalSignature: ${bytesToHex(externalSignature)}');
    print('internalSignature: ${bytesToHex(internalSignature)}');
  }
}