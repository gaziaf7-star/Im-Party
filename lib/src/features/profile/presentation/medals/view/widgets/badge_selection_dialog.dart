// part of '../medals_page.dart';
// class _BadgeSelectionDialog extends StatelessWidget {
//   const _BadgeSelectionDialog({
//     required this.state,
//     required this.ids,
//     required this.selectionBloc,
//   });
//
//   final MyAllBadgeSucssesState state;
//   final List<String> ids;
//   final SelectionBloc selectionBloc;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: ScreenUtil().screenHeight * 0.60,
//       width: ScreenUtil().screenWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: ColorManager.containerMedalsGradient,
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               InkWell(
//                 onTap: () => Navigator.pop(context),
//                 child: Padding(
//                   padding: context.paddingAll(15),
//                   child: const Icon(Icons.close, color: Colors.white),
//                 ),
//               ),
//               const Spacer(flex: 4),
//               Text(
//                 StringManager.achievement,
//                 style: context.bodyLarge.bold,
//               ),
//               const Spacer(flex: 6),
//             ],
//           ),
//           Expanded(
//             child: state.badges.data.isEmpty
//                 ? Image.asset(AssetsManager.empty, scale: 3.5)
//                 : SizedBox(
//                     width: ScreenUtil().screenWidth,
//                     child: GridView.builder(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         mainAxisSpacing: 0,
//                         crossAxisSpacing: 0,
//                       ),
//                       itemCount: state.badges.data.length,
//                       itemBuilder: (context, index) {
//                         final badge = state.badges.data[index];
//                         return Padding(
//                           padding:context.paddingAll(15),
//                           child: InkWell(
//                             onTap: () {
//                               selectionBloc.add(SelectBadge(
//                                 badgeId: badge.id,
//                                 context: context,
//                               ));
//                             },
//                             child: BlocBuilder<SelectionBloc, SelectionState>(
//                               bloc: selectionBloc,
//                               builder: (context, selectionState) {
//                                 final isSelected = selectionState.selectedIds
//                                     .contains(badge.id);
//                                 return BadgesItem(
//                                   isPicked: isSelected,
//                                   image: badge.image,
//                                 );
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ),
//           10.hBox,
//           state.badges.data.isEmpty
//               ? const SizedBox()
//               : ButtonWidget(
//                   onPressed: () {
//                     final selectedIds = selectionBloc.state.selectedIds;
//                     if (selectedIds.length < 9) {
//                       Navigator.pop(context);
//                       BlocProvider.of<PickMyBadgesBloc>(context).add(
//                         PickMyBadgesEvent(ids: selectedIds),
//                       );
//                     }
//                   },
//                   title: StringManager.done.tr(),
//                   height: 40.h,
//                   width: 100.w,
//                   backgroundColor: const Color(0xFF00BCD4),
//                   fontWeight: FontWeight.normal,
//                   fontSize: 13,
//                 ),
//           10.hBox,
//         ],
//       ),
//     );
//   }
// }
