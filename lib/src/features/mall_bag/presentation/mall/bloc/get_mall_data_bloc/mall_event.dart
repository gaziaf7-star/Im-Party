part of 'mall_bloc.dart';

abstract class MallEvent extends Equatable {
  final int index;
  final bool? isLoading;

  final MallEntity? selectedItem;

  const MallEvent({this.index = 0, this.isLoading = false, this.selectedItem});

  @override
  List<Object?> get props => [index, selectedItem];
}

class SelectMallItemEvent extends MallEvent {
  const SelectMallItemEvent({required MallEntity selectedItem})
      : super(selectedItem: selectedItem);
}

class GetCarMallEvent extends MallEvent {
  const GetCarMallEvent({super.isLoading});
}

class GetFramesMallEvent extends MallEvent {
  const GetFramesMallEvent({super.isLoading});
}

class GetSpecialIdMallEvent extends MallEvent {
  const GetSpecialIdMallEvent({super.isLoading});
}

class GetBubbleMallEvent extends MallEvent {
  const GetBubbleMallEvent({super.isLoading});
}

class GetProfileFramesMallEvent extends MallEvent {
  const GetProfileFramesMallEvent({super.isLoading});
}

class ChangeAppBarUIMallEvent extends MallEvent {
  const ChangeAppBarUIMallEvent({required super.index});
}
