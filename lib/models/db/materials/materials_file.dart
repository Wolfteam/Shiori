import 'package:freezed_annotation/freezed_annotation.dart';
import 'talent_material_file_model.dart';

part 'materials_file.freezed.dart';
part 'materials_file.g.dart';

@freezed
abstract class MaterialsFile implements _$MaterialsFile {
  @late
  List<TalentMaterialFileModel> get materials => talents + weaponPrimary;

  factory MaterialsFile({
    @required List<TalentMaterialFileModel> talents,
    @required List<TalentMaterialFileModel> weaponPrimary,
  }) = _MaterialsFile;

  MaterialsFile._();

  factory MaterialsFile.fromJson(Map<String, dynamic> json) => _$MaterialsFileFromJson(json);
}
