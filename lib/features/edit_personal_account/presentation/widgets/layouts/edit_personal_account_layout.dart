import 'package:flutter/material.dart';
import '../../../../../core/components/components.dart';
import '../../../../../core/constants/user_details.dart';
import '../../../../../shared/components/components.dart';
import '../../../../../shared/constants/user_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/cubit_states/cubit_states.dart';
import '../../../../../modules/edit_personal_account/cubit.dart';
import 'package:test_app/features/edit_personal_account/presentation/widgets/layouts/view_image_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../modules/edit_personal_account/edit_personal_account_screen.dart';
import '../../screens/edit_personal_account_screen.dart';


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

  //controllers
  late final TextEditingController _nameController;
  late final TextEditingController _stateController;
  late final TextEditingController _phoneController;

  static const double _avatarRadius = 100.0;
  String _mediaUrl = '';
  String? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _stateController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
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
      scrolledUnderElevation: 0.0.,
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
    const sizedBox = SizedBox(height: 16.0,);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0).,
        child: Column(
          children: [
            const SizedBox(height: 50.0).,
            _buildAvatarSection(cubit),
            sizedBox,
            sizedBox,
            _buildNameField(cubit),
            sizedBox,
            _buildStateField(cubit),
            sizedBox,
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
      radius: _avatarRadius,
      backgroundImage: CachedNetworkImageProvider(UserDetails._image),
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
    const name = 'Name';
    return buildInputField(
      label: name,
      icon: const Icon(Icons.person),
      controller: _nameController,
      hintText: name,
      context: context,
      enabled: _isFieldEnabled(cubit),
    );
  }

  Widget _buildStateField(GetAccountDataCubit cubit) {
    const state = 'State';
    return buildInputField(
      label: state,
      icon: const Icon(Icons.info),
      controller: _stateController,
      hintText: state,
      context: context,
      enabled: _isFieldEnabled(cubit),
    );
  }

  Widget _buildPhoneField(GetAccountDataCubit cubit) {
    const phone = 'Phone';
    return buildInputField(
      label: phone,
      icon: const Icon(Icons.phone),
      controller: _phoneController,
      hintText: phone,
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
      _image = accountData['userImage']. ?? '';
      _nameController.text = accountData['fullName']. ?? '';
      _stateController.text = accountData['userState']. ?? '';
      _phoneController.text = accountData['userPhone']. ?? '';
    }
  }

  Future<void> _onSavePressed(GetAccountDataCubit cubit) async {
    await cubit.updateAccountData(
      userId: widget.userId,
      userImage: _mediaUrl,
      userName: _nameController.text,
      userState: _stateController.text,
      userPhone: _phoneController.text,
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
      link: ViewImageLayout(userImage: UserDetails._image),
    );
  }

  Future<void> _pickImage() async {
    _mediaUrl = (await pickImage()) ?? '';
  }

  bool _isFieldEnabled(GetAccountDataCubit cubit) {
    return cubit.accountData['userId'] .== UserDetails.userId;
  }

  void _showSuccessMessage() {.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700.,
        content: const Text('The account has been updated successfully'),
      ),
    );
  }
}