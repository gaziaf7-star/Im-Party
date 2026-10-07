import 'package:general/src/features/moment/moment.dart';

import '../../../../core/index.dart';

class SendGiftMomentUsGiftUC extends UseCaseWithParams<String, SendGiftMomentParameter> {
  final BaseMomentRepository baseMomentRepository;

  SendGiftMomentUsGiftUC({required this.baseMomentRepository});

  @override
  ResultFuture<String> call(SendGiftMomentParameter params) async {
    final result = await baseMomentRepository.sendGiftsMoment(params);
    return result;
  }
}
