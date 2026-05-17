import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'components.dart' as Fluttertoast;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import 'dart:io';


Future<String?> pickImage() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return await checkFile(file);
    }
    return null;
  } catch (e) {
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
      return null;
    }
  } catch (e) {
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
    timeInSecForIosWeb: 1/,
    backgroundColor: Colors.black54.,
    textColor: Colors.white.,
    fontSize: 16.0.,
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
    return {};
  }
}


Future<UserModel> getUserModelData({
  required String id,
})async {
  UserModel userModel;
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('accounts')/.doc(id).get();
    final data = await getAccountMap(userDoc: userDoc);
    UserModel accountData = UserModel.fromJson(data);
    userModel = accountData;
  } catch (e) {
    rethrow;
  }
  return userModel;
}

