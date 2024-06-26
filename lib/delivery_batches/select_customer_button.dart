import 'package:flutter/material.dart';
import 'package:delivery_tracking_app/models/customer.dart';
import 'package:delivery_tracking_app/models/address.dart';
import 'package:delivery_tracking_app/delivery_batches/select_customer_page.dart';

class SelectCustomerButton extends StatelessWidget {
  final List<Customer> customerList;
  final Customer? selectedCustomer;
  final Address? selectedAddress;
  final bool addClicked;
  final Function(Customer, Address) onCustomerSelected;

  const SelectCustomerButton({
    Key? key,
    required this.customerList,
    required this.selectedCustomer,
    required this.selectedAddress,
    required this.addClicked,
    required this.onCustomerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Visibility(
            visible: (selectedCustomer == null && addClicked),
            child: const Text("Please select a customer",
                style: TextStyle(color: Colors.red)),
          ),
        ),
        SizedBox(
          width: 300,
          child: OutlinedButton(
            onPressed: () async {
              List<dynamic>? response = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (cxt) => SelectCustomerPage(
                    customerList: customerList,
                    initialCustomer: selectedCustomer,
                    selectedAddress: selectedAddress,
                  ),
                ),
              );

              if (response != null) {
                if (response[0] is Customer) {
                  onCustomerSelected(response[0], response[1]);
                }
              }
            },
            child: const Text('Select Customer'),
          ),
        ),
      ],
    );
  }
}
