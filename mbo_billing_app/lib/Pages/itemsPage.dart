
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mbo_billing_app/Pages/priceChangePage.dart';
import 'dart:convert';

import 'homePage.dart';
import 'itemsAddingPage.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems().then((fetchedItems) {
      setState(() {
        items = fetchedItems;
      });
    });
  }

  Future<List<Item>> fetchItems() async {
    const url = "http://dev.workspace.cbs.lk/getItemsMbO.php";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        return jsonResponse.map((item) => Item.fromJson(item)).toList();
      }

      return [];
    } else {
      throw Exception(
          'Failed to load data from the API. Status Code: ${response.statusCode}');
    }
  }

  void showRemoveConfirmationDialog(BuildContext context, String itemCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Remove'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // deleteMainTask(taskId); // Call the deleteMainTask method
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showMoreOptions(Item selectedItem) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Change Price'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PriceChangePage(item: selectedItem),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Add Stock'),
              onTap: () {
                // Implement the logic for adding stock
                Navigator.pop(context);
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
        title: Text('Items'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${items[index].itemCode} | ${items[index].name}'),
                        Text('Rs:${items[index].price.toStringAsFixed(2)}'),
                        Text('Quantity: ${items[index].availableQuantity}'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showRemoveConfirmationDialog(context, items[index].itemCode);
                          },
                          icon: Icon(
                            Icons.remove_circle_outline_rounded,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Remove Item',
                        ),
                        IconButton(
                          onPressed: () {
                            showMoreOptions(items[index]);
                          },
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.black,
                          ),
                          tooltip: 'More',
                        )
                      ],
                    ),
                  ],
                ),
                // Add more details if needed
              ),
              Divider()
            ],
          );
        },
      ),

      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddingItemsPage()),);
        },
        child: Text('Add Items'),
      ),
    );
  }
}

class Item {
  final String itemCode;
  final String name;
  final double price;
  final int availableQuantity;

  // Use named parameters for the constructor
  Item({
    required this.itemCode,
    required this.name,
    required this.price,
    required this.availableQuantity,
  });

  // Factory constructor to convert JSON to an Item object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['item_code'],
      name: json['item_name'],
      price: double.parse(json['price'].toString()),
      availableQuantity: int.parse(json['available_quantity'].toString()),
    );
  }
}
