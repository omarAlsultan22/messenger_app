import 'dart:ui';
import '../../data/models/data_model.dart';
import '../../data/models/user_status.dart';
import '../../data/models/message_group.dart';
import '../../data/models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/data/models/message_result_model.dart';
import 'package:test_app/core/presentation/states/app_sup_states.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import 'package:test_app/core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/states/base/main_loaded_state.dart';
import 'package:test_app/core/presentation/states/base/main_app_sub_state.dart';


class ConversationState extends TripleModelAppState<UserStatus, DataModel, MessageResult> {
  ConversationState({
    super.subState,
    super.firstModel,
    super.secondModel,
    super.thirdModel
  });

  factory ConversationState.initial(){
    return ConversationState(
        firstModel: null,
        secondModel: DataModel(),
        thirdModel: MessageResult.initial(),
        subState: InitialState());
  }

  bool get listISEmpty => secondModel!.listISEmpty;

  DocumentSnapshot? get firstDocument => secondModel!.firstDocument;

  DocumentSnapshot? get lastDocument => secondModel!.lastDocument;

  List<MessageGroup> get conversationList => secondModel!.conversationList;

  void addMessageGroup(MessageGroup group) =>
      secondModel!.addMessageGroup(group);

  void addNewMessages({
    required int existingIndex,
    required List<ConversationModel> messages
  }) =>
      secondModel!.addNewMessages(
          existingIndex: existingIndex, messages: messages);

  void insertMessages({
    required String? title,
    required DateTime sortDate,
    required List<ConversationModel> messages}) =>
      secondModel!.insertMessage(
          title: title,
          sortDate: sortDate,
          messages: messages
      );

  void insertAllMessages({
    required int existingIndex,
    required List<ConversationModel> messages
  }) =>
      secondModel!.insertAllMessages(
          messages: messages,
          existingIndex: existingIndex
      );

  int existingIndex(String? date) =>
      conversationList.indexWhere(
              (g) => g.date == date
      );

  void clearList() => secondModel!.clearList();

  UserStatus updateFirstModel({
    DateTime? lastSeen,
    String? bgImage,
    bool? isOnline,
    bool? isTyping,
    Color? bgColor
  }) {
    return firstModel!.copyWith(
      lastSeen: lastSeen,
      bgImage: bgImage,
      isOnline: isOnline,
      isTyping: isTyping,
      bgColor: bgColor,
    );
  }

  DataModel updateSecondModel({
    List<MessageGroup>? conversationList,
    DocumentSnapshot? firstDocument,
    DocumentSnapshot? lastDocument,
    bool? hasMessages,
  }) {
    return secondModel!.copyWith(
        conversationList: conversationList,
        firstDocument: firstDocument,
        lastDocument: lastDocument,
        hasMessages: hasMessages
    );
  }

  @override
  ConversationState copyWith({
    UserStatus? firstModel,
    DataModel? secondModel,
    MessageResult? thirdModel,
    MainAppSubState? subState
  }) {
    return ConversationState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
      secondModel: secondModel ?? this.secondModel,
      thirdModel: thirdModel ?? this.thirdModel,
    );
  }

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState!.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () =>
            onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure));
  }
}