import 'package:flutter/material.dart';

class AddDeliveryBatch extends StatefulWidget {
  const AddDeliveryBatch({super.key});

  @override
  State<AddDeliveryBatch> createState() => _AddDeliveryBatchState();
}

class _AddDeliveryBatchState extends State<AddDeliveryBatch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Batch'),
      ),
      body: Column(),
    );
  }
}
