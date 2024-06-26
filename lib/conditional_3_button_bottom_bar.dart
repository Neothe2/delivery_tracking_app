import 'package:flutter/material.dart';

import 'confirmation_modal.dart';

class ConditionalThreeButtonBottomBar extends StatelessWidget {
  final String primaryButtonLabel;
  final Function() onPrimaryButtonPressed;
  final String secondaryButtonLabel;
  final Function() onSecondaryButtonPressed;
  final IconData secondaryButtonIcon;
  final bool showSecondaryButton;

  const ConditionalThreeButtonBottomBar({
    super.key,
    required this.primaryButtonLabel,
    required this.onPrimaryButtonPressed,
    required this.secondaryButtonLabel,
    required this.onSecondaryButtonPressed,
    required this.secondaryButtonIcon,
    required this.showSecondaryButton,
  });

  @override
  Widget build(BuildContext context) {
    //TODO: Make this better
    return (showSecondaryButton)
        ? BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.close), label: 'Cancel'),
              BottomNavigationBarItem(
                icon: const Icon(Icons.check),
                label: primaryButtonLabel,
              ),
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
          )
        : BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.close), label: 'Cancel'),
              BottomNavigationBarItem(
                  icon: Icon(secondaryButtonIcon), label: secondaryButtonLabel),
              BottomNavigationBarItem(
                icon: const Icon(Icons.check),
                label: primaryButtonLabel,
              ),
            ],
            currentIndex: 2,
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
                  onSecondaryButtonPressed();
                case 2:
                  onPrimaryButtonPressed();
              }
            },
          );
  }
}
