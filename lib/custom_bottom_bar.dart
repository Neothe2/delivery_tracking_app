import 'package:flutter/material.dart';

import 'confirmation_modal.dart';

class BottomBar extends StatelessWidget {
  final String primaryButtonLabel;
  final Function() onPrimaryButtonPressed;

  const BottomBar(
      {super.key,
      required this.primaryButtonLabel,
      required this.onPrimaryButtonPressed});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.close), label: 'Cancel'),
        BottomNavigationBarItem(
            icon: const Icon(Icons.check), label: primaryButtonLabel),
      ],
      currentIndex: 1,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) async {
        switch (index) {
          case 0:
            var confirmation = await cancelConfirmationModal(
                context: context,
                header: "Are You Sure?",
                message: "Are you sure you want to cancel?");
            if (confirmation) {
              Navigator.pop(context);
            }
          case 1:
            onPrimaryButtonPressed();
        }
      },
    );
  }
}
