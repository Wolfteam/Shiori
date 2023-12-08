import 'tests/artifacts_page_test.dart' as artifacts_test;
import 'tests/banner_history_page_test.dart' as banner_history_test;
import 'tests/calculator_asc_materials_page_test.dart' as calculator_asc_materials_test;
import 'tests/characters_page_test.dart' as characters_test;
import 'tests/custom_builds_page_test.dart' as custom_builds_test;
import 'tests/elements_page_test.dart' as elements_test;
import 'tests/inventory_page_test.dart' as inventory_tests;
import 'tests/main_tab_page_test.dart' as main_tab_test;
import 'tests/materials_page_test.dart' as materials_test;
import 'tests/monsters_page_test.dart' as monsters_test;
import 'tests/notifications_page_test.dart' as notifications_page;
import 'tests/splash_page_test.dart' as splash_test;
import 'tests/today_asc_materials_page_test.dart' as today_asc_materials_test;
import 'tests/weapons_page_test.dart' as weapons_test;

void main() {
  splash_test.main();
  main_tab_test.main();
  today_asc_materials_test.main();
  characters_test.main();
  weapons_test.main();
  artifacts_test.main();
  materials_test.main();
  monsters_test.main();
  elements_test.main();
  inventory_tests.main();
  banner_history_test.main();
  calculator_asc_materials_test.main();
  notifications_page.main();
  custom_builds_test.main();
}
