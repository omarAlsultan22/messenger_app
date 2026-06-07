import 'message_group.dart';
import 'conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DataModel {
  List<MessageGroup> conversationList;
  DocumentSnapshot? firstDocument;
  DocumentSnapshot? lastDocument;
  bool hasMessages;

  DataModel({
    this.conversationList = const [],
    this.hasMessages = true,
    this.firstDocument,
    this.lastDocument,
  });

  bool get listISEmpty => conversationList.isEmpty;

  void addMessageGroup(MessageGroup group) =>
      conversationList.add(group);

  void insertAllMessages({
    required int existingIndex,
    required List<ConversationModel> messages
  }) =>
      conversationList[existingIndex].insertAllMessages(messages);

  void insertMessage({
    required String? title,
    required DateTime sortDate,
    required List<ConversationModel> messages
  }) =>
      conversationList.insert(0, MessageGroup(
        date: title,
        sortDate: sortDate,
        messages: messages,
      ));

  void addNewMessages({
    required int existingIndex,
    required List<ConversationModel> messages
  }) => conversationList[existingIndex].addNewMessages(messages: messages);

  void clearList() => conversationList.clear();

  DataModel copyWith({
    List<MessageGroup>? conversationList,
    DocumentSnapshot? firstDocument,
    DocumentSnapshot? lastDocument,
    bool? hasMessages,
  }) {
    return DataModel(
      conversationList: conversationList ?? this.conversationList,
      firstDocument: firstDocument ?? this.firstDocument,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMessages: hasMessages ?? this.hasMessages,
    );
  }
}