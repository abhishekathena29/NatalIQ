import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The five bottom-nav tab destinations. Tapping into one of these always
/// replaces the whole stack (`go`) — switching tabs shouldn't pile up back
/// history. Every other route is a "detail" screen reached by drilling in,
/// so it should be pushed, keeping a proper back stack and enabling the
/// back button / system back gesture.
const _tabPaths = {'/', '/chat', '/track', '/community', '/more'};

/// Navigates to [path] the right way for what kind of destination it is:
/// `go` for a bottom-nav tab, `push` for everything else.
void navigateTo(BuildContext context, String path) {
  if (_tabPaths.contains(path)) {
    context.go(path);
  } else {
    context.push(path);
  }
}
