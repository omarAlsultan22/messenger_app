import 'dart:ui';
import '../../data/models/data_model.dart';
import '../../data/models/user_status.dart';
import '../../data/models/message_group.dart';
import '../../data/models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/data/models/message_result_model.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import 'package:test_app/core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/states/base/main_app_sub_state.dart';
import 'package:test_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:test_app/features/conversation/data/models/conversation_success_state.dart';


class ConversationState extends MainAppSupState {
  final DataModel dataModel;
  final UserStatus userStatus;
  final MessageResult messageResult;

  const ConversationState({
    super.subState,
    required this.dataModel,
    required this.userStatus,
    required this.messageResult
  });

  factory ConversationState.initial(){
    return ConversationState(
      subState: InitialState(),
      dataModel: DataModel(),
      userStatus: UserStatus(),
      messageResult: MessageResult.initial(),
    );
  }

  bool get listISEmpty => dataModel.listISEmpty;

  bool get hasMessages => dataModel.hasMessages;

  DocumentSnapshot? get firstDocument => dataModel.firstDocument;

  DocumentSnapshot? get lastDocument => dataModel.lastDocument;

  List<MessageGroup> get conversationList => dataModel.conversationList;

  void addMessageGroup(MessageGroup group) =>
      dataModel.addMessageGroup(group);

  void addNewMessages({
    required int existingIndex,
    required List<ConversationModel> messages
  }) =>
      dataModel.addNewMessages(
          existingIndex: existingIndex, messages: messages);

  void insertMessages({
    required String? title,
    required DateTime sortDate,
    required List<ConversationModel> messages}) =>
      dataModel.insertMessage(
          title: title,
          sortDate: sortDate,
          messages: messages
      );

  void insertAllMessages({
    required int existingIndex,
    required List<ConversationModel> messages
  }) =>
      dataModel.insertAllMessages(
          messages: messages,
          existingIndex: existingIndex
      );

  int existingIndex(String? date) =>
      conversationList.indexWhere(
              (g) => g.date == date
      );

  void clearList() => dataModel.clearList();

  UserStatus updateFirstModel({
    DateTime? lastSeen,
    String? bgImage,
    bool? isOnline,
    bool? isTyping,
    Color? bgColor
  }) {
    return userStatus.copyWith(
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
    return dataModel.copyWith(
        conversationList: conversationList,
        firstDocument: firstDocument,
        lastDocument: lastDocument,
        hasMessages: hasMessages
    );
  }

  // States
  ConversationState setLoadingState(){
    return copyWith(subState: LoadingState());
  }

  ConversationState setSuccessState(){
    return copyWith(subState: SuccessState());
  }

  ConversationState setSuccessStateWithSuccessMessage({String? message}){
    return copyWith(subState: SuccessState(), messageResult: MessageResult.success(message: message));
  }

  ConversationState setErrorState(AppException failure) {
    return copyWith(
        messageResult: MessageResult.error(
            error: failure
        )
    );
  }

  ConversationState copyWith({
    UserStatus? userStatus,
    DataModel? dataModel,
    MessageResult? messageResult,
    MainAppSubState? subState
  }) {
    return ConversationState(
      subState: subState ?? this.subState,
      dataModel: dataModel ?? this.dataModel,
      userStatus: userStatus ?? this.userStatus,
      messageResult: messageResult ?? MessageResult.initial(),
    );
  }

  @override
  ConversationSuccessState get dataModels =>
      ConversationSuccessState(
          dataModel: dataModel,
          userStatus: userStatus,
          messageResult: messageResult
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(ConversationSuccessState) onLoaded,
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