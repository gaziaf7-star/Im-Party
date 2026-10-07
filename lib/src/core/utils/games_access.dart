import 'package:general/src/features/auth/data/model/my_data_model.dart';

/// Single source of truth for the "can this user open games?" decision on the
/// client.
///
/// The full access policy (allowed roles OR min level OR min recharge, plus the
/// VIP / manager / agency bypass and the legacy level fallback) is computed
/// server-side in `UserHandling::canPlay` and shipped on every `/my-data`
/// fetch as `game_available` -> [MyDataModel.isGameAvailable]. The client does
/// not have the raw inputs (no `total_charge_coins`, no flat `users.level`, no
/// scalar `type_user`), so re-deriving the decision here would be incomplete and
/// could diverge from the server gate. We therefore consume the authoritative
/// flag instead of recomputing it.
///
/// Default behavior (all games-settings keys unset) keeps games available for
/// everyone, because the server returns `game_available = true` in that case.
abstract final class GamesAccess {
  const GamesAccess._();

  /// Whether the current user may see and open the games entry points.
  static bool get canPlay =>
      MyDataModel.getInstance().isGameAvailable ?? false;
}
