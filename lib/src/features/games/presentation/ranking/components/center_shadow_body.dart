part of'../rank_screen.dart';
class CenterShadowBody extends StatelessWidget {
  const CenterShadowBody({super.key,required this.color});

  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 60.h,
          width: 60.h,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: (0.7 )),
                  blurRadius: 15,
                  spreadRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
              gradient: RadialGradient(
                  colors: [
                     color,
                     color.withValues(alpha: (0.5 )),
                     color.withValues(alpha: (0.0 )),
                  ]
              )
          ),
        ),
        Container(
          height: 50.h,
          width: 50.h,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: (0.6 )),
                  blurRadius: 15,
                  spreadRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
              gradient: RadialGradient(
                  colors: [
                    color,
                    color.withValues(alpha: (0.5 )),
                    color.withValues(alpha: (0.0 )),
                  ]
              )
          ),
        ),
      ],
    );
  }
}
