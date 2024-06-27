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
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: (selectedCustomer == null && addClicked),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                "Please select a customer",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          OutlinedButton(
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              shadowColor: Colors.black.withOpacity(0.1),
              elevation: 5,
            ),
            child: const Text(
              'Select Customer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
