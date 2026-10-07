import 'package:general/src/core/index.dart';

class AppleEntity extends Equatable {
  final AuthorizationCredentialAppleID appleID;
  final MyDataModel data;

  const AppleEntity({
    required this.appleID,
    required this.data,
  });

  @override
  List<Object?> get props => [appleID, data];
}
