import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/model/invitation.dart';
import 'package:music_room/core/notification/controller.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/friend/controller.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/inbox/impl_repository.dart';
import 'package:music_room/features/inbox/provider.dart';
import 'package:music_room/features/inbox/state.dart';
import 'package:music_room/features/room/provider.dart';

class InboxController extends Notifier<InboxState> with WidgetsBindingObserver {
  static const Duration _refreshInterval = Duration(seconds: 10);

  Timer? _refreshTimer;

  InboxRepository get         _repo => ref.read(inboxRepositoryProvider);
  FriendController get        _friend => ref.read(friendProvider.notifier);
  NotificationController get  _notification => ref.read(notificationProvider.notifier);

  @override
  InboxState build() {
    final isAuthenticated = ref.watch(authProvider.select((s) => s.isAuthenticated));
    ref.onDispose(_stopRefreshing);
    if (isAuthenticated) _startRefreshing();
    return const InboxState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshInBackground();
  }

  Future<void>  refresh() async {
    await Future.wait([
      _refreshInvitations(),
      _refreshFriendRequests(),
    ]);
  }

  void  refreshInBackground() {
    unawaited(refresh().catchError((Object e) {
      logger.debug('Fail to refresh inbox: $e');
    }));
  }

  Future<void>  acceptInvitation(Invitation invitation) async {
    await _repo.acceptInvitation(invitation.id);
    _removeInvitation(invitation);
    await ref.read(roomProvider.notifier).onRefreshRoom();
  }

  Future<void>  rejectInvitation(Invitation invitation) async {
    await _repo.rejectInvitation(invitation.id);
    _removeInvitation(invitation);
  }

  void  _startRefreshing() {
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => refreshInBackground());
    refreshInBackground();
  }

  void  _stopRefreshing() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void>  _refreshInvitations() async {
    final invitations = await _repo.getInvitations();
    _newInvitations(invitations).forEach(_notifyInvitation);
    state = state.copyWith(invitations: invitations);
  }

  Iterable<Invitation>  _newInvitations(List<Invitation> invitations) {
    final knownIds = state.invitations.map((invitation) => invitation.id).toSet();
    return invitations.where((invitation) => !knownIds.contains(invitation.id));
  }

  void  _notifyInvitation(Invitation invitation) {
    _notification.hint(
      'Room invitation',
      description: '${invitation.inviterUsername ?? 'Someone'} invited you to a room.',
    );
  }

  void  _removeInvitation(Invitation invitation) {
    final invitations = state.invitations.where((i) => i.id != invitation.id).toList();
    state = state.copyWith(invitations: invitations);
  }

  Future<void>  _refreshFriendRequests() async {
    final knownIds = _pendingFriendRequestIds();
    await _friend.refreshFriends();
    _newFriendRequests(knownIds).forEach(_notifyFriendRequest);
  }

  Set<String> _pendingFriendRequestIds() {
    return ref.read(friendProvider).pendingRequests
      .map((friend) => friend.friendId)
      .toSet();
  }

  Iterable<Friend>  _newFriendRequests(Set<String> knownIds) {
    return ref.read(friendProvider).pendingRequests
      .where((friend) => !knownIds.contains(friend.friendId));
  }

  void  _notifyFriendRequest(Friend friend) {
    _notification.hint(
      'Friend request',
      description: '${friend.username ?? 'Someone'} wants to be your friend.',
    );
  }
}
