import 'dart:convert';

import 'package:billing_app/Pages/printerPage.dart';
import 'package:billing_app/Pages/salesPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'itemsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _customerNameController = TextEditingController();
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
        List<Item> items = jsonResponse.map((item) => Item(
          item['item_code'],
          item['item_name'],
          double.parse(item['price'].toString()), // Parse price to double
          0,
          0.0,
          isSelected: false,
          availableQuantity: int.parse(item['available_quantity'].toString()), // Convert to int
        )).toList();

        return items;
      }

      return [];
    } else {
      throw Exception(
          'Failed to load data from the API. Status Code: ${response.statusCode}');
    }
  }

  Map<String, int> getAvailableQuantities(List<Item> items) {
    Map<String, int> availableQuantities = {};
    for (var item in items) {
      int nowAvailableQuantity = item.availableQuantity - item.quantity;
      availableQuantities[item.itemCode] = nowAvailableQuantity;
    }
    return availableQuantities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gunasewana Mills'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.insert_chart_outlined_rounded,),
              title: Text('Sales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.business_center_outlined),
              title: Text('Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ItemsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemTile(
                  item: items[index],
                  onQuantityChanged: (int value) {
                    setState(() {
                      items[index].quantity = value;
                      if (items[index].isSelected) {
                        items[index].total = value * items[index].price;
                      }
                    });
                  },
                  onSelectedChanged: (bool value) {
                    setState(() {
                      items[index].isSelected = value;
                      if (value) {
                        items[index].total =
                            items[index].quantity * items[index].price;
                      } else {
                        items[index].total = 0;
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          List<Item> selectedItems =
          items.where((item) => item.isSelected).toList();
          double subtotal = 0;
          for (var item in selectedItems) {
            subtotal += item.total;
          }
          String stSubtotal = subtotal.toStringAsFixed(2);

          printSelectedItems(selectedItems);
          print('Subtotal: ${stSubtotal}');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrinterPage(
                selectedItems: selectedItems,
                subTotal: stSubtotal,
                customerName: _customerNameController.text,
                availableQuantities: getAvailableQuantities(selectedItems),
              ),
            ),
          );
        },
        child: Text('Print'),
      ),
    );
  }

  void printSelectedItems(List<Item> selectedItems) {
    print('Selected Items:');
    for (var item in selectedItems) {
      print(
          'Name: ${item.name}, Price: ${item.price.toStringAsFixed(2)}, Quantity: ${item.quantity}, Total: ${item.total.toStringAsFixed(2)}, Available Quantity: ${item.availableQuantity}');
    }
  }
}

class ItemTile extends StatefulWidget {
  final Item item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onSelectedChanged;

  ItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onSelectedChanged,
  });

  @override
  _ItemTileState createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  int quantity = 0;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    quantity = widget.item.quantity;
    selected = widget.item.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
          widget.onSelectedChanged(selected);
        });
      },
      child: ListTile(
        title: Text(widget.item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rs:${widget.item.price.toStringAsFixed(2)}'),
            Text('Available Quantity: ${widget.item.availableQuantity}'),
          ],
        ),
        leading: Checkbox(
          value: selected,
          onChanged: (newValue) {
            setState(() {
              selected = newValue ?? false;
              widget.onSelectedChanged(selected);
            });
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                if (quantity > 0) {
                  setState(() {
                    quantity--;
                    widget.onQuantityChanged(quantity);
                  });
                }
              },
            ),
            Text(quantity.toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  quantity++;
                  widget.onQuantityChanged(quantity);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String itemCode;
  final String name;
  final double price;
  int quantity;
  double total;
  bool isSelected;
  int availableQuantity;

  Item(this.itemCode, this.name, this.price, this.quantity, this.total,
      {this.isSelected = false, required this.availableQuantity});
}
