import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/services/changelog_provider.dart';

part 'changelog_bloc.freezed.dart';
part 'changelog_event.dart';
part 'changelog_state.dart';

class ChangelogBloc extends Bloc<ChangelogEvent, ChangelogState> {
  final ChangelogProvider _changelogProvider;

  ChangelogBloc(this._changelogProvider) : super(const ChangelogState.loading()) {
    on<ChangelogEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(ChangelogEvent event, Emitter<ChangelogState> emit) async {
    final s = await event.map(
      init: (_) async {
        final changelog = await _changelogProvider.load();
        return ChangelogState.loadedState(changelog);
      },
    );
    emit(s);
  }
}
