import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'dart:math';
import 'package:intl/intl.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:http/http.dart' as http;
import 'homePage.dart';


class PrinterPage extends StatefulWidget {
  final List<Item> selectedItems;
  final String subTotal;
  final String customerName;
  final Map<String, int> availableQuantities;
  PrinterPage({super.key, required this.selectedItems, required this.subTotal, required this.customerName, required this.availableQuantities, });

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = '';


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected=await bluetoothPrint.isConnected??false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }


  String generatedReceiptId() {
    final random = Random();
    int min = 0; // Smallest 5-digit number
    int max = 99999; // Largest 5-digit number
    int randomNumber = min + random.nextInt(max - min + 1);
    return randomNumber.toString().padLeft(5, '0');
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

  String getCurrentMonth() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM').format(now);
    return formattedDate;
  }

  String getCurrentTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('HH:mm:ss').format(now);
    return formattedDate;
  }

  String generateReceiptString(List<Item> selectedItems, String subTotal) {
    StringBuffer receiptBuffer = StringBuffer();
    receiptBuffer.writeln("Receipt Details");
    receiptBuffer.writeln("----------------------------");

    for (Item item in selectedItems) {
      receiptBuffer.writeln(item.name);
      receiptBuffer.writeln("Price: ${item.price} | Quantity: ${item.quantity} | Total: ${item.total}");
      receiptBuffer.writeln("----------------------------");
    }

    receiptBuffer.writeln("Sub Total: $subTotal");
    receiptBuffer.writeln("----------------------------");

    return receiptBuffer.toString();
  }

  Future<void> updateAvailableQuantities(Map<String, int> updatedQuantities) async {
    try {
      var url = "http://dev.workspace.cbs.lk/updateAvailableQuantity.php";

      var data = {
        "quantities": updatedQuantities,
      };

      http.Response res = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      print("Response Code: ${res.statusCode}");
      print("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        if (jsonDecode(res.body) == "true") {
          print("Available quantities updated successfully");
        }
      } else {
        print("Failed to connect to the server. Status Code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }



  Future<void> addSale(BuildContext context,{
    required billNo,
    required customer,
    required cashier,
    required billDetails,
    required subTotal,
  }) async {

    var url = "http://dev.workspace.cbs.lk/addSale.php";

    var data = {
      "bill_no": billNo,
      "customer_": customer,
      "date_time": getCurrentTime(),
      "bill_date": getCurrentDate(),
      "bill_month": getCurrentMonth(),
      "cashier_": cashier,
      "bill_details": billDetails,
      "sub_total": subTotal,
      "status_":'1',
    };

    http.Response res = await http.post(
      Uri.parse(url),
      body: data,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );

    if (res.statusCode.toString() == "200") {
      if (jsonDecode(res.body) == "true") {
        if (!mounted) return;
        showPrintedSuccessfullyDialog(context);


      } else {
        if (!mounted) return;
        snackBar(context, "Error", Colors.red);
      }
    } else {
      if (!mounted) return;
      snackBar(context, "Error", Colors.redAccent);
    }
  }

  Future<void> snackBar( BuildContext context, String message, Color color) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: color, fontSize: 17.0),
      ),
    ));
  }

  Future<void> showPrintedSuccessfullyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Printed Successfully'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sale recoded Successfully!!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                // Close the dialog
              },
            ),
            TextButton(
              child: Text('Print Seller Copy'),
              onPressed: _connected?() async {
                print(generatedReceiptId());
                Map<String, dynamic> config = Map();

                List<LineText> list = [];


                list.add(LineText(type: LineText.TYPE_TEXT, content: "Seller Copy", weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Receipt No:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: generatedReceiptId(), weight: 1, align: LineText.ALIGN_LEFT, x: 140, relativeX: 0, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Customer:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: widget.customerName, weight: 1, align: LineText.ALIGN_LEFT, x: 130, relativeX: 0, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cashier:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: "DinethriG", weight: 1, align: LineText.ALIGN_LEFT, x: 110, relativeX: 0, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: getCurrentDateTime(), weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Payment Type:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: "Cash", weight: 1, align: LineText.ALIGN_LEFT, x: 165, relativeX: 0, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));

                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Item Price', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Qty', weight: 1, align: LineText.ALIGN_LEFT, x: 155, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: "Total(Rs)", weight: 1, align: LineText.ALIGN_LEFT, x: 255, relativeX: 0, linefeed: 1));
                list.add(LineText(linefeed: 1));

                // Add items to the receipt
                for (Item item in widget.selectedItems) {
                  list.add(LineText(
                    type: LineText.TYPE_TEXT,
                    content: ' ${item.name}',
                    weight: 1,
                    align: LineText.ALIGN_LEFT,
                    x: 0,
                    relativeX: 0,
                    linefeed: 1, ));
                  list.add(LineText(
                      type: LineText.TYPE_TEXT,
                      content: item.price.toStringAsFixed(2),
                      weight: 1,
                      align: LineText.ALIGN_LEFT,
                      x: 5,
                      relativeX: 0,
                      linefeed: 0));
                  list.add(LineText(
                      type: LineText.TYPE_TEXT,
                      content: item.quantity.toString(),
                      weight: 1,
                      align: LineText.ALIGN_LEFT,
                      x: 160,
                      relativeX: 0,
                      linefeed: 0));
                  list.add(LineText(
                      type: LineText.TYPE_TEXT,
                      content: item.total.toStringAsFixed(2),
                      weight: 1,
                      align: LineText.ALIGN_LEFT,
                      x: 260,
                      relativeX: 0,
                      linefeed: 1));
                }

                list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Sub Total', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT, content: widget.subTotal, weight: 1, align: LineText.ALIGN_LEFT, x: 255, relativeX: 0, linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                list.add(LineText(type: LineText.TYPE_TEXT, content: 'Thank You!!', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                // list.add(LineText(type: LineText.TYPE_TEXT, content: 'Develop by: Digital Business Lab', weight: 1, align: LineText.ALIGN_CENTER,fontZoom: 1, linefeed: 1));
                list.add(LineText(linefeed: 1));

                await bluetoothPrint.printReceipt(config, list);
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }:null,
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    String receiptString = generateReceiptString(widget.selectedItems, widget.subTotal);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Connect Bluetooth Printer'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothPrint.startScan(timeout: Duration(seconds: 5)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!.map((d) => ListTile(
                    title: Text(d.name??''),
                    subtitle: Text(d.address??''),
                    onTap: () async {
                      setState(() {
                        _device = d;
                      });
                    },
                    trailing: _device!=null && _device!.address == d.address?Icon(
                      Icons.check,
                      color: Colors.green,
                    ):null,
                  )).toList(),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButton(
                          child: Text('connect'),
                          onPressed:  _connected?null:() async {
                            if(_device!=null && _device!.address !=null){
                              setState(() {
                                tips = 'connecting...';
                              });
                              await bluetoothPrint.connect(_device!);
                            }else{
                              setState(() {
                                tips = 'please select device';
                              });
                              print('please select device');
                            }
                          },
                        ),
                        SizedBox(width: 10.0),
                        OutlinedButton(
                          child: Text('disconnect'),
                          onPressed:  _connected?() async {
                            setState(() {
                              tips = 'disconnecting...';
                            });
                            await bluetoothPrint.disconnect();
                          }:null,
                        ),
                      ],
                    ),
                    Divider(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Now Available Quantities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(widget.availableQuantities.toString()),

                        Text("Receipt Preview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        // Add your receipt information here, you can use a ListView or Column
                        // to display the list of selected items and their details.
                        // Example:
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.selectedItems.length,
                          itemBuilder: (context, index) {
                            Item item = widget.selectedItems[index];
                            return ListTile(
                              title: Text("${item.itemCode} | ${item.name} "),
                              subtitle: Column(
                                children: [
                                  Text("Price: ${item.price} | Quantity: ${item.quantity} | Total: ${item.total}"),
                                ],
                              ),
                            );
                          },
                        ),
                        Text("Sub Total: ${widget.subTotal}", style: TextStyle(fontWeight: FontWeight.bold)),
                        // Add other receipt details here.
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: 10.0),
                        OutlinedButton(
                          child: Text('Print Receipt'),
                          onPressed:  _connected?() async {
                            print(generatedReceiptId());
                            print(receiptString);
                            Map<String, dynamic> config = Map();

                            List<LineText> list = [];

                            list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));

                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Gunasewana Mills', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
                            list.add(LineText(linefeed: 1));

                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'No.170,Gunasewana,Negombo Road', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Marandagahamula', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Tel: 077-7728960 | 071-7728960', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Receipt No:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: generatedReceiptId(), weight: 1, align: LineText.ALIGN_LEFT, x: 140, relativeX: 0, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Customer:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: widget.customerName, weight: 1, align: LineText.ALIGN_LEFT, x: 130, relativeX: 0, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cashier:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: "DinethriG", weight: 1, align: LineText.ALIGN_LEFT, x: 110, relativeX: 0, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: getCurrentDateTime(), weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Payment Type:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: "Cash", weight: 1, align: LineText.ALIGN_LEFT, x: 165, relativeX: 0, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));

                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Item Price', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Qty', weight: 1, align: LineText.ALIGN_LEFT, x: 155, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: "Total(Rs)", weight: 1, align: LineText.ALIGN_LEFT, x: 255, relativeX: 0, linefeed: 1));
                            list.add(LineText(linefeed: 1));

                            // Add items to the receipt
                            for (Item item in widget.selectedItems) {
                              list.add(LineText(
                                  type: LineText.TYPE_TEXT,
                                  content: ' ${item.name}',
                                  weight: 1,
                                  align: LineText.ALIGN_LEFT,
                                  x: 0,
                                  relativeX: 0,
                                  linefeed: 1, ));
                              list.add(LineText(
                                  type: LineText.TYPE_TEXT,
                                  content: item.price.toStringAsFixed(2),
                                  weight: 1,
                                  align: LineText.ALIGN_LEFT,
                                  x: 5,
                                  relativeX: 0,
                                  linefeed: 0));
                              list.add(LineText(
                                  type: LineText.TYPE_TEXT,
                                  content: item.quantity.toString(),
                                  weight: 1,
                                  align: LineText.ALIGN_LEFT,
                                  x: 160,
                                  relativeX: 0,
                                  linefeed: 0));
                              list.add(LineText(
                                  type: LineText.TYPE_TEXT,
                                  content: item.total.toStringAsFixed(2),
                                  weight: 1,
                                  align: LineText.ALIGN_LEFT,
                                  x: 260,
                                  relativeX: 0,
                                  linefeed: 1));
                            }

                            list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Sub Total', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: widget.subTotal, weight: 1, align: LineText.ALIGN_LEFT, x: 255, relativeX: 0, linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                            list.add(LineText(type: LineText.TYPE_TEXT, content: 'Thank You!!', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                            // list.add(LineText(type: LineText.TYPE_TEXT, content: 'Develop by: Digital Business Lab', weight: 1, align: LineText.ALIGN_CENTER,fontZoom: 1, linefeed: 1));
                            list.add(LineText(linefeed: 1));

                            await bluetoothPrint.printReceipt(config, list);

                            addSale(context, billNo: generatedReceiptId(), cashier: "DinethriG", billDetails: receiptString, subTotal: widget.subTotal, customer: widget.customerName);
                            updateAvailableQuantities(widget.availableQuantities);
                          }:null,
                        ),


                        OutlinedButton(
                            child: Text('Select Again'),
                            onPressed:  () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()
                                ),
                              );
                            }
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),




                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

