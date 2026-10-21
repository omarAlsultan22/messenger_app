import '../chats_list.dart';
import '../stories_list.dart';
import '../chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/themes/theme_notifier.dart';
import '../../../../../core/constants/app_paddings.dart';
import '../../../../../core/data/models/last_message_model.dart';
import 'package:test_app/core/services/data/session_service.dart';
import '../../../../../core/presentation/widgets/build_input_field.dart';
import '../../../../../core/services/domain/i_notification_service.dart';
import '../../../../../core/services/domain/i_online_status_service.dart';
import 'package:test_app/core/data/data_sources/local/cache_helper_impl.dart';
import 'package:test_app/core/presentation/widgets/navigation/navigator.dart';
import '../../../../conversation/presentation/screens/conversation_screen.dart';
import '../../../../edit_personal_account/presentation/screens/edit_personal_account_screen.dart';


class HomeLayout extends StatefulWidget {
  final String profileImage;
  final CacheHelperImpl cacheHelper;
  final SessionService sessionService;
  final List<LastMessageModel> friendList;
  final IOnlineStatusService onlineStatusService;
  final INotificationService notificationService;
  const HomeLayout({
    required this.notificationService,
    required this.onlineStatusService,
    required this.sessionService,
    required this.profileImage,
    required this.cacheHelper,
    required this.friendList,
    super.key
  });

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {

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
    await widget.onlineStatusService.initialize();
    await widget.notificationService.initialize();
    await widget.notificationService.subscribeToTopic('all_users');
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
          item.firstName!.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _toggleThemeMode() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    setState(() => _isDarkMode = !_isDarkMode);

    final newThemeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await widget.cacheHelper.setString(
        key: 'themeColor', value: newThemeMode.toString());
    themeNotifier.setTheme(newThemeMode);
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
      ),
    );
  }

  void _navigateToProfile() {
    BuildNavigator.build(
      context: context,
      link: EditPersonalAccountScreen(docId: widget.sessionService.currentUid),
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
              onFriendTap: (friend) => _navigateToConversation(friend),
            ),
            _verticalSpacing,
            ChatsList(
              filteredData: _filteredData,
              searchController: _searchController,
              onChatTap: (friend) => _navigateToConversation(friend),
            ),
          ],
        ),
      ),
    );
  }
}