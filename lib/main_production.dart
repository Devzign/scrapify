import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/config/app_config.dart';
import 'main.dart' as app;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // must be first
  AppConfig.initialize(AppFlavor.production);
  await EasyLocalization.ensureInitialized();
  app.runMain();
}
