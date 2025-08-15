import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/lib/models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../shared/components/constants.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../online_status_service/online_status_service.dart';

class ConversationsCubit extends Cubit<CubitStates> {
  ConversationsCubit() : super(InitialState());

  static ConversationsCubit get(context) => BlocProvider.of(context);
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  StreamSubscription? _interactionsSubscription;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _onlineSubscription;
  StreamSubscription? _lastSeenSubscription;
  DocumentSnapshot? firstDocument;
  DocumentSnapshot? lastDocument;
  SharedPreferences? _prefs;
  List<MessageGroup> conversationsList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isMe = false;
  String currentId = '';
  bool? isOnline;
  bool? isTyping;
  DateTime? lastSeen;
  bool hasMessages = true;
  Color? bgColor;
  String? bgImage;

  Future<void> getSavedBackgroundColorAndImage(String docId) async {
    final colorValue = _prefs?.getString('bg_color_$docId');
    bgImage = _prefs?.getString('bg_image_$docId');
    bgColor = Color(int.parse(colorValue!));
    emit(SuccessState(key: 'getSavedBackgroundColorAndImage'));
  }

  void clearConversationsList() {
    conversationsList.clear();
    emit(SuccessState(key: 'clearConversationsList'));
  }

  Future<void> updateUnreadMessages(String docId) async {
    emit(LoadingState(key: 'updateUnreadMessages'));
    try {
      final firestore = FirebaseFirestore.instance;
      final unreadMessages = await firestore
          .collection('messages')
          .doc(docId)
          .collection('conversations')
          .where('unreadMessage', isEqualTo: true)
          .get();

      await Future.wait(
          unreadMessages.docs.map((unreadMessage) async {
            firestore.collection('messages')
                .doc(docId)
                .collection('conversations').doc(unreadMessage.id).update(
                {'unreadMessage': false});
          })
      );
      emit(SuccessState(key: 'updateUnreadMessages'));
    }
    catch (error) {
      emit(ErrorState(error: error.toString(), key: 'updateUnreadMessages'));
    }
  }

  Future<void> getConversations({required String docId}) async {
    emit(LoadingState(key: 'getConversations'));
    _conversationsSubscription?.cancel();

    _conversationsSubscription = getNewMessages(
      docId: docId,
    ).listen((messageGroups) {
      for (final group in messageGroups) {
        final existingIndex = conversationsList.indexWhere(
                (g) => g.title == group.title
        );
        if (existingIndex != -1) {
          conversationsList[existingIndex].messages.addAll(group.messages);
        } else {
          conversationsList.add(group);
        }
      }
      emit(SuccessState(key: 'getConversations'));
    }, onError: (error) {
      emit(ErrorState(error: error.toString(), key: 'getConversations'));
    });
  }

  Future<void> updateTyping(bool isTyping) async {
    if (_auth.currentUser == null) return;

    await FirebaseFirestore.instance.collection('accounts').doc(
        _auth.currentUser!.uid).update({
      'isTyping': isTyping,
    });
  }

  void getUserOnlineStatus(OnlineStatusService onlineStatusService,
      String userId) {
    _onlineSubscription =
        onlineStatusService.getUserOnlineStatus(userId).listen((value) {
          isOnline = value;
          emit(UserStatusUpdatedState());
        });
  }

  void getUserTypingStatus(OnlineStatusService onlineStatusService,
      String userId) {
    _onlineSubscription =
        onlineStatusService.getUserTypingStatus(userId).listen((value) {
          isTyping = value;
          emit(UserStatusUpdatedState());
        });
  }

  void getUserLastSeen(OnlineStatusService onlineStatusService, String userId) {
    _lastSeenSubscription =
        onlineStatusService.getUserLastSeen(userId).listen((value) {
          lastSeen = value;
          emit(UserStatusUpdatedState());
        });
  }

  @override
  Future<void> close() async {
    _conversationsSubscription?.cancel();
    _onlineSubscription?.cancel();
    _lastSeenSubscription?.cancel();
    await _interactionsSubscription?.cancel();
    return super.close();
  }

  Future<void> deleteConversation({
    required String docId
  }) async {
    emit(LoadingState(key: 'deleteConversation'));
    try {
      conversationsList.clear();
      await FirebaseFirestore.instance.collection('messages')
          .doc(docId).delete();
      emit(SuccessState(key: 'deleteConversation'));
    }
    catch (error) {
      emit(ErrorState(error: error.toString(), key: 'deleteConversation'));
    }
  }

  Future<void> deleteMessage({
    required List<String> messagesIds,
    required String docId,
  }) async {
    emit(LoadingState(key: 'deleteMessage'));
    try {
      for (var group in conversationsList) {
        group.messages.removeWhere((e) => messagesIds.contains(e.messageId));
      }
      conversationsList.removeWhere((group) => group.messages.isEmpty);
      emit(SuccessState(key: 'deleteMessage'));
    } catch (error) {
      emit(ErrorState(error: 'Error deleting message: $error', key: 'deleteMessage'));
    }
  }

  Future<void> sendMessage({
    required String docId,
    required String userId,
    required ConversationModel conversation,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = firestore.collection('messages')
          .doc(docId)
          .collection('conversations')
          .doc();
      conversation.messageId = doc.id;
      await doc.set(conversation.toMap());
      _organizeMessagesByDate([conversation]);
      emit(SuccessState(key: 'sendMessage'));
    } catch (error) {
      emit(ErrorState(error: error.toString(), key: 'sendMessage'));
      rethrow;
    }
  }

  void _organizeMessagesByDate(List<ConversationModel> messages) {
    if (messages.isEmpty || messages.last.dateTime == null) return;

    final messageDate = DateTime(
        messages.last.dateTime!.year,
        messages.last.dateTime!.month,
        messages.last.dateTime!.day
    );

    String header = date(messageDate: messageDate);

    final existingIndex = conversationsList.indexWhere(
            (group) => group.title == header
    );

    if (existingIndex != -1) {
      conversationsList[existingIndex].messages.addAll(messages);
    } else {
      conversationsList.insert(0, MessageGroup(
        title: header,
        messages: messages,
        sortDate: messageDate,
      ));
    }
  }

  Future<void> getOldMessages({required String docId}) async {
    try {
      emit(LoadingState(key: 'getOldMessages'));
      var query = FirebaseFirestore.instance
          .collection('messages')
          .doc(docId)
          .collection('conversations')
          .orderBy('dateTime', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final data = await query.limit(15).get();
      if (data.docs.isEmpty) {
        hasMessages = false;
        emit(SuccessState());
        return;
      }

      lastDocument = data.docs.last;
      final conversations = data.docs
          .map((doc) => ConversationModel.fromJson(json: doc.data()))
          .toList()
          .reversed
          .toList();

      final groupedData = groupMessagesByDate(conversations);

      groupedData.forEach((group) {
        final existingIndex = conversationsList.indexWhere(
                (g) => g.title == group.title
        );

        if (existingIndex != -1) {
          conversationsList[existingIndex].messages.insertAll(
              0, group.messages);
        } else {
          conversationsList.insert(0, group);
        }
      });

      emit(SuccessState(key: 'getOldMessages'));
    } catch (e) {
      emit(ErrorState(error: e.toString(), key: 'getOldMessages'));
    }
  }

  Stream<List<MessageGroup>> getNewMessages({
    required String docId,
  }) {
    var firestore = FirebaseFirestore.instance;
    var query = firestore.collection('messages')
        .doc(docId)
        .collection('conversations')
        .orderBy('dateTime', descending: true);

    if (firstDocument != null) {
      query = query.endBeforeDocument(firstDocument!);
    }

    if (conversationsList.isEmpty) {
      query = query.limit(15);
    }

    query.get();

    return query.snapshots().asyncMap((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      firstDocument = snapshot.docs.first;
      lastDocument = snapshot.docs.last;

      final conversations = snapshot.docs
          .map((doc) {
        if (doc.data()['senderId'] == currentId) {
          return null;
        }
        return ConversationModel.fromJson(
          json: Map<String, dynamic>.from(doc.data()),
        );
      })
          .where((conversation) => conversation != null)
          .toList()
          .reversed
          .toList();

      currentId = UserDetails.userId;
      return groupMessagesByDate(conversations.cast<ConversationModel>());
    });
  }

  List<MessageGroup> groupMessagesByDate(List<ConversationModel> messages) {
    if (messages.isEmpty) return [];

    Map<String, List<ConversationModel>> groupedMessages = {};

    for (var message in messages) {
      if (message.dateTime == null) continue;

      final messageDate = DateTime(
          message.dateTime!.year,
          message.dateTime!.month,
          message.dateTime!.day
      );

      String header = date(messageDate: messageDate);
      groupedMessages.putIfAbsent(header, () => []);
      groupedMessages[header]!.add(message);
    }

    return groupedMessages.entries.map((entry) {
      final date = DateTime(
          entry.value.last.dateTime!.year,
          entry.value.last.dateTime!.month,
          entry.value.last.dateTime!.day
      );

      return MessageGroup(
        title: entry.key,
        messages: entry.value,
        sortDate: date,
      );
    }).toList();
  }
}

