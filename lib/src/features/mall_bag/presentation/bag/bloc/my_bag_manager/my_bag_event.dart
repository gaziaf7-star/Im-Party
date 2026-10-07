part of'my_bag_bloc.dart';

abstract class MyBagEvent extends Equatable {
  final int index;
  final bool? isLoading;

  final MyBagEntity? selectedItem;

  const MyBagEvent({this.index = 0, this.isLoading = false, this.selectedItem});

  @override
  List<Object?> get props => [index, selectedItem];
}

class SelectBagItemEvent extends MyBagEvent {
  final int? type;

  const SelectBagItemEvent({required super.selectedItem, this.type});
}

class GetFramesMyBagEvent extends MyBagEvent {
  const GetFramesMyBagEvent({super.isLoading});
}

class GetBubbleBackPackMyBagEvent extends MyBagEvent {
  const GetBubbleBackPackMyBagEvent({super.isLoading});
}

class GetEntrieMyBagEvent extends MyBagEvent {
  const GetEntrieMyBagEvent({super.isLoading});
}

class GetVipMyBagEvent extends MyBagEvent {
  const GetVipMyBagEvent({super.isLoading});
}

class GetSpecialIdMyBagEvent extends MyBagEvent {
  const GetSpecialIdMyBagEvent({super.isLoading});
}

class GetProfileFrameMyBagEvent extends MyBagEvent {
  const GetProfileFrameMyBagEvent({super.isLoading});
}

class LocalChangeDataEvent extends MyBagEvent {
  final String itemId;
  final MallOrBagType tabType;
  final bool useType;

  const LocalChangeDataEvent({required this.itemId,
    required this.tabType,
    required this.useType,
  });
}

class ChangeAppBarUIEvent extends MyBagEvent {

  const ChangeAppBarUIEvent({required super.index});
}

