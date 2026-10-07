// ignore_for_file: must_be_immutable

import 'package:general/src/core/index.dart';
import '../../features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import '../../features/home/presentation/search_screen/bloc/search_manager/search_states.dart';
import 'package:general/src/core/widgets/user_info_row2.dart';

class SearchContainerVisibility extends StatefulWidget {
  const SearchContainerVisibility(
      {super.key, required this.searchContainerVisibleNotifier, required this.userID});
  final ValueNotifier<bool> searchContainerVisibleNotifier;
  final TextEditingController userID;
  @override
  State<SearchContainerVisibility> createState() =>
      _SearchContainerVisibilityState();
}

class _SearchContainerVisibilityState extends State<SearchContainerVisibility> {


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.searchContainerVisibleNotifier,
        builder: (buildContext, dynamic, _) {
        return Visibility(
          visible: widget.searchContainerVisibleNotifier.value,
          child: Container(
            height: ScreenUtil().screenHeight * .3,
            width: ScreenUtil().screenWidth,
            color: ColorManager.surfaceCardColor,
            child: BlocBuilder<SearchBloc, SearchStates>(
              bloc: di<SearchBloc>(),
              buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
              builder: (context, state) {

                if (state.reqState ==RequestState.loaded) {
                  return ListView.builder(
                      itemCount: state.data?.users.length??0,
                      itemExtent: 70,
                      itemBuilder: (context, index) {
                        if(state.data?.users!=null) {
                          if(state.data!.users.isNotEmpty) {
                            return UserInfoRow(
                            onTap: () {
                              setState(() {
                                widget.userID.text =
                                    state.data!.users[index].id.toString();
                              });
                              widget.searchContainerVisibleNotifier.value = false;
                            },
                            userData: state.data!.users[index],
                            endIcon: const Icon(
                              Icons.arrow_forward_ios,
                            ));
                          }
                        }
                        return null;
                      });

                }
                else if (state.reqState ==RequestState.loading) {
                  return const LoadingWidget();
                } else {
                  return const SizedBox();
                }

              },
            ),
          ),
        );
      }
    );
  }
}
