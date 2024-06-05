import 'dart:io';
import 'dart:typed_data';

import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/proof_of_delivery/signature_page.dart';
import 'package:delivery_tracking_app/scan_crates_to_add.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../custom_bottom_bar.dart';

class ProofOfDeliveryPage extends StatefulWidget {
  const ProofOfDeliveryPage({super.key});

  @override
  State<ProofOfDeliveryPage> createState() => _ProofOfDeliveryPageState();
}

class _ProofOfDeliveryPageState extends State<ProofOfDeliveryPage> {
  File? selectedImage;
  Uint8List? signaturePngBytes;
  Image? signatureImage;
  var buttonStyle = ButtonStyle(
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
  var noteTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Title(
          color: ColorPalette.greenVibrant,
          child: const Text('Proof Of Delivery'),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Center buttons horizontally

              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                    child: AspectRatio(
                      aspectRatio: 1, // Makes the button square
                      child: OutlinedButton(
                        style: buttonStyle,
                        onPressed: () async {
                          await getSignature(context);
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              //TODO: replace with signature icon
                              Icons.note_alt,
                              size: 100,
                            ),
                            Text('Signature')
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: OutlinedButton(
                        style: buttonStyle,
                        onPressed: () async {
                          await _pickImage();
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 100,
                            ),
                            Text('Photo')
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            // Wrap the TextField in ans Expanded widget
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TextField(
                maxLines: 10,
                controller: noteTextController,
                decoration:
                    const InputDecoration(hintText: 'Write any notes here...'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        primaryButtonLabel: 'Submit',
        onPrimaryButtonPressed: () {
          if (selectedImage != null &&
              signaturePngBytes != null &&
              signaturePngBytes!.isNotEmpty &&
              noteTextController.text != "") {
            Navigator.pop(context, {
              "signature": signaturePngBytes,
              "image": selectedImage,
              "note": noteTextController.text,
            });
          } else {
            //Show error snackbar
            showTopSnackBar(context, 'Please fill in all fields', Colors.red);
          }
        },
      ),
    );
  }

  Future<void> getSignature(BuildContext context) async {
    var response = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (cxt) => const SignaturePage(),
      ),
    );

    if (response != null && response is SignatureController) {
      Uint8List? pngBytes = await response.toPngBytes();
      if (pngBytes != null) {
        setState(() {
          signaturePngBytes = pngBytes;
        });
      }
    }
  }

  Future _pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage != null) {
      setState(() {
        selectedImage = File(returnedImage.path);
      });
    }
  }
}
