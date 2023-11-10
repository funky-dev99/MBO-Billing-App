import 'package:billing_app/Pages/itemsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddingItemsPage extends StatefulWidget {
  const AddingItemsPage({Key? key}) : super(key: key);

  @override
  State<AddingItemsPage> createState() => _AddingItemsPageState();
}

class _AddingItemsPageState extends State<AddingItemsPage> {
  // Controller for text fields
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // Function to handle save button press
  Future<void> addItem(
    BuildContext context, {
    required String itemCode,
    required String name,
    required double price,
    required int quantity,
  }) async {
    // Add your validation logic for text controllers here
    // For example, you can check if the fields are not empty or meet specific criteria

    if (itemCode.isEmpty || name.isEmpty || price <= 0 || quantity <= 0) {
      // Show an error message or handle validation failure
      // You can use a snackbar or any other UI element to display the message
      snackBar(
          context, "Please fill in all fields with valid values.", Colors.red);
      return;
    }

    // If validation passes, proceed with adding the item
    var url = "http://dev.workspace.cbs.lk/addItems.php";

    var data = {
      "item_code": itemCode,
      "item_name": name,
      "price": price.toString(),
      "available_quantity": quantity.toString(),
      "status_" :' 1',
      // Add other required parameters for your API
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
        // Show success message
        if (!mounted) return;
        showPrintedSuccessfullyDialog(context);
      } else {
        // Handle API response indicating failure
        if (!mounted) return;
        snackBar(context, "Error", Colors.blueAccent);
      }
    } else {
      // Handle non-200 status code
      if (!mounted) return;
      snackBar(context, "Error", Colors.redAccent);
    }
  }

  Future<void> snackBar(
      BuildContext context, String message, Color color) async {
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
      barrierDismissible:
          false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Successful'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Item Added Successfully!!'),
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
              child: Text('Add another item'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddingItemsPage()),
                );
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
        title: Text('Add Item'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ItemsPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "Item Code:",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: itemCodeController,
                  decoration: InputDecoration(
                    hintText: '#0001',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "Item Name:",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 400, // Adjust the width as needed
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Item Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Price:",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 180, // Adjust the width as needed
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: priceController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '2800.00',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Quantity:",
                        style: TextStyle(fontSize: 18, color: Colors.black),
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
                          controller: quantityController,
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
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    addItem(
                      context,
                      itemCode: itemCodeController.text,
                      name: nameController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      quantity: int.tryParse(quantityController.text) ?? 0,
                    );
                  },
                  child: Text('Save Item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
