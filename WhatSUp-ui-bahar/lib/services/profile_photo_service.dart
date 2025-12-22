import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ProfilePhotoService {
  static Future<String?> pickResizeAndSaveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final Uint8List bytes = await picked.readAsBytes();

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // thumbnail: 256px genişlik yeterli
    final img.Image resized = img.copyResize(decoded, width: 256);
    final List<int> jpg = img.encodeJpg(resized, quality: 80);

    final String b64 = base64Encode(jpg);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'photoBase64': b64}, SetOptions(merge: true));

    return b64;
  }

  static Uint8List decodeBase64ToBytes(String b64) {
    return base64Decode(b64);
  }
}
