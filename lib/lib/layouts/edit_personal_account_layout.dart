import 'package:test_app/lib/modules/edit_personal_account/cubit.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/components/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/components/constants.dart';
import 'package:flutter/material.dart';


class EditPersonalAccountLayout extends StatefulWidget {
  final String userId;

  const EditPersonalAccountLayout({
    required this.userId,
    super.key
  });

  @override
  State<EditPersonalAccountLayout> createState() => _EditPersonalAccountLayoutState();
}

class _EditPersonalAccountLayoutState extends State<EditPersonalAccountLayout> {
  late final TextEditingController nameController;
  late final TextEditingController stateController;
  late final TextEditingController phoneController;

  static const double avatarRadius = 100.0;
  String mediaUrl = '';
  String? image;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    stateController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    stateController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetAccountDataCubit, CubitStates>(
      listener: _blocListener,
      builder: (context, state) => _buildMainContent(context, state),
    );
  }

  Widget _buildMainContent(BuildContext context, CubitStates state) {
    final cubit = GetAccountDataCubit.get(context);

    if (state is LoadingState) {
      return _buildLoadingState();
    }

    if (state is SuccessState) {
      _initializeControllers(cubit);
    }

    return Scaffold(
      appBar: _buildAppBar(cubit),
      body: _buildBody(cubit),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  AppBar _buildAppBar(GetAccountDataCubit cubit) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      title: _buildAppBarTitle(),
      actions: [_buildSaveButton(cubit)],
    );
  }

  Widget _buildAppBarTitle() {
    return widget.userId == UserDetails.userId
        ? const Text('Edit Profile')
        : const Text('Friend Profile');
  }

  Widget _buildSaveButton(GetAccountDataCubit cubit) {
    if (widget.userId != UserDetails.userId) {
      return const SizedBox();
    }

    return IconButton(
      icon: const Icon(Icons.save),
      onPressed: () => _onSavePressed(cubit),
    );
  }

  Widget _buildBody(GetAccountDataCubit cubit) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50.0),
            _buildAvatarSection(cubit),
            sizeBox(),
            sizeBox(),
            _buildNameField(cubit),
            sizeBox(),
            _buildStateField(cubit),
            sizeBox(),
            _buildPhoneField(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(GetAccountDataCubit cubit) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        _buildAvatar(),
        _buildCameraButton(cubit),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: avatarRadius,
      backgroundImage: CachedNetworkImageProvider(image ?? ''),
      child: GestureDetector(
        onTap: () => _viewImage(context),
      ),
    );
  }

  Widget _buildCameraButton(GetAccountDataCubit cubit) {
    if (widget.userId != UserDetails.userId) {
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

  Widget _buildNameField(GetAccountDataCubit cubit) {
    return buildInputField(
      label: 'Name',
      icon: const Icon(Icons.person),
      controller: nameController,
      hintText: 'Name',
      context: context,
      enabled: _isFieldEnabled(cubit),
    );
  }

  Widget _buildStateField(GetAccountDataCubit cubit) {
    return buildInputField(
      label: 'State',
      icon: const Icon(Icons.info),
      controller: stateController,
      hintText: 'State',
      context: context,
      enabled: _isFieldEnabled(cubit),
    );
  }

  Widget _buildPhoneField(GetAccountDataCubit cubit) {
    return buildInputField(
      label: 'Phone',
      icon: const Icon(Icons.phone),
      controller: phoneController,
      hintText: 'Phone',
      keyboardType: TextInputType.phone,
      context: context,
      enabled: _isFieldEnabled(cubit),
    );
  }

  void _blocListener(BuildContext context, CubitStates state) {
    if (state is SuccessState) {
      _showSuccessMessage();
    }
  }

  void _initializeControllers(GetAccountDataCubit cubit) {
    final accountData = cubit.accountData;

    if (accountData.isNotEmpty) {
      image = accountData['userImage'] ?? '';
      nameController.text = accountData['fullName'] ?? '';
      stateController.text = accountData['userState'] ?? '';
      phoneController.text = accountData['userPhone'] ?? '';
    }
  }

  Future<void> _onSavePressed(GetAccountDataCubit cubit) async {
    await cubit.updateAccountData(
      userId: widget.userId,
      userImage: mediaUrl,
      userName: nameController.text,
      userState: stateController.text,
      userPhone: phoneController.text,
    ).then((_) {
      _refreshPage();
    });
  }

  void _refreshPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => EditPersonalAccountScreen(userId: widget.userId)
      ),
    );
  }

  void _viewImage(BuildContext context) {
    navigator(
      context: context,
      link: ViewImage(userImage: image ?? ''),
    );
  }

  Future<void> _pickImage() async {
    mediaUrl = (await pickImageOrVideo()) ?? '';
  }

  bool _isFieldEnabled(GetAccountDataCubit cubit) {
    return cubit.accountData['userId'] == UserDetails.userId;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: const Text('The account has been updated successfully'),
      ),
    );
  }
}