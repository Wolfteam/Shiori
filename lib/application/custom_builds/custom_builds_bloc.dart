import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';

part 'custom_builds_bloc.freezed.dart';
part 'custom_builds_event.dart';
part 'custom_builds_state.dart';

class CustomBuildsBloc extends Bloc<CustomBuildsEvent, CustomBuildsState> {
  final DataService _dataService;

  CustomBuildsBloc(this._dataService) : super(const CustomBuildsState.loaded());

  @override
  Stream<CustomBuildsState> mapEventToState(CustomBuildsEvent event) async* {
    final s = await event.map(
      load: (_) async {
        final builds = _dataService.customBuilds.getAllCustomBuilds();
        return state.copyWith.call(builds: builds);
      },
      delete: (e) async {
        await _dataService.customBuilds.deleteCustomBuild(e.key);
        final builds = [...state.builds];
        builds.removeWhere((el) => el.key == e.key);
        return state.copyWith.call(builds: builds);
      },
    );

    yield s;
  }
}
