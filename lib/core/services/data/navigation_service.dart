import 'package:flutter/cupertino.dart';


class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static NavigatorState? get currentState => navigatorKey.currentState;
}