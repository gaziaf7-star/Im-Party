part of '../coin_seller_screen.dart';

class CoinSellerTransferTab extends StatefulWidget {
  const CoinSellerTransferTab({super.key});

  @override
  State<CoinSellerTransferTab> createState() =>
      _CoinSellerTransferTabState();
}

class _CoinSellerTransferTabState
    extends State<CoinSellerTransferTab> {
  final _userIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final SearchUserAgencyBloc _searchBloc =
  di<SearchUserAgencyBloc>();

  Timer? _searchDebounce;

  OutlineInputBorder _border(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Clear any old result left in this singleton bloc from another screen.
    _searchBloc.add(
      const SearchUserEvent(id: ''),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    // Do not leave a recipient result selected for another screen.
    _searchBloc.add(
      const SearchUserEvent(id: ''),
    );

    _userIdController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onRecipientChanged(String? rawValue) {
    final value = (rawValue ?? '').trim();

    _searchDebounce?.cancel();

    if (value.isEmpty) {
      _searchBloc.add(
        const SearchUserEvent(id: ''),
      );
      return;
    }

    // Debounce keeps typing smooth and prevents one API call per keystroke.
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
          () {
        if (!mounted) return;

        _searchBloc.add(
          SearchUserEvent(id: value),
        );
      },
    );
  }

  String? _resolvedRecipientId() {
    final typed = _userIdController.text.trim();
    final users = _searchBloc.state.users ?? const [];

    if (typed.isEmpty || users.isEmpty) {
      return null;
    }

    var matched = users.first;

    for (final user in users) {
      if (user.uuid.trim() == typed ||
          user.id.toString() == typed) {
        matched = user;
        break;
      }
    }

    final publicId = matched.uuid.trim();

    return publicId.isNotEmpty
        ? publicId
        : matched.id.toString();
  }

  String? _resolvedRecipientName() {
    final typed = _userIdController.text.trim();
    final users = _searchBloc.state.users ?? const [];

    if (typed.isEmpty || users.isEmpty) {
      return null;
    }

    var matched = users.first;

    for (final user in users) {
      if (user.uuid.trim() == typed ||
          user.id.toString() == typed) {
        matched = user;
        break;
      }
    }

    return matched.name.trim().isEmpty
        ? null
        : matched.name.trim();
  }

  void _submitTransfer(BuildContext context) {
    final recipientId = _resolvedRecipientId();

    if (recipientId == null) {
      Methods.showToast(
        context,
        message: 'Please enter a valid user ID.',
        isError: true,
      );
      return;
    }

    final amountText = _amountController.text.trim();

    di<CoinSellerBloc>().add(
      TransferCoinSellerEvent(
        userId: recipientId,
        amount: amountText,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        context: context,
      ),
    );

    _userIdController.clear();
    _amountController.clear();
    _noteController.clear();

    _searchBloc.add(
      const SearchUserEvent(id: ''),
    );
  }

  void _onTransferPressed(BuildContext context) {
    final typedUserId = _userIdController.text.trim();
    final recipientId = _resolvedRecipientId();
    final recipientName = _resolvedRecipientName();
    final amountText = _amountController.text.trim();
    final amount = int.tryParse(amountText);

    if (typedUserId.isEmpty) {
      Methods.showToast(
        context,
        message: StringManager.invalidUserId.tr(),
        isError: true,
      );
      return;
    }

    if (recipientId == null) {
      Methods.showToast(
        context,
        message: 'User not found. Please enter a valid user ID.',
        isError: true,
      );
      return;
    }

    if (amount == null || amount <= 0) {
      Methods.showToast(
        context,
        message: StringManager.invalidAmount.tr(),
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              18.w,
              16.h,
              18.w,
              18.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: _coinSellerBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        gradient: const LinearGradient(
                          colors: _coinSellerGradient,
                        ),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                        size: 23.h,
                      ),
                    ),
                    11.wBox,
                    Expanded(
                      child: TextWidget(
                        StringManager.confirmTransferTitle.tr(),
                        style: context.bodyLarge
                            .size(17)
                            .bold
                            .colorExt(_coinSellerText),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(dialogContext),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F2F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: _coinSellerText,
                          size: 19.h,
                        ),
                      ),
                    ),
                  ],
                ),
                18.hBox,
                if (recipientName != null)
                  _ConfirmInfoRow(
                    title: 'Recipient',
                    value: recipientName,
                  ),
                if (recipientName != null)
                  10.hBox,
                _ConfirmInfoRow(
                  title: StringManager.recipientUserId.tr(),
                  value: recipientId,
                ),
                10.hBox,
                _ConfirmInfoRow(
                  title: StringManager.amount.tr(),
                  value: amountText,
                ),
                if (_noteController.text.trim().isNotEmpty) ...[
                  10.hBox,
                  _ConfirmInfoRow(
                    title: StringManager.noteOptional.tr(),
                    value: _noteController.text.trim(),
                  ),
                ],
                20.hBox,
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: _coinSellerBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            foregroundColor: _coinSellerText,
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            StringManager.cancel.tr(),
                            style: TextStyle(
                              color: _coinSellerText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    10.wBox,
                    Expanded(
                      child: _GradientActionButton(
                        title: StringManager.confirm.tr(),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _submitTransfer(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        2.h,
        16.w,
        24.h,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16.w,
          16.h,
          16.w,
          18.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: _coinSellerBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 15.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              StringManager.transferCoins.tr(),
              style: context.bodyLarge
                  .size(17)
                  .bold
                  .colorExt(_coinSellerText),
            ),
            5.hBox,
            TextWidget(
              'Send coins securely to a user account.',
              isTranslate: false,
              style: context.bodySmall
                  .size(12)
                  .colorExt(_coinSellerSubText),
            ),
            20.hBox,

            _CoinSellerFieldLabel(
              text: StringManager.recipientUserId.tr(),
            ),
            8.hBox,

            TextInputWidget(
              StringManager.enterUserId.tr(),
              controller: _userIdController,
              keyboardType: TextInputType.text,
              prefixIcon: Icons.person_outline_rounded,
              prefixColor: _coinSellerPurple,

              // IMPORTANT: typed text is explicitly black.
              textColor: Colors.black,
              cursorColor: _coinSellerPurple,
              textSize: 14,

              fillColor: const Color(0xFFF8F7FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 15.h,
              ),
              hintStyle: context.bodyMedium
                  .size(13)
                  .colorExt(
                const Color(0xFF8B8791),
              ),
              border: _border(_coinSellerBorder),
              enabledBorder: _border(_coinSellerBorder),
              focusedBorder: _border(
                _coinSellerPurple,
                width: 1.3,
              ),
              onChanged: _onRecipientChanged,
            ),

            // Live recipient lookup result card.
            BlocBuilder<SearchUserAgencyBloc, SearchUserAgencyStates>(
              bloc: _searchBloc,
              buildWhen: (prev, curr) =>
              prev.usersRequestState != curr.usersRequestState ||
                  prev.users != curr.users ||
                  prev.usersErrorMsg != curr.usersErrorMsg,
              builder: (context, searchState) {
                final typed = _userIdController.text.trim();

                if (typed.isEmpty ||
                    searchState.usersRequestState.isEmpty) {
                  return const SizedBox.shrink();
                }

                if (searchState.usersRequestState.isLoading) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FA),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: _coinSellerBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 17.h,
                            height: 17.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _coinSellerPurple,
                            ),
                          ),
                          9.wBox,
                          TextWidget(
                            'Checking user...',
                            isTranslate: false,
                            style: context.bodySmall
                                .size(11.5)
                                .w600
                                .colorExt(_coinSellerSubText),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final users = searchState.users ?? const [];

                if (users.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F6),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: const Color(0xFFFFD9DE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            color: const Color(0xFFE65365),
                            size: 19.h,
                          ),
                          9.wBox,
                          Expanded(
                            child: TextWidget(
                              searchState.usersErrorMsg.trim().isNotEmpty
                                  ? searchState.usersErrorMsg
                                  : 'User not found',
                              isTranslate: false,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodySmall
                                  .size(11.5)
                                  .w600
                                  .colorExt(
                                const Color(0xFFB33A49),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                var user = users.first;

                for (final candidate in users) {
                  if (candidate.uuid.trim() == typed ||
                      candidate.id.toString() == typed) {
                    user = candidate;
                    break;
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      10.w,
                      10.h,
                      11.w,
                      10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3FF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _coinSellerPurple.withValues(
                          alpha: 0.34,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _coinSellerPurple.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: _coinSellerGradient,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: UserImage(
                              imageSize: 46.w,
                              image: EndPoints.getImage(user.image),
                              displayName: user.name,
                              boxFit: BoxFit.cover,
                              borderRadius: 50.radius,
                            ),
                          ),
                        ),
                        11.wBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                user.name.trim().isEmpty
                                    ? 'User'
                                    : user.name,
                                isTranslate: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.bodyMedium
                                    .size(13.5)
                                    .bold
                                    .colorExt(Colors.black),
                              ),
                              5.hBox,
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14.h,
                                    color: _coinSellerPurple,
                                  ),
                                  5.wBox,
                                  Expanded(
                                    child: TextWidget(
                                      'ID: ${user.uuid.trim().isNotEmpty ? user.uuid : user.id}',
                                      isTranslate: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.bodySmall
                                          .size(11.5)
                                          .w600
                                          .colorExt(
                                        const Color(0xFF5E5868),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 27.w,
                          height: 27.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1EBB73),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 17.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            17.hBox,
            _CoinSellerFieldLabel(
              text: StringManager.amount.tr(),
            ),
            8.hBox,

            TextInputWidget(
              StringManager.enterAmount.tr(),
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              prefixIcon: Icons.monetization_on_outlined,
              prefixColor: _coinSellerPurple,

              // IMPORTANT: typed text is explicitly black.
              textColor: Colors.black,
              cursorColor: _coinSellerPurple,
              textSize: 14,

              fillColor: const Color(0xFFF8F7FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 15.h,
              ),
              hintStyle: context.bodyMedium
                  .size(13)
                  .colorExt(
                const Color(0xFF8B8791),
              ),
              border: _border(_coinSellerBorder),
              enabledBorder: _border(_coinSellerBorder),
              focusedBorder: _border(
                _coinSellerPurple,
                width: 1.3,
              ),
            ),

            17.hBox,
            _CoinSellerFieldLabel(
              text: StringManager.noteOptional.tr(),
              optional: true,
            ),
            8.hBox,

            TextInputWidget(
              StringManager.enterNoteOptional.tr(),
              controller: _noteController,
              maxLines: 3,
              minLines: 3,

              // IMPORTANT: typed text is explicitly black.
              textColor: Colors.black,
              cursorColor: _coinSellerPurple,
              textSize: 14,

              fillColor: const Color(0xFFF8F7FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 14.h,
              ),
              hintStyle: context.bodyMedium
                  .size(13)
                  .colorExt(
                const Color(0xFF8B8791),
              ),
              border: _border(_coinSellerBorder),
              enabledBorder: _border(_coinSellerBorder),
              focusedBorder: _border(
                _coinSellerPurple,
                width: 1.3,
              ),
            ),

            22.hBox,

            BlocBuilder<CoinSellerBloc, CoinSellerState>(
              bloc: di<CoinSellerBloc>(),
              buildWhen: (prev, curr) =>
              prev.reqStateTransfer !=
                  curr.reqStateTransfer,
              builder: (context, state) {
                return _GradientActionButton(
                  title: StringManager.transferNow.tr(),
                  isLoading: state.reqStateTransfer.isLoading,
                  onTap: state.reqStateTransfer.isLoading
                      ? null
                      : () => _onTransferPressed(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinSellerFieldLabel extends StatelessWidget {
  const _CoinSellerFieldLabel({
    required this.text,
    this.optional = false,
  });

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextWidget(
          text,
          style: context.bodyMedium
              .size(13)
              .w600
              .colorExt(Colors.black),
        ),
        if (optional) ...[
          4.wBox,
          TextWidget(
            '(optional)',
            isTranslate: false,
            style: context.bodySmall
                .size(10.5)
                .colorExt(_coinSellerSubText),
          ),
        ],
      ],
    );
  }
}

class _ConfirmInfoRow extends StatelessWidget {
  const _ConfirmInfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 13.w,
        vertical: 11.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _coinSellerBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextWidget(
              title,
              style: context.bodySmall
                  .size(11.5)
                  .colorExt(_coinSellerSubText),
            ),
          ),
          10.wBox,
          Flexible(
            child: TextWidget(
              value,
              isTranslate: false,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium
                  .size(13)
                  .bold
                  .colorExt(Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.title,
    required this.onTap,
    this.isLoading = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.55,
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.r),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: _coinSellerGradient,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.52),
                ),
                boxShadow: enabled
                    ? [
                  BoxShadow(
                    color: _coinSellerPurple
                        .withValues(alpha: 0.23),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                  width: 20.h,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                    : TextWidget(
                  title,
                  style: context.bodyMedium
                      .size(14)
                      .bold
                      .colorExt(Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
