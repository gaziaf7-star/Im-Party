import 'package:general/src/core/index.dart';

class GoogleEntity extends Equatable {
  final GoogleSignInAccount googleID;
  final MyDataModel data;

  const GoogleEntity({required this.googleID, required this.data});

  @override
  List<Object?> get props => [googleID, data];
}
