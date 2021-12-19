import 'dart:typed_data';

import 'package:kong_land/kongland/util.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import 'info_record.dart';
import 'input_record.dart';
import 'output_record.dart';

class OP {
  static Uint8List getTag = Uint8List.fromList([0x3a, 0x11, 0x15]);
  static Uint8List getKeys = Uint8List.fromList([0x3a, 0x15, 0x42]);
}

Map<String, Uint8List> op = {
  'getTag': Uint8List.fromList([0x3a, 0x11, 0x15]),
  'getKeys': Uint8List.fromList([0x3a, 0x15, 0x42]),
};
NfcA nfcaFromTag(NfcTag tag) => NfcA(
      tag: tag,
      identifier: tag.data['nfca']['identifier'],
      atqa: tag.data['nfca']['atqa'],
      sak: tag.data['nfca']['sak'],
      maxTransceiveLength: tag.data['nfca']['maxTransceiveLength'],
      timeout: tag.data['nfca']['timeout'],
    );

class SiLoTag {
  final NfcTag tag;
  final NfcA nfcA;
  final InfoRecord infoRecord;
  final InputRecord inputRecord;
  final OutputRecord outputRecord;
  late bool isValidTag;
  late Uint8List configRegister;

  factory SiLoTag.fromTag(NfcTag tag) {
    Map<String, dynamic> data = tag.data;
    Map<String, dynamic> nfca = Map<String, dynamic>.from(data['nfca']);
    Map<String, dynamic> ndef = Map<String, dynamic>.from(data['ndef']);
    Map<String, dynamic> mifareultralight =
        Map<String, dynamic>.from(data['mifareultralight']);

    var records = ndef['cachedMessage']['records'];
    List<NdefRecord> cachedRecords = [];

    records.forEach((record) {
      cachedRecords.add(
        NdefRecord(
            typeNameFormat:
                NdefTypeNameFormat.values.elementAt(record['typeNameFormat']),
            type: record['type'],
            identifier: record['identifier'],
            payload: record['payload']),
      );
    });

    return SiLoTag(
      tag: tag,
      nfcA: nfcaFromTag(tag),
      inputRecord: InputRecord.fromBytes(cachedRecords[5].payload),
      infoRecord: InfoRecord.fromBytes(cachedRecords[3].payload),
      outputRecord: OutputRecord.fromBytes(cachedRecords[4].payload),
    );
  }

  SiLoTag({
    required this.tag,
    required this.nfcA,
    required this.infoRecord,
    required this.inputRecord,
    required this.outputRecord,
  });

  Future<bool> validTag() async {
    Uint8List resp = await nfcA.transceive(data: OP.getTag);
    Uint8List check =
        Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3]);
    return bytesToHex(check) == bytesToHex(resp.sublist(2, resp.length - 2));
  }

  Future<Uint8List> getConfigRegister() async =>
      await nfcA.transceive(data: Uint8List.fromList([0x30, 0xe8]));

  Future<Uint8List> getKeys() async =>
      await nfcA.transceive(data: Uint8List.fromList([0x3a, 0x15, 0x42]));
}
