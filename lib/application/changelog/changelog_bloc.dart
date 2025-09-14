import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/services/changelog_provider.dart';

part 'changelog_bloc.freezed.dart';
part 'changelog_event.dart';
part 'changelog_state.dart';

class ChangelogBloc extends Bloc<ChangelogEvent, ChangelogState> {
  final ChangelogProvider _changelogProvider;

  ChangelogBloc(this._changelogProvider) : super(const ChangelogState.loading()) {
    on<ChangelogEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(ChangelogEvent event, Emitter<ChangelogState> emit) async {
    switch (event) {
      case ChangelogEventInit():
        final changelog = await _changelogProvider.load();
        final state = ChangelogState.loadedState(changelog);
        emit(state);
    }
  }
}
