import 'package:test_app/features/sign_in/data/repositories_impl/firebase_data_repository.dart';
import '../../../conversation/domain/services/connectivity_service/connectivity_service.dart';
import '../../../conversation/data/data_sources/remote/firebase_firestore.dart';
import '../../../auth/domain/useCases/sign_in_useCase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/sign_in_layout.dart';
import 'package:flutter/material.dart';
import '../cubits/sign_in_cubit.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreService();
    final authRepository = FirebaseDataRepository(repository: repository);
    final useCase = SignInUseCase(
        authRepository: authRepository);
    final connectivityService = ConnectivityService();
    return BlocProvider(
      create: (BuildContext context) =>
          SignInCubit(
              useCase: useCase, connectivityService: connectivityService),
      child: const SignInLayout(),
    );
  }
}