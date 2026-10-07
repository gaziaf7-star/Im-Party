import 'package:general/src/core/index.dart';

class ShowBannersState extends Equatable {
  final Map<String, dynamic>? bannerData;

  const ShowBannersState({
    this.bannerData,
  });

  ShowBannersState copyWith({
    Map<String, dynamic>? bannerData,
  }) {
    return ShowBannersState(
      bannerData: bannerData ?? this.bannerData,
    );
  }

  @override
  List<Object?> get props => [
        bannerData,
      ];
}
