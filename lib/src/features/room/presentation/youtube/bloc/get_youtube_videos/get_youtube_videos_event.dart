import 'package:equatable/equatable.dart';

abstract class GetYoutubeEvent  extends Equatable {
  const GetYoutubeEvent();

}

class GetYoutubeVideoEvent extends GetYoutubeEvent {
final String search;
final String regionCode;
const GetYoutubeVideoEvent({  this.search='',this.regionCode='EG'});

  @override
  List<Object?> get props => [
    search,
    regionCode,
  ];

}
