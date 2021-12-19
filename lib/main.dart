import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kong_land/kongland/silo/silo_tag.dart';
import 'package:kong_land/kongland/util.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  late SiLoTag siLoTag;

  @override
  void initState() {
    _tagRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Kong Land')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, asyncSnapshot) => asyncSnapshot.data != true
                ? Center(child: Text('NfcManager.isAvailable(): ${asyncSnapshot.data}'))
                : Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
              children: [
                  Flexible(
                  flex: 3,
                  child: GridView.count(
                    padding: EdgeInsets.all(4),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      ElevatedButton(
                          child: Text('Tag Read'), onPressed: _tagRead),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {

    siLoTag = SiLoTag.fromTag(tag);
    bool valid = await siLoTag.validTag();
    print('Valid Tag: $valid');
    NfcManager.instance.stopSession();
    },pollingOptions: NfcPollingOption.values.toSet());
  }

}
