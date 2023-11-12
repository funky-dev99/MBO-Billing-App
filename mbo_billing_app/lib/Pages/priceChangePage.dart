
import 'package:flutter/material.dart';
import 'package:mbo_billing_app/Pages/itemsPage.dart';

import '../sizes.dart';



class PriceChangePage extends StatefulWidget {
  final Item item; // Assuming Item is your data model

  const PriceChangePage({Key? key, required this.item}) : super(key: key);

  @override
  State<PriceChangePage> createState() => _PriceChangePageState();
}

class _PriceChangePageState extends State<PriceChangePage> {

  final TextEditingController newPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Item Price'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20,width: getPageWidth(context),),

          Container(
            width: 310,
            height: 250,
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
                  padding: const EdgeInsets.only(bottom: 5,left: 15 ,top: 10),
                  child: Text('Item Code: ${widget.item.itemCode}',style: TextStyle(fontSize: 16),),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5,left: 15),
                  child: Text('Item Name: ${widget.item.name}',style: TextStyle(fontSize: 16),),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15,left: 15),
                  child: Text('Current Price: ${widget.item.price}',style: TextStyle(fontSize: 16),),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5,left: 15),
                      child: Text(
                        "New price: ",
                        style: TextStyle(fontSize: 16, color: Colors.black),
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
                          controller: newPriceController,
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
                SizedBox(height: 15,width: getPageWidth(context),),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {

                      },
                      child: Text('Save'),
                    ),

                    SizedBox(width: 15,),
                    ElevatedButton(
                      onPressed: () {

                      },
                      child: Text('Cancel',style: TextStyle(color: Colors.redAccent),),
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
