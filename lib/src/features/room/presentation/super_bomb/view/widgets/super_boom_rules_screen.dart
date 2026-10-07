import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_bloc/get_super_bombs_bloc.dart';

class SuperBoomRulesScreen extends StatelessWidget {
  const SuperBoomRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(StringManager.rule.tr()),
      ),
      body: BlocBuilder<GetSuperBombsBloc, GetSuperBombsState>(
        bloc: di<GetSuperBombsBloc>(),
        buildWhen: (prev, curr) => prev.rulesState != curr.rulesState || prev.rulesData != curr.rulesData,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.rulesState,
            title: '',
            subTitle: '',
            isNeedLoadingWidget: true,
            child: state.rulesData != null
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      context.locale.languageCode == 'ar'
                          ? (state.rulesData?.data[0].rulesAr ?? "")
                          : (state.rulesData?.data[0].rulesEn ?? ""),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
