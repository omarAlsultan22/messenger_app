import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/lib/models/last_message_model.dart';
import 'package:test_app/lib/models/user_model.dart';
import 'package:test_app/lib/modules/notification_service/notification_service.dart';
import 'package:test_app/lib/shared/components/components.dart';
import '../../shared/cubit_states/cubit_states.dart';

class MainScreenCubit extends Cubit<CubitStates> {
  MainScreenCubit() : super((InitialState()));

  static MainScreenCubit get(context) => BlocProvider.of(context);

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  List<LastMessageModel> friendsList = [];
  StreamSubscription? _friendsSubscription;
  String profileImage = '';
  bool isMessage = true;


  Future<void> getProfileImage({
    required String userId
})async {
    emit(LoadingState());
    try {
      final getData = await FirebaseFirestore.instance.collection('accounts')
          .doc(userId)
          .get();
      final userAccount = getData.data() as Map<String, dynamic>;
      var userImage = userAccount['userImage'];
      if (userImage is DocumentReference) {
        final imageDocRef = userImage;
        final imageDoc = await imageDocRef.get();

        if (imageDoc.exists && imageDoc.data() != null) {
          final imageData = imageDoc.data() as Map<String, dynamic>;
          userImage = imageData['userPost'] as String? ?? '';
        } else {
          userImage = '';
        }
        profileImage = userImage;
      }
      emit(SuccessState());
    }
    catch (error) {
      emit(ErrorState(error.toString()));
      print('Error in getAccount: ${error.toString()}');
      return;
    }
  }

  Stream<List<LastMessageModel>> getFriendsStream({required String userId}) {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .switchMap((friendsSnapshot) {
      if (friendsSnapshot.docs.isEmpty) {
        return Stream.value([]);
      }

      final streams = friendsSnapshot.docs.map((friendDoc) {
        return _getFriendLastMessageStream(firestore, userId, friendDoc.id);
      });

      return Rx.combineLatestList(streams);
    });
  }

  Stream<LastMessageModel> _getFriendLastMessageStream(
      FirebaseFirestore firestore,
      String userId,
      String friendId,
      ) {

    return firestore
        .collection('messages')
        .where('participants', arrayContains: friendId)
        .orderBy('lastMessageDateTime', descending: true)
        .limit(1)
        .snapshots()
        .switchMap((messagesSnapshot) {
      if (messagesSnapshot.docs.isEmpty) {
        return Stream.value(LastMessageModel.createEmptyLastMessage(friendId));
      }

      final lastMessage = messagesSnapshot.docs.first.data();
      final docId = lastMessage['docId'] as String?;
      if (docId == null) {
        return Stream.value(LastMessageModel.createEmptyLastMessage(friendId));
      }


      final unreadMessagesStream = firestore
          .collection('messages')
          .doc(docId)
          .collection('conversations')
          .where('unreadMessage', isEqualTo: true)
          .snapshots()
          .asyncMap((snapshot) async {
        for (final doc in snapshot.docs) {
          final unreadMessage = doc.data();
          lastMessage['unreadMessagesCount'] = snapshot.size;
          final senderId = unreadMessage['senderId'];
          final userModel = await getUserModelData(id: senderId);
          final messageWithDetails = {
            ...unreadMessage,
            'userName': userModel.userName,
            'docId': docId,
          };

          if (isMessage && userId != senderId) {
            NotificationService().sendMessage(messageWithDetails);
          }
        }
        return snapshot.size;
      });


      final userDataStream = Stream.fromFuture(getUserModelData(id: friendId));

      return Rx.combineLatest2(
        unreadMessagesStream,
        userDataStream,
            (int unreadCount, UserModel userModel) {
          if (lastMessage['participants'] != null) {
            lastMessage['participants'] =
            List<String>.from(lastMessage['participants'] as List);
          }

          if (lastMessage['lastMessageDateTime'] is Timestamp) {
            lastMessage['lastMessageDateTime'] =
                (lastMessage['lastMessageDateTime'] as Timestamp).toDate();
          }

          if (userModel.lastSeen is Timestamp) {
            userModel.lastSeen = (userModel.lastSeen as Timestamp).toDate();
          }

          lastMessage['userId'] = userModel.userId;
          lastMessage['userName'] = userModel.userName;
          lastMessage['userImage'] = userModel.userImage;
          lastMessage['isOnline'] = userModel.isOnline;
          lastMessage['lastSeen'] = userModel.lastSeen;


          return LastMessageModel.fromJson(lastMessage);
        },
      );
    }).handleError((e) {
      print('Error with friend $friendId: $e');
      return Stream.value(LastMessageModel.createEmptyLastMessage(friendId));
    });
  }


  Future<void> getFriends({required String userId}) async {
    emit(LoadingState());
    _friendsSubscription?.cancel();
    _friendsSubscription = getFriendsStream(userId: userId).listen(
          (updatedFriendsList) {
        friendsList = updatedFriendsList;
        isMessage = true;
        emit(SuccessState());
      },
      onError: (error) {
        emit(ErrorState(error.toString()));
      },
    );
  }

  @override
  Future<void> close(){
    _friendsSubscription?.cancel();
    return super.close();
  }
}

