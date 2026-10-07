import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/lucky_box_entity.dart';
import 'package:general/src/features/room/presentation/lucky_box/bloc/lucky_box_bloc.dart';
import 'package:general/src/features/room/presentation/lucky_box/lucky_box_controller.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/lucky_pill.dart';

class CoinsLuckyBox extends StatelessWidget {
  final List<TypeBoxEntity> boxes;

  const CoinsLuckyBox({super.key, required this.boxes});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LuckyBoxBloc, LuckyBoxState>(
      bloc: di<LuckyBoxBloc>(),
      buildWhen: (prev, curr) => prev.isLuckyBoxTap != curr.isLuckyBoxTap || prev.luckyBoxItem != curr.luckyBoxItem || prev.superBoxCoins != curr.superBoxCoins,
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              boxes.length,
              (index) {
                final coinStr = boxes[index].coins.toString();
                final isSelectedLuckyBox =
                    state.isLuckyBoxTap! && state.luckyBoxItem == coinStr;
                final isSelectedSuperBox =
                    !state.isLuckyBoxTap! && state.superBoxCoins == coinStr;

                final isSelected = isSelectedLuckyBox || isSelectedSuperBox;

                return ValueListenableBuilder(
                  valueListenable: LuckyBoxVariables.notifierCoins,
                  builder: (context, value, child) => Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.w),
                    child: SizedBox(
                      width: 90.w,
                      child: LuckyPill(
                        text: coinStr,
                        selected: isSelected,
                        onTap: () {
                          if (state.isLuckyBoxTap! &&
                              state.luckyBoxItem != coinStr) {
                            di<LuckyBoxBloc>()
                                .add(SelectLuckyBoxCoins(index: index));
                          } else if (!state.isLuckyBoxTap! &&
                              state.superBoxCoins != coinStr) {
                            di<LuckyBoxBloc>()
                                .add(SelectSuperBoxCoins(index: index));
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
