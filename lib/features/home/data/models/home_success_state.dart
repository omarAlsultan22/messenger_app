import '../../../../core/data/models/last_message_model.dart';
import 'package:test_app/core/presentation/states/base/main_loaded_state.dart';


class HomeSuccessState extends LoadedState {
  final String profileImage;
  final List<LastMessageModel> friendList;

  const HomeSuccessState({
    required this.friendList,
    required this.profileImage,
  });
}