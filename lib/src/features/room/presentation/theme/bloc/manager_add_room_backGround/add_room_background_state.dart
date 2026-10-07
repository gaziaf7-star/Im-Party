
import 'package:equatable/equatable.dart';

abstract class AddRoomBackgroundState extends Equatable {
  const AddRoomBackgroundState();
  
  @override
  List<Object> get props => [];
}

class AddRoomBackgroundInitial extends AddRoomBackgroundState {}
class AddRoomBackgroundLoading extends AddRoomBackgroundState {}
class AddRoomBackgroundSuccess extends AddRoomBackgroundState {
  final String massage; 
  const AddRoomBackgroundSuccess({required this.massage});
}
class AddRoomBackgroundError extends AddRoomBackgroundState {
  final String error ; 
  const AddRoomBackgroundError ({required this.error});
}
