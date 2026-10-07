
import '../../../../../reels_viewer/reels_viewer.dart';
import '../../auth.dart';

/// Loads `/config/settings` and applies the realtime transport flags
/// (Centrifugo chat + banners + ws url) via `RealtimeConfig.applyFromSettings`
/// inside the data source. No legacy realtime payload is parsed or returned.
class RealtimeSettingsUc extends UseCaseWithoutParams<BaseResponse<bool>> {
  final BaseAuthenticationRepository _repo;

  const RealtimeSettingsUc(this._repo);

  @override
  ResultFuture<BaseResponse<bool>> call() async {
    return await _repo.getRealtimeSettings();
  }
}
