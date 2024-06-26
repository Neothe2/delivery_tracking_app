import 'package:flutter/material.dart';
import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/models/delivery_batch.dart';

class DeliveryBatchListItem extends StatelessWidget {
  final DeliveryBatch deliveryBatch;
  final VoidCallback onTap;

  const DeliveryBatchListItem({
    Key? key,
    required this.deliveryBatch,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: ColorPalette.backgroundWhite,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorPalette.green,
              foregroundColor: Colors.white,
              child: Text(
                deliveryBatch.id.toString().toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              "To: ${deliveryBatch.customer!.name}",
              style: TextStyle(
                color: ColorPalette.greenDarkest,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              deliveryBatch.address!.value,
              style: TextStyle(color: ColorPalette.greenDark),
            ),
            trailing: const Icon(
              Icons.chevron_right_sharp,
              color: ColorPalette.green,
            ),
          ),
        ),
      ),
    );
  }
}
