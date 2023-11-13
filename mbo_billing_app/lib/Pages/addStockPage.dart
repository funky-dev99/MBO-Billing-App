
import 'package:flutter/material.dart';
import 'package:mbo_billing_app/Pages/itemsPage.dart';

import '../sizes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStockPage extends StatefulWidget {
  final Item item;
  const AddStockPage({super.key, required this.item});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final TextEditingController newStockController = TextEditingController();

  void addStock(String itemCode, String newStock) {
    // Convert newStock to an integer
    int newStockInt = int.tryParse(newStock) ?? 0;

    // Call the addStock function with the integer value
    addStockToServer(itemCode, newStockInt);
  }

  Future<bool> addStockToServer(String itemCode, int newStock) async {
    // Prepare the data to be sent to the PHP script.
    var data = {
      "item_code": itemCode,
      "available_quantity": newStock.toString(),
    };

    // URL of your PHP script.
    const url = "http://dev.workspace.cbs.lk/addStockMbO.php";

    try {
      final res = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (res.statusCode == 200) {
        final responseBody = jsonDecode(res.body);

        // Debugging: Print the response data.
        print("Response from PHP script: $responseBody");

        if (responseBody == "true") {
          print('Edit Successful');
          showEditedSuccessfullyDialog(context);
          return true; // PHP code was successful.
        } else {
          print('PHP code returned "false".');
          return false; // PHP code returned "false."
        }
      } else {
        print('HTTP request failed with status code: ${res.statusCode}');
        return false; // HTTP request failed.
      }
    } catch (e) {
      print('Error occurred: $e');
      return false; // An error occurred.
    }
  }


  Future<void> showEditedSuccessfullyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
      false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Successful'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Stock Added successfully!!'),
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
                  MaterialPageRoute(builder: (context) => ItemsPage()),
                );
                // Close the dialog
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Stock'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: getPageWidth(context),
          ),
          Container(
            width: 310,
            height: 275,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 15, top: 10),
                  child: Text(
                    'Item Code: ${widget.item.itemCode}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 15),
                  child: Text(
                    'Item Name: ${widget.item.name}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, left: 15),
                  child: Text(
                    'Current Quantity: ${widget.item.availableQuantity}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 12),
                  child: Text(
                    'New Quantity = Current Quantity + Added Quantity',
                    style: TextStyle(fontSize: 12,color: Colors.redAccent),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, left: 15),
                      child: Text(
                        "New Quantity: ",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 150, // Adjust the width as needed
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: newStockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '50',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                  width: getPageWidth(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        addStock(widget.item.itemCode, newStockController.text);
                      },
                      child: Text('Save'),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ItemsPage()),
                        );
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
