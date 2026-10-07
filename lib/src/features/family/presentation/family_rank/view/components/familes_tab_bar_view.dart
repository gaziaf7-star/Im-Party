part of '../family_rank_page.dart';

class FamilesTabBarView extends StatelessWidget {
  const FamilesTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllFamilyBloc,GetAllFamilyState>(
        bloc: di<GetAllFamilyBloc>(),
        buildWhen: (prev, curr) => prev.req != curr.req || prev.allFamilies != curr.allFamilies,
        builder: (context, state) {
          return HandlingDataWidget(
              reqState: state.req,
              title: StringManager.noFamily.tr(),
              subTitle: StringManager.pleaseRefresh.tr(),
              titleStyle: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
              onTap: () {
                di<GetAllFamilyBloc>().add(const GetFamilyEvent());
              },
              child: FamilyCard(
                allFamily: state.allFamilies ??[],
              ));
        }
        );
    }
}