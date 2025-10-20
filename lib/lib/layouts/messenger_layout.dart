import 'cubit.dart';
import '../main.dart';
import 'widgets/chats_list.dart';
import 'widgets/search_field.dart';
import 'widgets/stories_list.dart';
import 'package:flutter/material.dart';
import 'widgets/messenger_app_bar.dart';
import 'package:provider/provider.dart';
import '../models/last_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/components/constants.dart';
import '../shared/cubit_states/cubit_states.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/conversation_screen/conversation_screen.dart';
import '../modules/notification_service/notification_service.dart';
import '../modules/online_status_service/online_status_service.dart';
import '../modules/edit_personal_account/edit_personal_account_screen.dart';


class MessengerLayout extends StatefulWidget {
  const MessengerLayout({super.key});

  @override
  State<MessengerLayout> createState() => _MessengerLayoutState();
}

class _MessengerLayoutState extends State<MessengerLayout> {
  final TextEditingController _searchController = TextEditingController();
  final OnlineStatusService _onlineStatusService = OnlineStatusService();
  final NotificationService _notificationService = NotificationService();

  List<LastMessageModel> _filteredData = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _onlineStatusService.initialize();
    await _notificationService.initialize();
    await _notificationService.subscribeToTopic('all_users');
  }

  void _setupSearchListener() {
    _searchController.addListener(_performSearch);
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    final friendList = MainScreenCubit.get(context).friendsList;

    setState(() {
      _filteredData = query.isEmpty
          ? friendList
          : friendList.where((item) =>
          item.userName!.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _toggleThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    setState(() => _isDarkMode = !_isDarkMode);

    final newThemeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString('themeColor', newThemeMode.toString());
    themeNotifier.setThemeMode(newThemeMode);
  }

  void _navigateToConversation(LastMessageModel lastMessageModel) {
    if (lastMessageModel.docId.isEmpty) return;

    setState(() {
      lastMessageModel.unreadMessagesCount = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          lastMessageModel: lastMessageModel,
          onlineStatusService: _onlineStatusService,
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonalAccount(userId: UserDetails.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainScreenCubit, CubitStates>(
      listener: _blocListener,
      builder: (context, state) {
        final cubit = MainScreenCubit.get(context);
        final friendList = cubit.friendsList;
        final profileImage = cubit.profileImage;

        if (friendList.isNotEmpty && _searchController.text.isEmpty) {
          _filteredData = friendList;
        }

        return Scaffold(
          appBar: MessengerAppBar(
            profileImage: profileImage,
            onProfilePressed: _navigateToProfile,
            onThemeToggle: _toggleThemeMode,
          ),
          body: _buildBody(state, friendList),
        );
      },
    );
  }

  Widget _buildBody(CubitStates state, List<LastMessageModel> friendList) {
    if (state is! SuccessState && state.stateKey == StatesKeys.getFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(controller: _searchController),
            const SizedBox(height: 20.0),
            StoriesList(
              friends: friendList,
              onFriendTap: _navigateToConversation,
            ),
            const SizedBox(height: 20.0),
            ChatsList(
              filteredData: _filteredData,
              searchController: _searchController,
              onChatTap: _navigateToConversation,
            ),
          ],
        ),
      ),
    );
  }

  void _blocListener(BuildContext context, CubitStates state) {
    if (state is ErrorState && state.stateKey == StatesKeys.getFriends) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  }
}