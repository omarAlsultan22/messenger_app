import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../widgets/layouts/messenger_layout.dart';
import '../cubits/cubit.dart';


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