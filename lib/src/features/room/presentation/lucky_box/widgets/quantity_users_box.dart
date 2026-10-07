import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/lucky_pill.dart';
import 'package:general/src/features/room/room.dart';

class QuantityUsersBox extends StatelessWidget {
  final List<String> boxes;

  const QuantityUsersBox({super.key, required this.boxes});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LuckyBoxBloc, LuckyBoxState>(
        bloc: di<LuckyBoxBloc>(),
        buildWhen: (prev, curr) => prev.luckyBoxQuantity != curr.luckyBoxQuantity,
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                boxes.length,
                (index) {
                  return ValueListenableBuilder(
                    valueListenable: LuckyBoxVariables.notifierQuantity,
                    builder: (context, value, child) => Padding(
                      padding: EdgeInsetsDirectional.only(end: 8.w),
                      child: SizedBox(
                        width: 60.w,
                        child: LuckyPill(
                          text: boxes[index].toString(),
                          selected:
                              state.luckyBoxQuantity == boxes[index].toString(),
                          onTap: () {
                            if (state.luckyBoxQuantity != boxes[index]) {
                              di<LuckyBoxBloc>()
                                  .add(SelectLuckyBoxQuantity(index: index));
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
        });
  }
}
