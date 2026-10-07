import 'package:general/src/core/index.dart';
import 'package:general/src/features/vip/domain/use_case/buy_vip_use_case.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_bloc.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_event.dart';

import 'buy_vip_event.dart';
import 'buy_vip_state.dart';

class BuyVipBloc extends Bloc<BaseBuyVipEvent, BuyVipState> {
  final BuyVipUseCase buyVipUseCase;

  BuyVipBloc({required this.buyVipUseCase}) : super(const BuyVipState()) {
    on<BuyVipEvent>(
      (event, emit) async {
        emit(state.copyWith(requestState: RequestState.loading));
        final result = await buyVipUseCase(BuyVipParameter(
          type: event.type,
          uuid: event.toUid ?? '',
          vipId: event.vipId,
        ));

        result.fold(
          (left) {
            emit(
              state.copyWith(
                requestState: RequestState.error,
                message: NetworkExceptions.getErrorMessage(left),
              ),
            );
            Methods.showToast(event.context,
                message: state.message, isError: true);
          },
          (right) {
            emit(
              state.copyWith(
                requestState: RequestState.loaded,
                message: right,
              ),
            );

            Methods.showToast(event.context,
                message: StringManager.success.tr());
                
            //di<VipCenterBloc>().add(const GetVipCenterEvent(isLoading: false));
            di<VipCenterBloc>().add(const GetVipBagEvent());

          },
        );
      },
    );
  }
}
