import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/lib/layouts/conversation_layout.dart';
import 'package:test_app/lib/shared/components/components.dart';
import '../main.dart';
import '../models/last_message_model.dart';
import '../modules/edit_personal_account/edit_personal_account.dart';
import '../modules/messenger_screen/cubit.dart';
import '../modules/notification_service/notification_service.dart';
import '../modules/online_status_service/online_status_service.dart';
import '../shared/components/constants.dart';
import '../shared/cubit_states/cubit_states.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
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
        builder: (context) => ConversationLayout(
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
      listener: (context, state) {
        if (state is ErrorState && state.key == 'getFriends') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = MainScreenCubit.get(context);
        final friendList = cubit.friendsList;
        final profileImage = cubit.profileImage;

        if (friendList.isNotEmpty && _searchController.text.isEmpty) {
          _filteredData = friendList;
        }

        return Scaffold(
          appBar: _buildAppBar(profileImage),
          body: _buildBody(state, friendList),
        );
      },
    );
  }

  AppBar _buildAppBar(String profileImage) {
    return AppBar(
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
      titleSpacing: 20.0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(profileImage),
          ),
          const SizedBox(width: 15.0),
          const Text('Chats'),
        ],
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            radius: 15.0,
            backgroundColor: Colors.blue,
            child: Icon(Icons.edit, size: 16.0, color: Colors.white),
          ),
          onPressed: _navigateToProfile,
        ),
        IconButton(
          icon: const CircleAvatar(
            radius: 15.0,
            backgroundColor: Colors.blue,
            child: Icon(Icons.brightness_4_outlined, size: 16.0, color: Colors.white),
          ),
          onPressed: _toggleThemeMode,
        ),
      ],
    );
  }

  Widget _buildBody(CubitStates state, List<LastMessageModel> friendList) {
    if (state is! SuccessState && state.key == 'getFriends') {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            const SizedBox(height: 20.0),
            _buildStoriesList(friendList),
            const SizedBox(height: 20.0),
            _buildChatsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: buildInputField(
        context: context,
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesList(List<LastMessageModel> friendList) {
    return SizedBox(
      height: 106.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _buildStoryItem(friendList[index]),
        separatorBuilder: (context, index) => const SizedBox(width: 20.0),
        itemCount: friendList.length,
      ),
    );
  }

  Widget _buildStoryItem(LastMessageModel lastMessageModel) {
    return SizedBox(
      width: 60.0,
      child: InkWell(
        onTap: () => _navigateToConversation(lastMessageModel),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(lastMessageModel.userImage!),
                ),
                if (lastMessageModel.isOnline == true)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 3.0, end: 3.0),
                    child: CircleAvatar(
                      radius: 7.0,
                      backgroundColor: Colors.blue,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              lastMessageModel.userName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_filteredData.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => _buildChatItem(_filteredData[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 20.0),
      itemCount: _filteredData.length,
    );
  }

  Widget _buildChatItem(LastMessageModel lastMessageModel) {
    if (lastMessageModel.docId.isEmpty) return const SizedBox();

    return InkWell(
      onTap: () => _navigateToConversation(lastMessageModel),
      child: Row(
        children: [
          _buildUserAvatarWithBadge(lastMessageModel),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastMessageModel.userName ?? '',
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessageModel.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildMessageTimeIndicator(lastMessageModel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatarWithBadge(LastMessageModel lastMessageModel) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          radius: 30.0,
          backgroundImage: NetworkImage(lastMessageModel.userImage!),
        ),
        if (lastMessageModel.unreadMessagesCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Text(
                lastMessageModel.unreadMessagesCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsetsDirectional.only(bottom: 3.0, end: 3.0),
          child: CircleAvatar(
            radius: 7.0,
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTimeIndicator(LastMessageModel lastMessageModel) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            width: 7.0,
            height: 7.0,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(formatTime(lastMessageModel.lastMessageDateTime)),
      ],
    );
  }
}