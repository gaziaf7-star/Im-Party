import 'package:general/src/core/index.dart';

class ThirdPartyEntity extends Equatable{
   dynamic data;
 final String? type;
 final bool? isAgeNotComplete;
 final bool? isCountryNotComplete;
   ThirdPartyEntity( {required this.data,  this.type,this.isCountryNotComplete,this.isAgeNotComplete,});

  @override
  List<Object?> get props => [
    data,
    type,
    isAgeNotComplete,
    isCountryNotComplete,
  ];
}