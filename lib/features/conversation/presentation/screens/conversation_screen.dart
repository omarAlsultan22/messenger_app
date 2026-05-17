import '../cubits/cubit.dart';
import '../widgets/layouts/conversation_layout.dart';
import 'package:flutter/material.dart';
import '../../../../core/data/models/last_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../online_status_service/online_status_service.dart';


class ConversationScreen extends StatelessWidget {
  final LastMessageModel lastMessageModel;
  final OnlineStatusService onlineStatusService;

  const ConversationScreen({
    required this.lastMessageModel,
    required this.onlineStatusService,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsCubit()
        ..getConversation(docId: lastMessageModel.docId)
        ..getUserOnlineStatus(onlineStatusService, lastMessageModel.userId!)
        ..getUserLastSeen(onlineStatusService, lastMessageModel.userId!)
        ..getUserTypingStatus(onlineStatusService, lastMessageModel.userId!)
        ..updateUnreadMessages(lastMessageModel.docId),
      child: ConversationLayout(
        lastMessageModel: lastMessageModel,
        onlineStatusService: onlineStatusService,
      ),
    );
  }
}