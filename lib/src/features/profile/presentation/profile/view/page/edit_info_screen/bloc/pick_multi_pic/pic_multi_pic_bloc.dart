import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'pic_multi_pic_event.dart';
part 'pic_multi_pic_state.dart';

class PicMultiPicBloc extends Bloc<PicMultiPicEvent, PicMultiPicState> {
  PicMultiPicBloc() : super(PicMultiPicInitial()) {
    on<PicMultiPicEvent>((event, emit) {
    });
  }
}
