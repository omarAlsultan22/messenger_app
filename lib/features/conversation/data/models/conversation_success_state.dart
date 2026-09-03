import 'data_model.dart';
import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import 'package:test_app/features/conversation/data/models/user_status.dart';


class ConversationSuccessState extends LoadedState {
  final DataModel dataModel;
  final UserStatus userStatus;
  final MessageResult messageResult;

  const ConversationSuccessState({
    required this.dataModel,
    required this.userStatus,
    required this.messageResult
  });
}