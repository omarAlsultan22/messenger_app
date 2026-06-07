import '../chats_list.dart';
import '../stories_list.dart';
import '../chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme_notifier.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_strings.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/online_status_service.dart';
import '../../../../../core/data/models/last_message_model.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';
import 'package:test_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';
import '../../../../conversation/presentation/screens/conversation_screen.dart';
import '../../../../edit_personal_account/presentation/screens/edit_personal_account_screen.dart';


class HomeLayout extends StatefulWidget {
  final String profileImage;
  final CacheHelper cacheHelper;
  final List<LastMessageModel> friendList;
  const HomeLayout({
    super.key,
    required this.profileImage,
    required this.cacheHelper,
    required this.friendList
  });

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {

  final _onlineStatusService = OnlineStatusService();
  final _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();

  List<LastMessageModel> _filteredData = [];
  bool _isDarkMode = false;

  static const _heightValue = 20.0;
  static const _verticalSpacing = SizedBox(height: _heightValue);

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchController.removeListener(_performSearch);
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

    setState(() {
      _filteredData = query.isEmpty
          ? widget.friendList
          : widget.friendList.where((item) =>
          item.userName!.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _toggleThemeMode() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    setState(() => _isDarkMode = !_isDarkMode);

    final newThemeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await widget.cacheHelper.setString(key: 'themeColor', value: newThemeMode.toString());
    themeNotifier.setThemeMode(newThemeMode);
  }

  void _navigateToConversation(LastMessageModel lastMessageModel) {
    if (lastMessageModel.isEmpty) return;

    setState(() {
      lastMessageModel.copyWith(unreadMessagesCount: 0);
    });

    BuildNavigator.build(
      context: context,
      link: ConversationScreen(
        lastMessageModel: lastMessageModel,
        onlineStatusService: _onlineStatusService,
      ),
    );
  }

  void _navigateToProfile() {
    BuildNavigator.build(
      context: context,
      link: EditPersonalAccountScreen(docId: AppStrings.docId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        profileImage: widget.profileImage,
        onProfilePressed: _navigateToProfile,
        onThemeToggle: _toggleThemeMode,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: AppPaddings.large,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5.0),
            BuildInputField(
                labelText: 'Search',
                controller: _searchController,
                hintText: 'Search for friends...',
                prefixIcon: const Icon(Icons.search)),
            _verticalSpacing,
            StoriesList(
              friends: widget.friendList,
              onFriendTap: (friend)=> _navigateToConversation(friend),
            ),
        _verticalSpacing,
            ChatsList(
              filteredData: _filteredData,
              searchController: _searchController,
              onChatTap: (friend)=> _navigateToConversation(friend),
            ),
          ],
        ),
      ),
    );
  }
}