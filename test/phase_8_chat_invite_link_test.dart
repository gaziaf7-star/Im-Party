// Phase 8 — pure-logic unit tests for the new chat invite / deep-link surface:
//   * InviteShare.buildInviteLink: store URL without an inviter, the verified
//     `profile_` deep link with one, appURL precedence, and input trimming.
//   * ContactDiscoveryResult.isEmpty: empty only when both lists are empty.

import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/constants/constants_manager.dart';
import 'package:general/src/core/constants/end_points.dart';
import 'package:general/src/features/chats/data/contact_discovery_service.dart';
import 'package:general/src/features/chats/data/invite_share.dart';

void main() {
  group('InviteShare.buildInviteLink', () {
    final savedAppUrl = ConstantsManager.appURL;

    tearDown(() => ConstantsManager.appURL = savedAppUrl);

    test('without an inviter falls back to the store URL', () {
      ConstantsManager.appURL = '';
      final link = InviteShare.buildInviteLink();
      expect(link, contains('play.google.com'));
      expect(link, isNot(contains('deeplink')));
    });

    test('without an inviter uses the admin-configured appURL when set', () {
      ConstantsManager.appURL = 'https://store.example/app';
      expect(InviteShare.buildInviteLink(), 'https://store.example/app');
    });

    test('with an inviter builds the verified profile deep link', () {
      final link = InviteShare.buildInviteLink(inviterUserId: '123');
      expect(link, '${EndPoints.domainURL}/deeplink?data=profile_123');
    });

    test('with an inviter the deep link ignores appURL so it opens the app', () {
      ConstantsManager.appURL = 'https://store.example/app';
      final link = InviteShare.buildInviteLink(inviterUserId: '99');
      expect(link, '${EndPoints.domainURL}/deeplink?data=profile_99');
    });

    test('trims whitespace around the inviter id', () {
      final link = InviteShare.buildInviteLink(inviterUserId: '  456  ');
      expect(link, '${EndPoints.domainURL}/deeplink?data=profile_456');
    });

    test('a blank inviter id is treated as no inviter', () {
      ConstantsManager.appURL = 'https://store.example/app';
      expect(
        InviteShare.buildInviteLink(inviterUserId: '   '),
        'https://store.example/app',
      );
    });
  });

  group('ContactDiscoveryResult.isEmpty', () {
    test('is empty only when both registered and unregistered are empty', () {
      const empty = ContactDiscoveryResult(registered: [], unregistered: []);
      expect(empty.isEmpty, isTrue);

      const withRegistered = ContactDiscoveryResult(
        registered: [
          DiscoveredContact(userId: 1, name: 'A', avatar: ''),
        ],
        unregistered: [],
      );
      expect(withRegistered.isEmpty, isFalse);

      const withUnregistered = ContactDiscoveryResult(
        registered: [],
        unregistered: [UnregisteredContact(name: 'B', phone: '+100')],
      );
      expect(withUnregistered.isEmpty, isFalse);
    });
  });
}
