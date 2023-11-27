import 'tests/artifacts_page_test.dart' as artifacts_test;
import 'tests/characters_page_test.dart' as characters_test;
import 'tests/main_tab_page_test.dart' as main_tab_test;
import 'tests/materials_page_test.dart' as materials_test;
import 'tests/monsters_page_test.dart' as monsters_test;
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
}
