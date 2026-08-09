import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'core/config/bloc_observer.dart';
import 'core/constants/app_colors.dart';
import 'core/errors/mappers/error_handler.dart';
import 'core/config/initialization_controller.dart';
import 'core/presentation/widgets/build_snack_bar.dart';
import 'package:conditional_builder_null_safety/example/example.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  final initializationController = InitializationController();

  try {
    await initializationController.init();
    runApp(const MyApp());
  }
  catch (e, stackTrace) {
    final errorHandler = ErrorHandler(
      error: e,
      stackTrace: stackTrace,
    );
    final exception = errorHandler.handleException();
    runApp(
        MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Builder(
              builder: (context) =>
                  Scaffold(
                    body: exception.buildErrorWidget(
                      onRetry: () async {
                        try {
                          await initializationController.retryInit();
                          runApp(const MyApp());
                        } catch (e) {
                          BuildSnackBar.show(
                              context: context,
                              message: 'Initialization failed',
                              backgroundColor: AppColors.errorRed
                          );
                        }
                      },
                    ),
                  ),
            )
        )
    );
  }
}















