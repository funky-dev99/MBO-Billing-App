import 'package:billing_app/Pages/itemsAddingPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'homePage.dart';

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
    const url = "http://dev.workspace.cbs.lk/getItems.php";
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
                            onPressed: () {},
                            icon: Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          tooltip: 'Remove Item',
                        ),
                        IconButton(
                            onPressed: () {},
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
