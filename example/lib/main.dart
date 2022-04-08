import 'package:epos2_printer/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:epos2_printer/epos2_printer.dart';

import 'screen/discovery_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TM-m30 example app'),
        ),
        body: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController targetController;
  String? target;

  @override
  void initState() {
    super.initState();
    targetController = TextEditingController();
  }

  @override
  void dispose() {
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DiscoveryScreen(
                    onSelectedPrinter: (String? target) {
                      this.target = target;
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 22.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Center(
                child: Text(
                  'Discovery',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Target',
            style: TextStyle(color: Colors.black, fontSize: 18.0),
          ),
          const SizedBox(height: 12.0),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                controller: targetController,
              ),
            ),
          ),
          const SizedBox(height: 28.0),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(),
            ),
            child: Column(
              children: [
                getGroupButton(
                    label1: 'Connect',
                    onTap1: () => handleButton(() => Epos2Printer.connectPrinter(target)),
                    label2: 'Disconnect',
                    onTap2: () => handleButton(() => Epos2Printer.disconnect())),
                getGroupButton(
                    label1: 'Add text',
                    onTap1: () => handleButton(() => Epos2Printer.addText('Sample text')),
                    label2: 'Add Image',
                    onTap2: () => handleButton(() => Epos2Printer.addImage('assets/images/logo.png'))),
                getGroupButton(
                    label1: 'Add line space',
                    onTap1: () => handleButton(() => Epos2Printer.addLineSpace(1)),
                    label2: 'Add feed line',
                    onTap2: () => handleButton(() => Epos2Printer.addFeedLine(1))),
                getGroupButton(
                    label1: 'Add text size',
                    onTap1: () => handleButton(() => Epos2Printer.addTextSize(width: 2, height: 2)),
                    label2: 'Add text align',
                    onTap2: () => handleButton(() => Epos2Printer.addTextAlign(PosAlign.ALIGN_RIGHT))),
                getGroupButton(
                    label1: 'Add text font',
                    onTap1: () => handleButton(() => Epos2Printer.addTextFont(PosFont.FONT_B)),
                    label2: 'Print recieve',
                    onTap2: () => handleButton(() => Epos2Printer.printData())),
                getGroupButton(
                    label1: 'Test Plugin',
                    onTap1: () => handleButton(() => Epos2Printer.testPlugin()),
                    label2: 'Print recieve',
                    onTap2: () => handleButton(() => Epos2Printer.printData())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleButton(Future<void> Function() param) async {
    param.call();
    return;
    if (target != null && await Epos2Printer.isConnected()) {
      param.call();
    } else {
      showDialog(context, 'Please connect to printer first');
    }
  }

  Widget getGroupButton({required String label1, required String label2, VoidCallback? onTap1, VoidCallback? onTap2}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: getButton(label: label1, onTap: onTap1)),
          const SizedBox(width: 24.0),
          Expanded(child: getButton(label: label2, onTap: onTap2)),
        ],
      ),
    );
  }

  Widget getButton({required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      ),
    );
  }

  void showDialog(BuildContext context, String message) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
