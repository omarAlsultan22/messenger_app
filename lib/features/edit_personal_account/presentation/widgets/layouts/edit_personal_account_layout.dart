import 'package:flutter/material.dart';
import '../../../../../core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import '../../../../../core/utils/validate_input.dart';
import '../../screens/edit_personal_account_screen.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_strings.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_app/core/services/media_upload_service.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:test_app/core/presentation/widgets/build_snack_bar.dart';
import 'package:test_app/core/presentation/widgets/text_form_field.dart';
import 'package:test_app/core/presentation/widgets/navigation/navigator.dart';
import '../../../../auth/presentation/screens/change_email_and_password_screen.dart';
import 'package:test_app/features/edit_personal_account/data/models/account_model.dart';
import 'package:test_app/features/edit_personal_account/presentation/widgets/layouts/view_image_layout.dart';


class EditPersonalAccountLayout extends StatefulWidget {
  final Future <void> Function({
  required String userId,
  required String userImage,
  required String userName,
  required String userState,
  }) onUpdate;
  final String docId;
  final AccountModel accountModel;
  final MessageResult messageResult;
  const EditPersonalAccountLayout({
    super.key,
    required this.docId,
    required this.onUpdate,
    required this.accountModel,
    required this.messageResult
  });

  @override
  State<EditPersonalAccountLayout> createState() => _EditPersonalAccountLayoutState();
}

class _EditPersonalAccountLayoutState extends State<EditPersonalAccountLayout> {

  //controllers
  late final TextEditingController _nameController;
  late final TextEditingController _stateController;

  static const double _avatarRadius = 100.0;
  static const _sizedBox = SizedBox(height: 16.0);
  late final imageUrl = widget.accountModel.userImage;

  String _mediaUrl = '';
  String? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _stateController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant EditPersonalAccountLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageResult.message != null) {
      _showMessageResult(widget.messageResult);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    _initializeControllers();
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0.0,
      title: _buildAppBarTitle(),
      actions: [_buildSaveButton()],
    );
  }

  Widget _buildAppBarTitle() {
    return widget.docId == AppStrings.docId
        ? const Text('Edit Profile')
        : const Text('Friend Profile');
  }

  Widget _buildSaveButton() {
    if (widget.docId != AppStrings.docId) {
      return const SizedBox();
    }

    return IconButton(
      icon: const Icon(Icons.save),
      onPressed: () => _onSavePressed(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: AppPaddings.medium,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              _buildAvatarSection(),
              _sizedBox,
              _sizedBox,
              _buildNameField(),
              _sizedBox,
              _buildStateField(),
              AppSpaces.vertical_24,
              _buildChangePasswordButton(),
              _sizedBox,
            ],
          ),
        ),
      ),);
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        _buildAvatar(),
        _buildCameraButton(),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: _avatarRadius,
      child: GestureDetector(
        onTap: () => _viewImage(context),
        child: CachedNetworkImage(
          imageUrl: imageUrl ?? '',
          imageBuilder: (context, imageProvider) =>
              CircleAvatar(
                radius: _avatarRadius,
                backgroundImage: imageProvider,
              ),
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
          const CircleAvatar(
            radius: _avatarRadius,
            child: Icon(Icons.person, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    if (widget.docId != AppStrings.docId) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        bottom: 5.0,
        end: 5.0,
      ),
      child: IconButton(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera),
      ),
    );
  }

  Widget _buildNameField() {
    return BuildInputField(
      labelText: 'Name',
      prefixIcon: const Icon(Icons.person),
      controller: _nameController,
      hintText: 'Name',
      enabled: _isFieldEnabled(),
      validator: (value) => ValidateInput.validator(value!),
    );
  }

  Widget _buildStateField() {
    return BuildInputField(
      labelText: 'State',
      prefixIcon: const Icon(Icons.info),
      controller: _stateController,
      hintText: 'State',
      enabled: _isFieldEnabled(),
      validator: (value) => ValidateInput.validator(value!),
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: _changePasswordButtonStyle(),
        onPressed: _navigateToChangePassword,
        child: const Text(
          'Change email and password',
          style: TextStyle(
            fontSize: AppSizes.md,
            color: AppColors.amber_600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _initializeControllers() {
    _image = widget.accountModel.userImage ?? '';
    _nameController.text = widget.accountModel.userName ?? '';
    _stateController.text = widget.accountModel.userState ?? '';
  }

  Future<void> _onSavePressed() async {
    await widget.onUpdate(
      userId: widget.docId,
      userImage: _mediaUrl,
      userName: _nameController.text,
      userState: _stateController.text,
    ).then((_) {
      _refreshPage();
    });
  }

  void _refreshPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => EditPersonalAccountScreen(docId: widget.docId)
      ),
    );
  }

  void _viewImage(BuildContext context) {
    BuildNavigator.build(
      context: context,
      link: ViewImageLayout(userImage: imageUrl ?? ''),
    );
  }

  Future<void> _pickImage() async {
    final imageFile = await MediaUploadService.pickImage();
    if (imageFile != null) {
      _mediaUrl = await MediaUploadService.checkAndUploadFile(imageFile) ?? '';
    }
  }

  bool _isFieldEnabled() {
    return widget.accountModel.userId == AppStrings.docId;
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangeEmailAndPasswordScreen(),
      ),
    );
  }

  ButtonStyle _changePasswordButtonStyle() {
    return OutlinedButton.styleFrom(
        padding: AppPaddings.verticalSymmetric,
        side: const BorderSide(color: AppColors.amber_600),
        shape: const RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadius_12
        )
    );
  }

  void _showMessageResult(MessageResult messageResult) {
    BuildSnackBar.show(
        context: context,
        message: messageResult.message!,
        backgroundColor: messageResult.color!
    );
  }
}