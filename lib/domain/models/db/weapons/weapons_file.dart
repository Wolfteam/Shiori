import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models.dart';
import 'weapon_file_model.dart';

part 'weapons_file.freezed.dart';
part 'weapons_file.g.dart';

@freezed
abstract class WeaponsFile implements _$WeaponsFile {
  @late
  List<WeaponFileModel> get weapons => bows + swords + claymores + catalysts + polearms;

  factory WeaponsFile({
    @required List<WeaponFileModel> bows,
    @required List<WeaponFileModel> swords,
    @required List<WeaponFileModel> claymores,
    @required List<WeaponFileModel> catalysts,
    @required List<WeaponFileModel> polearms,
  }) = _WeaponsFile;

  WeaponsFile._();

  factory WeaponsFile.fromJson(Map<String, dynamic> json) => _$WeaponsFileFromJson(json);
}
