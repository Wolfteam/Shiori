import 'tests/artifacts_page_test.dart' as artifacts_test;
import 'tests/banner_history_count_page_test.dart' as banner_history_count_page_test;
import 'tests/calculator_asc_materials_page_test.dart' as calculator_asc_materials_test;
import 'tests/characters_page_test.dart' as characters_test;
import 'tests/charts_page_test.dart' as charts_page_test;
import 'tests/custom_builds_page_test.dart' as custom_builds_test;
import 'tests/elements_page_test.dart' as elements_test;
import 'tests/game_codes_page_test.dart' as game_codes_test;
import 'tests/inventory_page_test.dart' as inventory_tests;
import 'tests/main_tab_page_test.dart' as main_tab_test;
import 'tests/materials_page_test.dart' as materials_test;
import 'tests/monsters_page_test.dart' as monsters_test;
import 'tests/notifications_page_test.dart' as notifications_page;
import 'tests/splash_page_test.dart' as splash_test;
import 'tests/tier_list_page_test.dart' as tier_list_test;
import 'tests/today_asc_materials_page_test.dart' as today_asc_materials_test;
import 'tests/weapons_page_test.dart' as weapons_test;
import 'tests/wish_simulator_page_test.dart' as wish_simulator_test;

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
  banner_history_count_page_test.main();
  calculator_asc_materials_test.main();
  notifications_page.main();
  custom_builds_test.main();
  charts_page_test.main();
  tier_list_test.main();
  game_codes_test.main();
  wish_simulator_test.main();
}
