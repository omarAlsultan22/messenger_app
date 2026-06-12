import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../repositories/home_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/user_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/data/models/last_message_model.dart';
import 'package:test_app/core/utils/mappers/user_account_mapper.dart';


class GetFriendsUseCase {
  final HomeRepository _repository;

  GetFriendsUseCase({required HomeRepository repository})
      : _repository = repository;

  Stream<List<LastMessageModel>> execute({required String userId}) {
    return _repository.getFriendsListStream(docId: userId).switchMap((
        friendsSnapshot) {
      if (friendsSnapshot.docs.isEmpty) {
        return Stream.value([]);
      }

      final streams = friendsSnapshot.docs.map((friendDoc) {
        return _getFriendLastMessageStream(friendDoc.id, userId);
      });

      return Rx.combineLatestList(streams);
    });
  }

  Future<Map<String, dynamic>> _getAccountMap({
    required DocumentSnapshot userDoc,
  }) async {
    try {
      final userAccount = userDoc.data() as Map<String, dynamic>? ?? {};
      return await UserAccountMapper.enrichUserAccount(
          userAccount: userAccount);
    } catch (e) {
      return {};
    }
  }

  Future<UserModel> _getUserModelData({
    required String docId,
  }) async {
    UserModel userModel;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('accounts').doc(docId).get();
      final data = await _getAccountMap(userDoc: userDoc);
      UserModel accountData = UserModel.fromJson(data);
      userModel = accountData;
    } catch (e) {
      rethrow;
    }
    return
      userModel;
  }

  Stream<LastMessageModel> _getFriendLastMessageStream(String friendId,
      String userId) {
    return _repository.getLastMessageStream(friendId: friendId).switchMap((
        messagesSnapshot) {
      if (messagesSnapshot.docs.isEmpty) {
        return Stream.value(LastMessageModel.createEmptyLastMessage(friendId));
      }

      final lastMessage = messagesSnapshot.docs.first.data() as Map<
          String,
          dynamic>;
      final docId = lastMessage['docId'] as String?;

      if (docId == null) {
        return Stream.value(LastMessageModel.createEmptyLastMessage(friendId));
      }

      final unreadMessagesStream = _repository.getUnreadMessagesStream(
          docId: docId).asyncMap((snapshot) async {
        for (final doc in snapshot.docs) {
          final unreadMessage = doc.data() as Map<String, dynamic>;
          final unreadMessagesNumber =
          lastMessage['unreadMessagesCount'] = snapshot.size;
          final senderId = unreadMessage['senderId'];
          final userModel = await _getUserModelData(docId: senderId);
          final messageWithDetails = {
            ...unreadMessage,
            'userName': userModel.firstName,
            'docId': docId,
          };

          if (unreadMessagesNumber != 0 && userId != senderId) {
            for (int num = 0; num < unreadMessagesNumber; num++) {
              NotificationService().sendMessage(messageWithDetails);
            }
          }
        }
        return snapshot.size;
      });

      final userDataStream = Stream.fromFuture(
          _getUserModelData(docId: friendId));

      return Rx.combineLatest2(
        unreadMessagesStream,
        userDataStream,
            (int unreadCount, UserModel userModel) {
          final Map<String, dynamic> processedMessage = Map.from(lastMessage);

          if (processedMessage['participants'] != null) {
            processedMessage['participants'] =
            List<String>.from(processedMessage['participants'] as List);
          }

          if (processedMessage['lastMessageDateTime'] is Timestamp) {
            processedMessage['lastMessageDateTime'] =
                (processedMessage['lastMessageDateTime'] as Timestamp).toDate();
          }

          DateTime? lastSeen = userModel.lastSeen;
          if (lastSeen is Timestamp) {
            lastSeen = (lastSeen as Timestamp).toDate();
          }

          processedMessage['userId'] = userModel.userId;
          processedMessage['userName'] = userModel.firstName;
          processedMessage['userImage'] = userModel.userImage;
          processedMessage['isOnline'] = userModel.isOnline;
          processedMessage['lastSeen'] = lastSeen;

          return LastMessageModel.fromJson(processedMessage);
        },
      );
    }).handleError((e) {
      print('Error with friend $friendId: $e');
      return Stream.value(LastMessageModel.createEmptyLastMessage(friendId));
    });
  }
}