import 'dart:async';

import 'package:general/src/core/index.dart';

/// Pending agency / manager / admin / host / super-admin role invitations
/// shown directly above the normal chat list.
///
/// The backend routes used here are:
///   GET  /api/role-requests?status=pending
///   POST /api/role-requests/accept
///   POST /api/role-requests/reject
///
/// Behaviour:
/// - loads immediately when the Chats page opens
/// - silently refreshes every 15 seconds while mounted
/// - refreshes immediately after app resume
/// - Accept / Reject removes the successful item from the list immediately
/// - a silent reconciliation fetch follows the action
/// - after Accept, my-data is refreshed so the newly assigned role is reflected
///   throughout the app without requiring logout/restart
class RoleRequestInbox extends StatefulWidget {
  const RoleRequestInbox({super.key});

  @override
  State<RoleRequestInbox> createState() => _RoleRequestInboxState();
}

class _RoleRequestInboxState extends State<RoleRequestInbox>
    with WidgetsBindingObserver {
  static const List<Color> _actionGradient = [
    Color(0xFF8E2BFF),
    Color(0xFF503CFF),
    Color(0xFF29D7FF),
  ];

  static String get _listUrl =>
      '${EndPoints.baseURL}/role-requests';

  static String get _acceptUrl =>
      '${EndPoints.baseURL}/role-requests/accept';

  static String get _rejectUrl =>
      '${EndPoints.baseURL}/role-requests/reject';

  final DioFactory _dio = di<DioFactory>();

  Timer? _pollTimer;
  DateTime _lastFetchAt = DateTime.fromMillisecondsSinceEpoch(0);

  List<_RoleRequestItem> _requests = const [];
  Set<int> _actingIds = <int>{};

  bool _initialLoading = true;
  bool _refreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fetchRequests(initial: true);

    // Requests rarely change: poll once a minute, not every 15 s.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 60),
          (_) => _fetchRequests(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        DateTime.now().difference(_lastFetchAt).inSeconds >= 30) {
      _fetchRequests(silent: true);
    }
  }

  Future<void> _fetchRequests({
    bool initial = false,
    bool silent = false,
  }) async {
    if (_refreshing) return;

    _refreshing = true;
    _lastFetchAt = DateTime.now();

    if (initial && mounted) {
      setState(() {
        _initialLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _dio.get(
        _listUrl,
        queryParameters: const {
          'status': 'pending',
        },
        forceRefresh: true,
      );

      final body = _asMap(response.data);
      final rawData = body['data'];

      final parsed = <_RoleRequestItem>[];

      if (rawData is List) {
        for (final raw in rawData) {
          final map = _asMap(raw);
          final item = _RoleRequestItem.fromJson(map);

          if (item.id > 0 &&
              item.status.toLowerCase() == 'pending') {
            parsed.add(item);
          }
        }
      }

      parsed.sort(
            (a, b) => b.sortDate.compareTo(a.sortDate),
      );

      if (!mounted) return;

      setState(() {
        _requests = parsed;
        _initialLoading = false;
        _errorMessage = null;
      });
    } on DioException catch (e) {
      Methods.printLog(
        '🚨 [ROLE_REQUESTS][LIST] '
            'status=${e.response?.statusCode} '
            'url=$_listUrl '
            'message=${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _initialLoading = false;

        // Keep already displayed items on a temporary network failure.
        if (_requests.isEmpty && !silent) {
          _errorMessage = _extractErrorMessage(
            e.response?.data,
            fallback: 'Could not load role requests.',
          );
        }
      });
    } catch (e) {
      Methods.printLog(
        '🚨 [ROLE_REQUESTS][LIST] error=$e',
      );

      if (!mounted) return;

      setState(() {
        _initialLoading = false;
        if (_requests.isEmpty && !silent) {
          _errorMessage = 'Could not load role requests.';
        }
      });
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _respond(
      _RoleRequestItem item, {
        required bool accept,
      }) async {
    if (_actingIds.contains(item.id)) return;

    setState(() {
      _actingIds = {
        ..._actingIds,
        item.id,
      };
    });

    try {
      final response = await _dio.post(
        accept ? _acceptUrl : _rejectUrl,
        data: accept
            ? {
          'request_id': item.id,
        }
            : {
          'request_id': item.id,
          'reason': 'Rejected from mobile app',
        },
      );

      final body = _asMap(response.data);
      final success = body['status'] != false;

      if (!success) {
        throw StateError(
          _extractErrorMessage(
            body,
            fallback: accept
                ? 'Could not accept this request.'
                : 'Could not reject this request.',
          ),
        );
      }

      if (!mounted) return;

      // Remove immediately after server success. The follow-up GET below is
      // only reconciliation, so the UI never waits for a second network call.
      setState(() {
        _requests = _requests
            .where((request) => request.id != item.id)
            .toList(growable: false);

        final next = <int>{..._actingIds};
        next.remove(item.id);
        _actingIds = next;
      });

      final message = _extractSuccessMessage(
        body,
        fallback: accept
            ? 'Role request accepted successfully.'
            : 'Role request rejected.',
      );

      Methods.showToast(
        context,
        message: message,
      );

      if (accept && di.isRegistered<FetchUserDataBloc>()) {
        di<FetchUserDataBloc>().add(
          const FetchMyDataEvent(
            isLoading: false,
          ),
        );
      }

      // Reconcile with backend without showing a loading state.
      Future<void>.delayed(
        const Duration(milliseconds: 350),
            () {
          if (mounted) {
            _fetchRequests(silent: true);
          }
        },
      );
    } on DioException catch (e) {
      Methods.printLog(
        '🚨 [ROLE_REQUESTS][${accept ? 'ACCEPT' : 'REJECT'}] '
            'id=${item.id} '
            'status=${e.response?.statusCode} '
            'message=${e.message}',
      );

      if (!mounted) return;

      setState(() {
        final next = <int>{..._actingIds};
        next.remove(item.id);
        _actingIds = next;
      });

      Methods.showToast(
        context,
        message: _extractErrorMessage(
          e.response?.data,
          fallback: accept
              ? 'Could not accept this request.'
              : 'Could not reject this request.',
        ),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        final next = <int>{..._actingIds};
        next.remove(item.id);
        _actingIds = next;
      });

      Methods.showToast(
        context,
        message: e is StateError
            ? e.message
            : accept
            ? 'Could not accept this request.'
            : 'Could not reject this request.',
        isError: true,
      );
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map(
            (key, item) => MapEntry(
          key.toString(),
          item,
        ),
      );
    }

    return <String, dynamic>{};
  }

  static String _extractSuccessMessage(
      dynamic value, {
        required String fallback,
      }) {
    final map = _asMap(value);
    final message = map['message']?.toString().trim();

    return message == null || message.isEmpty
        ? fallback
        : message;
  }

  static String _extractErrorMessage(
      dynamic value, {
        required String fallback,
      }) {
    final map = _asMap(value);

    final message = map['message']?.toString().trim();

    if (message != null && message.isNotEmpty) {
      return message;
    }

    final errors = map['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;

      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }

      return first.toString();
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading && _requests.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          10.w,
          4.h,
          10.w,
          2.h,
        ),
        child: const _RoleRequestLoadingCard(),
      );
    }

    if (_errorMessage != null && _requests.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          10.w,
          4.h,
          10.w,
          2.h,
        ),
        child: _RoleRequestErrorCard(
          message: _errorMessage!,
          onRetry: () {
            setState(() => _errorMessage = null);
            _fetchRequests(initial: true);
          },
        ),
      );
    }

    if (_requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10.w,
          4.h,
          10.w,
          2.h,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            10.w,
            11.h,
            10.w,
            10.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 35.w,
                      height: 35.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11.r),
                        gradient: const LinearGradient(
                          colors: _actionGradient,
                        ),
                      ),
                      child: Icon(
                        Icons.assignment_ind_rounded,
                        color: Colors.white,
                        size: 20.h,
                      ),
                    ),
                    9.wBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            'Role Requests',
                            isTranslate: false,
                            style: context.bodyMedium
                                .size(14)
                                .bold
                                .colorExt(
                              const Color(0xFF17141D),
                            ),
                          ),
                          2.hBox,
                          TextWidget(
                            '${_requests.length} pending invitation${_requests.length == 1 ? '' : 's'}',
                            isTranslate: false,
                            style: context.bodySmall
                                .size(10.5)
                                .colorExt(
                              const Color(0xFF807B87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_refreshing)
                      SizedBox(
                        width: 16.h,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: Color(0xFF6D37F5),
                        ),
                      )
                    else
                      InkWell(
                        onTap: () =>
                            _fetchRequests(silent: true),
                        borderRadius:
                        BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: const Color(0xFF6D37F5),
                            size: 19.h,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              9.hBox,
              for (int index = 0;
              index < _requests.length;
              index++) ...[
                _RoleRequestCard(
                  key: ValueKey(
                    'role_request_${_requests[index].id}',
                  ),
                  item: _requests[index],
                  isLoading:
                  _actingIds.contains(_requests[index].id),
                  onAccept: () => _respond(
                    _requests[index],
                    accept: true,
                  ),
                  onReject: () => _respond(
                    _requests[index],
                    accept: false,
                  ),
                ),
                if (index != _requests.length - 1)
                  8.hBox,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleRequestCard extends StatelessWidget {
  const _RoleRequestCard({
    super.key,
    required this.item,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
  });

  static const List<Color> _acceptGradient = [
    Color(0xFF8E2BFF),
    Color(0xFF503CFF),
    Color(0xFF29D7FF),
  ];

  final _RoleRequestItem item;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.fromLTRB(
        11.w,
        11.h,
        11.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: const Color(0xFFE8E4EF),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserImage(
                imageSize: 47.w,
                image: EndPoints.getImage(item.senderImage),
                displayName: item.senderName,
              ),
              10.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextWidget(
                            item.senderName.isEmpty
                                ? 'Official'
                                : item.senderName,
                            isTranslate: false,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: context.bodyMedium
                                .size(13.5)
                                .bold
                                .colorExt(
                              const Color(0xFF17141D),
                            ),
                          ),
                        ),
                        if (item.createdAtHuman.isNotEmpty)
                          TextWidget(
                            item.createdAtHuman,
                            isTranslate: false,
                            maxLines: 1,
                            style: context.bodySmall
                                .size(9.5)
                                .colorExt(
                              const Color(0xFF8B8790),
                            ),
                          ),
                      ],
                    ),
                    4.hBox,
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 5.h,
                      children: [
                        _RoleChip(
                          icon: Icons.workspace_premium_rounded,
                          text: item.roleLabel,
                        ),
                        if (item.country.isNotEmpty)
                          _RoleChip(
                            icon: Icons.public_rounded,
                            text: item.country,
                            light: true,
                          ),
                      ],
                    ),
                    if (item.agencyName.isNotEmpty) ...[
                      5.hBox,
                      TextWidget(
                        item.agencyName,
                        isTranslate: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodySmall
                            .size(10.5)
                            .w600
                            .colorExt(
                          const Color(0xFF6D37F5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (item.notes.isNotEmpty) ...[
            9.hBox,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFEEEAF2),
                ),
              ),
              child: TextWidget(
                item.notes,
                isTranslate: false,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall
                    .size(10.8)
                    .colorExt(
                  const Color(0xFF66616D),
                ),
              ),
            ),
          ],
          10.hBox,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                      const Color(0xFF3B3740),
                      side: const BorderSide(
                        color: Color(0xFFDCD8E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(19.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: TextWidget(
                      'Reject',
                      isTranslate: false,
                      style: context.bodyMedium
                          .size(12)
                          .bold
                          .colorExt(
                        const Color(0xFF3B3740),
                      ),
                    ),
                  ),
                ),
              ),
              8.wBox,
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading ? null : onAccept,
                      borderRadius:
                      BorderRadius.circular(19.r),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(19.r),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: _acceptGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6D37F5)
                                  .withValues(alpha: 0.18),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                            width: 17.h,
                            height: 17.h,
                            child:
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : TextWidget(
                            'Accept',
                            isTranslate: false,
                            style: context.bodyMedium
                                .size(12)
                                .bold
                                .colorExt(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.icon,
    required this.text,
    this.light = false,
  });

  final IconData icon;
  final String text;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: light
            ? const Color(0xFFF0EEF3)
            : const Color(0xFF6D37F5)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.h,
            color: light
                ? const Color(0xFF77717E)
                : const Color(0xFF6D37F5),
          ),
          4.wBox,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 130.w,
            ),
            child: TextWidget(
              text,
              isTranslate: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall
                  .size(9.8)
                  .w600
                  .colorExt(
                light
                    ? const Color(0xFF77717E)
                    : const Color(0xFF6D37F5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRequestLoadingCard extends StatelessWidget {
  const _RoleRequestLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.h,
            height: 20.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6D37F5),
            ),
          ),
          12.wBox,
          Expanded(
            child: TextWidget(
              'Checking role requests...',
              isTranslate: false,
              style: context.bodyMedium
                  .size(12)
                  .w600
                  .colorExt(
                const Color(0xFF4D4852),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRequestErrorCard extends StatelessWidget {
  const _RoleRequestErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        13.w,
        11.h,
        10.w,
        11.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFFDC5364),
            size: 20.h,
          ),
          9.wBox,
          Expanded(
            child: TextWidget(
              message,
              isTranslate: false,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall
                  .size(10.8)
                  .colorExt(
                const Color(0xFF5F5964),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF6D37F5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRequestItem {
  const _RoleRequestItem({
    required this.id,
    required this.userId,
    required this.role,
    required this.roleLabel,
    required this.status,
    required this.country,
    required this.agencyId,
    required this.agencyName,
    required this.agencyImage,
    required this.senderId,
    required this.senderPublicId,
    required this.senderName,
    required this.senderImage,
    required this.senderType,
    required this.notes,
    required this.createdAt,
    required this.createdAtHuman,
  });

  factory _RoleRequestItem.fromJson(
      Map<String, dynamic> json,
      ) {
    final agency = _map(json['agency']);
    final sender = _map(json['sender']);

    final role = _string(json['role']);

    return _RoleRequestItem(
      id: _int(json['id']),
      userId: _int(json['user_id']),
      role: role,
      roleLabel: _string(json['role_label']).isNotEmpty
          ? _string(json['role_label'])
          : _prettyRole(role),
      status: _string(json['status']).isEmpty
          ? 'pending'
          : _string(json['status']),
      country: _string(json['permisioncountry']),
      agencyId: _int(
        json['agency_id'] ?? agency['id'],
      ),
      agencyName: _string(agency['name']),
      agencyImage: _string(agency['profile_image']),
      senderId: _int(sender['id']),
      senderPublicId: _string(sender['user_id']),
      senderName: _string(sender['name']),
      senderImage: _string(sender['profile_image']),
      senderType: _string(sender['user_type']),
      notes: _string(json['notes']),
      createdAt: _string(json['created_at']),
      createdAtHuman: _string(
        json['created_at_human'],
      ),
    );
  }

  final int id;
  final int userId;

  final String role;
  final String roleLabel;
  final String status;
  final String country;

  final int agencyId;
  final String agencyName;
  final String agencyImage;

  final int senderId;
  final String senderPublicId;
  final String senderName;
  final String senderImage;
  final String senderType;

  final String notes;
  final String createdAt;
  final String createdAtHuman;

  DateTime get sortDate =>
      DateTime.tryParse(createdAt)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map(
            (key, item) => MapEntry(
          key.toString(),
          item,
        ),
      );
    }

    return <String, dynamic>{};
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _string(dynamic value) =>
      value?.toString().trim() ?? '';

  static String _prettyRole(String value) {
    if (value.trim().isEmpty) return 'Role Invitation';

    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
      '${part[0].toUpperCase()}${part.substring(1)}',
    )
        .join(' ');
  }
}
