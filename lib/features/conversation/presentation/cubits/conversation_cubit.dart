import 'dart:async';
import '../../utils/date_converter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/conversation_model.dart';
import '../../domain/useCases/send_message_use_case.dart';
import '../../domain/useCases/update_typing_use_case.dart';
import '../../domain/useCases/get_background_use_case.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import '../../domain/useCases/delete_messages_use_case.dart';
import '../../../../core/services/online_status_service.dart';
import '../../domain/useCases/get_old_messages_use_case.dart';
import '../../domain/useCases/get_conversations_use_case.dart';
import '../../domain/useCases/clear_conversations_use_case.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../domain/useCases/update_unread_messages_use_case.dart';
import 'package:test_app/core/errors/exceptions/firebase_app_exception.dart';
import 'package:test_app/features/conversation/presentation/states/conversation_state.dart';


class ConversationCubit extends Cubit<ConversationState> {
  final GetBackgroundUseCase _getBackgroundUseCase;
  final UpdateUnreadMessagesUseCase _updateUnreadMessagesUseCase;
  final GetConversationsUseCase _getConversationsUseCase;
  final GetOldMessagesUseCase _getOldMessagesUseCase;
  final ClearConversationsUseCase _clearConversationsUseCase;
  final DeleteMessagesUseCase _deleteMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final UpdateTypingUseCase _updateTypingUseCase;
  final OnlineStatusService _onlineStatusService;

  ConversationCubit({
    required GetBackgroundUseCase getBackgroundUseCase,
    required UpdateUnreadMessagesUseCase updateUnreadMessagesUseCase,
    required GetConversationsUseCase getConversationsUseCase,
    required GetOldMessagesUseCase getOldMessagesUseCase,
    required ClearConversationsUseCase clearConversationsUseCase,
    required DeleteMessagesUseCase deleteMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required UpdateTypingUseCase updateTypingUseCase,
    required OnlineStatusService onlineStatusService,
  })
      : _getBackgroundUseCase = getBackgroundUseCase,
        _updateUnreadMessagesUseCase = updateUnreadMessagesUseCase,
        _getConversationsUseCase = getConversationsUseCase,
        _getOldMessagesUseCase = getOldMessagesUseCase,
        _clearConversationsUseCase = clearConversationsUseCase,
        _deleteMessagesUseCase = deleteMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _updateTypingUseCase = updateTypingUseCase,
        _onlineStatusService = onlineStatusService,
        super(ConversationState.initial());

  static ConversationCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _interactionsSubscription;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _lastSeenSubscription;
  StreamSubscription? _onlineSubscription;

  Future<void> updateTyping(bool isTyping) async {
    await _updateTypingUseCase.execute(isTyping);
  }

  Future<void> getSavedBackgroundColorAndImage(String docId) async {
    final result = await _getBackgroundUseCase.execute(docId: docId);
    final userStatus = state.updateFirstModel(
        bgImage: result['bgImage'], bgColor: result['bgColor']);
    emit(state.copyWith(firstModel: userStatus));
  }

  Future<void> updateUnreadMessages(String docId) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      await _updateUnreadMessagesUseCase.execute(docId: docId);
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(error: exception)));
    }
  }

  Future<void> getConversation({
    required String docId,
    required String? senderId
  }) async {
    emit(state.copyWith(subState: LoadingState()));
    _conversationsSubscription?.cancel();

    _conversationsSubscription = _getConversationsUseCase.execute(
      docId: docId,
      senderId: senderId,
      firstDocument: state.firstDocument,
      lastDocument: state.lastDocument,
      isEmptyList: state.listISEmpty,
    ).listen((messageGroups) {
      for (final group in messageGroups.conversationList) {
        final existingIndex = state.existingIndex(group.date);

        if (existingIndex != -1) {
          state.addNewMessages(
              existingIndex: existingIndex, messages: group.messages);
        } else {
          state.addMessageGroup(group);
        }
      }
      emit(state.copyWith(subState: SuccessState()));
    }, onError: (e) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: StackTrace.current
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(error: exception)));
    });
  }

  void getUserOnlineStatus(String userId) {
    _onlineSubscription =
        _onlineStatusService.getUserOnlineStatus(userId).listen((value) {
          final userStatus = state.updateFirstModel(isOnline: value);
          emit(state.copyWith(firstModel: userStatus));
        });
  }

  void getUserTypingStatus(String userId) {
    _onlineSubscription =
        _onlineStatusService.getUserTypingStatus(userId).listen((value) {
          final userStatus = state.updateFirstModel(isTyping: value);
          emit(state.copyWith(firstModel: userStatus));
        });
  }

  void getUserLastSeen(String userId) {
    _lastSeenSubscription =
        _onlineStatusService.getUserLastSeen(userId).listen((value) {
          final userStatus = state.updateFirstModel(lastSeen: value);
          emit(state.copyWith(firstModel: userStatus));
        });
  }

  Future<void> clearConversationsList({required String docId}) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      state.clearList();
      await _clearConversationsUseCase.execute(docId: docId);
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(error: exception)));
    }
  }

  Future<void> deleteMessages({
    required List<String> messagesIds,
    required String docId,
  }) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      await _deleteMessagesUseCase.execute(
        docId: docId,
        messagesIds: messagesIds,
        conversationList: state.conversationList,
      );
      emit(state.copyWith(subState: SuccessState()));
    } catch (e) {
      final exception = FirebaseAppException(
          message: 'Error deleting messages: ${e.toString()}');
      emit(state.copyWith(subState: ErrorState(error: exception)));
    }
  }

  Future<void> sendMessage({
    required String docId,
    required String userId,
    required ConversationModel conversation,
  }) async {
    try {
      await _sendMessageUseCase.execute(
        docId: docId,
        conversation: conversation,
        conversationsList: state.conversationList,
        organizeMessages: (messages) => _organizeMessagesByDate(messages),
      );
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(error: exception)));
    }
  }

  void _organizeMessagesByDate(List<ConversationModel> messages) {
    if (messages.isEmpty || messages.last.dateTime == null) return;

    final messageDate = DateTime(
        messages.last.dateTime!.year,
        messages.last.dateTime!.month,
        messages.last.dateTime!.day
    );

    final header = DateConverter.getDateHeader(messageDate);

    final existingIndex = state.existingIndex(header);


    if (existingIndex != -1) {
      state.addNewMessages(existingIndex: existingIndex, messages: messages);
    } else {
      state.insertMessages(
          title: header, sortDate: messageDate, messages: messages);
    }
  }

  Future<void> getOldMessages({required String docId}) async {
    try {
      emit(state.copyWith(subState: LoadingState()));

      final dataModel = await _getOldMessagesUseCase.execute(
        docId: docId,
        lastDocument: state.lastDocument,
      );

      if (dataModel.listISEmpty) {
        final dataModel = state.updateSecondModel(hasMessages: false);
        emit(state.copyWith(
            subState: SuccessState(), secondModel: dataModel));
        return;
      }

      for (var group in dataModel.conversationList) {
        final existingIndex = state.existingIndex(group.date);
        if (existingIndex != -1) {
          state.insertAllMessages(
              existingIndex: existingIndex, messages: group.messages);
        } else {
          state.insertMessages(
              title: group.date,
              sortDate: group.sortDate,
              messages: group.messages
          );
        }
      }

      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(error: exception)));
    }
  }

  @override
  Future<void> close() async {
    _conversationsSubscription?.cancel();
    _onlineSubscription?.cancel();
    _lastSeenSubscription?.cancel();
    await _interactionsSubscription?.cancel();
    return super.close();
  }
}
