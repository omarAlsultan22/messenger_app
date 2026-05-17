import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/edit_personal_account_layout.dart';
import 'package:flutter/material.dart';
import '../cubits/cubit.dart';


class EditPersonalAccountScreen extends StatelessWidget {
  final String userId;

  const EditPersonalAccountScreen({
    required this.userId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetAccountDataCubit()..getAccountData(userId: userId),
      child: EditPersonalAccountLayout(userId: userId),
    );
  }
}