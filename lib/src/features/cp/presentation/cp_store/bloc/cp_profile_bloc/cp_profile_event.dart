part of 'cp_profile_bloc.dart';

abstract class CpProfileEvents extends Equatable {
  const CpProfileEvents();
}

class GetCpProfileEvents extends CpProfileEvents {
  final String userId;

  /// Bypasses the per-user "already loaded" guard so a same-user refetch after a
  /// mutation (e.g. buying CP seats) actually re-hits the network instead of
  /// short-circuiting on the cached state.
  final bool forceRefresh;

  const GetCpProfileEvents({required this.userId, this.forceRefresh = false});

  @override
  List<Object?> get props => [
        userId,
        forceRefresh,
      ];
}

class BuyCpSeatsEvents extends CpProfileEvents {
  final String wareId;

  const BuyCpSeatsEvents({required this.wareId});

  @override
  List<Object?> get props => [
        wareId,
      ];
}
