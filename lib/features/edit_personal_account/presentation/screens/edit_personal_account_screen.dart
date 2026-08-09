import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../cubits/edit_personal_account_cubit.dart';
import '../widgets/layouts/edit_personal_account_layout.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:test_app/features/edit_personal_account/presentation/states/edit_personal_account_state.dart';


class EditPersonalAccountScreen extends StatelessWidget {
  final String docId;

  const EditPersonalAccountScreen({
    required this.docId,
    super.key
  });

  static const _defaultInfoText = 'Info';
  static const _defaultInfoIcon = Icons.info;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        sl<EditPersonalAccountCubit>()
          ..getAccountData(docId: docId),
        child: BlocBuilder<EditPersonalAccountCubit, EditPersonalAccountState>(
            builder: (context, state) {
              final cubit = EditPersonalAccountCubit.get(context);
              return state.when(
                onInitial: () =>
                const InitialStateWidget(
                    text: _defaultInfoText, icon: _defaultInfoIcon),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (data) {
                  return EditPersonalAccountLayout(
                    onUpdate: ({
                      required String userId,
                      required String userImage,
                      required String firstName,
                      required String lastName,
                      required String userState
                    }) =>
                        cubit.updateAccountData(
                            userId: userId,
                            firstName: firstName,
                            lastName: lastName,
                            userImage: userImage,
                            userState: userState
                        ),
                    userId: docId,
                    accountModel: data.firstModel,
                    messageResult: data.secondModel,
                  );
                },
                onError: (error) =>
                    error.buildErrorWidget(
                        onRetry: () => cubit.getAccountData(docId: docId)
                    ),
              );
            }
        )
    );
  }
}