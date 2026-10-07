

import 'package:equatable/equatable.dart';

abstract class GiftHistoryEvent extends Equatable {
  const GiftHistoryEvent();

  @override
  List<Object> get props => [];
}
class GetGiftHistory extends GiftHistoryEvent{
  final String id ;
  final bool force;
  const GetGiftHistory({required this.id, this.force = false });

  @override
  List<Object> get props => [id, force];
}
