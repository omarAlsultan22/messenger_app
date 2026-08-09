import 'core/di_core.dart';
import 'domains/di_auth.dart';
import 'domains/di_home.dart';
import 'package:get_it/get_it.dart';
import 'domains/di_conversation.dart';
import 'domains/di_edit_personal_account.dart';


final sl = GetIt.instance;

void setupServiceLocator() {
  // ============ Core ============
  CoreDependencies.register();

  // ============ Domains ============
  AuthDependencies.register();
  HomeDependencies.register();
  ConversationDependencies.register();
  EditPersonalAccountDependencies.register();
}