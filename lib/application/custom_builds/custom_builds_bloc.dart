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
    switch (event) {
      case CustomBuildsEventLoad():
        final builds = _dataService.customBuilds.getAllCustomBuilds();
        yield state.copyWith.call(builds: builds);
      case CustomBuildsEventDelete():
        await _dataService.customBuilds.deleteCustomBuild(event.key);
        final builds = [...state.builds];
        builds.removeWhere((el) => el.key == event.key);
        yield state.copyWith.call(builds: builds);
    }
  }
}
