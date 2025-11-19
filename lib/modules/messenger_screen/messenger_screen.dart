import '../../shared/constants/user_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layouts/messenger_layout.dart';
import 'package:flutter/material.dart';
import 'cubit.dart';


class MessengerScreen extends StatelessWidget {
  const MessengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenCubit()..getFriends(userId: UserDetails.userId),
      child: const MessengerLayout(),
    );
  }
}