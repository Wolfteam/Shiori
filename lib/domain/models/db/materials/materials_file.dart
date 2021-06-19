import 'package:freezed_annotation/freezed_annotation.dart';

import 'material_file_model.dart';

part 'materials_file.freezed.dart';
part 'materials_file.g.dart';

@freezed
class MaterialsFile with _$MaterialsFile {
  List<MaterialFileModel> get materials =>
      talents + weapon + weaponPrimary + common + currency + elemental + jewels + locals + experience + ingredient;

  factory MaterialsFile({
    required List<MaterialFileModel> talents,
    required List<MaterialFileModel> weapon,
    required List<MaterialFileModel> weaponPrimary,
    required List<MaterialFileModel> common,
    required List<MaterialFileModel> currency,
    required List<MaterialFileModel> elemental,
    required List<MaterialFileModel> jewels,
    required List<MaterialFileModel> locals,
    required List<MaterialFileModel> experience,
    required List<MaterialFileModel> ingredient,
  }) = _MaterialsFile;

  MaterialsFile._();

  factory MaterialsFile.fromJson(Map<String, dynamic> json) => _$MaterialsFileFromJson(json);
}
