import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../models/user_model.dart';
import 'components.dart' as Fluttertoast;

Future<String?> pickImageOrVideo() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return await checkFile(file);
    }
    return null;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}

Future<String?> checkFile(File file) async {
  try {
    String filePath = file.path.toLowerCase();
    String extension = path.extension(filePath).replaceFirst('.', '');

    List<String> imageExtensions = ['jpg', 'png', 'jpeg', 'gif', 'webp'];
    List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv'];
    List<String> audioExtensions = [
      'mp3',     // الأكثر شيوعاً
      'wav',     // صوت غير مضغوط بجودة عالية
      'aac',     // Advanced Audio Coding
      'ogg',     // مفتوح المصدر
      'm4a',     // Apple Audio
      'flac',    // Free Lossless Audio Codec
      'wma',     // Windows Media Audio
      'aiff',    // Audio Interchange File Format
      'opus',    // فعال للبث عبر الإنترنت
      'amr',     // Adaptive Multi-Rate (شائع في التسجيلات الصوتية)
    ];

    if (imageExtensions.contains(extension)) {
      return await uploadFile(file, 'images');
    } else if (videoExtensions.contains(extension)) {
      return await uploadFile(file, 'videos');
    }
    else if (audioExtensions.contains(extension)) {
      return await uploadFile(file, 'audios');
    }
    else {
      print('Unsupported file type: $extension');
      return null;
    }
  } catch (e) {
    print('Error checking file: $e');
    return null;
  }
}

Future <String?> uploadFile(File file, String folderName) async {
  try {
    String fileName = path.basename(file.path);
    Reference storageReference =
    FirebaseStorage.instance.ref().child('$folderName/$fileName');

    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    if (snapshot.state == TaskState.success) {
      String downloadUrl = await storageReference.getDownloadURL();
      print('File uploaded to $folderName/$fileName');
      return downloadUrl;
    } else {
      print('Upload failed');
      return null;
    }
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}

void showToast({
  required String msg,
  int? timeInSecForIosWeb,
  Toast? toastLength,
  ToastGravity? gravity,
  Color? backgroundColor,
  double? fontSize,
  Color? textColor
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<Map<String, dynamic>> getUserAccount({
  required Map<String, dynamic> userAccount,
}) async {
  try {
    if (userAccount['userImage'] is DocumentReference) {
      final imageDocRef = userAccount['userImage'] as DocumentReference;
      final imageDoc = await imageDocRef.get();

      if (imageDoc.exists && imageDoc.data() != null) {
        final imageData = imageDoc.data() as Map<String, dynamic>;
        userAccount['userImage'] = imageData['userPost'] as String? ?? '';
      } else {
        userAccount['userImage'] = '';
      }
    }
    return userAccount;
  }
  catch (e) {
    print('Error in getAccount: $e');
    return {};
  }
}

Future<Map<String, dynamic>> getAccountMap({
  required DocumentSnapshot userDoc,
}) async {
  try {
    final userAccount = userDoc.data() as Map<String, dynamic>? ?? {};

    return await getUserAccount(userAccount: userAccount);
  } catch (e) {
    print('Error in getAccount: $e');
    return {};
  }
}

Future<UserModel> getUserModelData({
  required String id,
})async {
  UserModel userModel;
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('accounts').doc(id).get();
    final data = await getAccountMap(userDoc: userDoc);
    UserModel accountData = UserModel.fromJson(data);
    userModel = accountData;
  } catch (e) {
    rethrow;
  }
  return userModel;
}

Future navigator({
  required BuildContext context,
  required Widget link
}) => Navigator.push(context, MaterialPageRoute(builder: (context)=> link));


SizedBox sizeBox () =>
    const SizedBox(
      height: 16.0,
    );


String? validator(String? value, String? item) {
  if (value!.isEmpty) {
    return 'Please Enter Your $item';
  }
  return null;
}


Widget buildInputField({
  required TextEditingController controller,
  String? label,
  String? hintText,
  TextInputType? keyboardType,
  Widget? icon,
  InputDecoration? decoration,
  String? Function(String?)? validator,
  required BuildContext context,
  bool enabled = true,
  double borderRadius = 50.0,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType ?? TextInputType.text,
    cursorRadius: const Radius.circular(100.0),
    validator: validator,
    enabled: enabled,
    decoration: decoration ?? InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
      ),
      labelText: label,
      hintText: hintText,
      prefixIcon: icon,
    ),
  );
}
