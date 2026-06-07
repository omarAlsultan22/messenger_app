import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/home_repository.dart';


class GetProfileUseCase {
  final HomeRepository _repository;

  GetProfileUseCase({required HomeRepository repository}) : _repository = repository;

  Future<String> execute({required String userId}) async {
    try {
      final accountData = await _repository.getAccountData(docId: userId);
      final userAccount = accountData.data() as Map<String, dynamic>;
      var userImage = userAccount['userImage'];

      if (userImage is DocumentReference) {
        final imageDoc = await userImage.get();
        if (imageDoc.exists && imageDoc.data() != null) {
          final imageData = imageDoc.data() as Map<String, dynamic>;
          userImage = imageData['userPost'] as String? ?? '';
        } else {
          userImage = '';
        }
      }
      return userImage;
    } catch (error) {
      print('Error in getProfileImage: ${error.toString()}');
      return '';
    }
  }
}