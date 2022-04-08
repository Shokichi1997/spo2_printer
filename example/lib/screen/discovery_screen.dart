import 'dart:async';

import 'package:epos2_printer/entity/printer_device.dart';
import 'package:epos2_printer/epos2_printer.dart';
import 'package:flutter/material.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({Key? key, required this.onSelectedPrinter}) : super(key: key);

  final void Function(String? target) onSelectedPrinter;

  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  var devices = <PrinterDevice>[];
  StreamSubscription<List<PrinterDevice>>? subscriptionPrinterDevice;

  @override
  void initState() {
    getDevices();
    super.initState();
    getDevices();
  }

  @override
  void dispose() {
    super.dispose();
    subscriptionPrinterDevice?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find printer'),
      ),
      body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                widget.onSelectedPrinter(devices[index].address);
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                    Icon(Icons.print, color: Colors.blue, size: 24.0),
                    SizedBox(width: 12.0),
                    // Text(devices[index][]),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void getDevices() {
    subscriptionPrinterDevice?.cancel();
    subscriptionPrinterDevice = Epos2Printer.getPrinters().listen((list) {
      if (mounted) {
        setState(() {
          devices = list;
        });
      }
    });
  }
}
