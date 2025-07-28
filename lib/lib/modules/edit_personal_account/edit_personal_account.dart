import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/lib/modules/edit_personal_account/cubit.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class EditPersonalAccount extends StatefulWidget {
  final String userId;
  const EditPersonalAccount({
    required this.userId, super.key
  });

  @override
  State<EditPersonalAccount> createState() => _EditPersonalAccountState();
}

class _EditPersonalAccountState extends State<EditPersonalAccount> {
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
    return BlocProvider(create: (create) =>
    GetAccountDataCubit()
      ..getAccountData(userId: widget.userId),
        child: BlocConsumer<GetAccountDataCubit, CubitStates>(
          listener: (context, state) {
            if (state is SuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.green.shade700,
                      content: const Text(
                          'The account has been updated successfully')));
            }
          },
          builder: (context, state) {
            final cubit = GetAccountDataCubit.get(context);

            if (state is LoadingState) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is SuccessState) {
              final accountData = cubit.accountData;

              print(accountData);
              if (accountData.isNotEmpty) {
                image = accountData['userImage'] ?? '';
                nameController.text = accountData['fullName'] ?? '';
                stateController.text = accountData['userState'] ?? '';
                phoneController.text = accountData['userPhone'] ?? '';
              }
            }

            return Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0.0,
                title: widget.userId == UserDetails.userId
                    ? const Text('Edit Profile')
                    : const Text('Friend Profile'),
                actions: [
                  widget.userId == UserDetails.userId ?
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () =>
                        cubit.updateAccountData(
                            userId: widget.userId,
                            userImage: mediaUrl,
                            userName: nameController.text,
                            userState: stateController.text,
                            userPhone: phoneController.text
                        ).then((_) {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) =>
                              EditPersonalAccount(userId: widget.userId)));
                        }),
                  ) : const SizedBox(),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 50.0),
                      Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          CircleAvatar(
                              radius: avatarRadius,
                              backgroundImage: CachedNetworkImageProvider(
                                  image ?? ''),
                              child: GestureDetector(
                                onTap: ()=> navigator(context: context,
                                    link: ViewImage(userImage: image ?? '')),
                              ),
                            ),
                          widget.userId == UserDetails.userId ? Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 5.0,
                              end: 5.0,
                            ),
                            child: IconButton(
                                onPressed: () async {
                                  mediaUrl = (await pickImageOrVideo())!;
                                },
                                icon: const Icon(Icons.camera)),
                          ) : const SizedBox(),
                        ],
                      ),
                      sizeBox(),
                      sizeBox(),
                      buildInputField(
                          label: 'Name',
                          icon: const Icon(Icons.person),
                          controller: nameController,
                          hintText: 'Name',
                          context: context,
                          enabled: cubit.accountData['userId'] == UserDetails.userId
                              ? true
                              : false
                      ),
                      sizeBox(),
                      buildInputField(
                          label: 'State',
                          icon: const Icon(Icons.info),
                          controller: stateController,
                          hintText: 'State',
                          context: context,
                          enabled: cubit.accountData['userId'] == UserDetails.userId
                              ? true
                              : false
                      ),
                      sizeBox(),
                      buildInputField(
                          label: 'Phone',
                          icon: const Icon(Icons.phone),
                          controller: phoneController,
                          hintText: 'Phone',
                          keyboardType: TextInputType.phone,
                          context: context,
                          enabled: cubit.accountData['userId'] == UserDetails.userId
                              ? true
                              : false
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
    );
  }
}

class ViewImage extends StatelessWidget {
  final String userImage;

  const ViewImage({
    required this.userImage,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          height: 500.0,
          width: double.infinity,
          child: Image.network(userImage, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
