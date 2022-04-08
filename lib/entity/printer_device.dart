class PrinterDevice {
  PrinterDevice({this.name, this.address});

  final String? name;
  final String? address;

  factory PrinterDevice.fromJson(Map<String, dynamic> json) {
    return PrinterDevice(
      name: json['PrinterName'],
      address: json['Target'],
    );
  }
}
