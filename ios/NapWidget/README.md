# Nap Timer — iOS widget setup

WidgetKit requires its own Xcode target (a "Widget Extension"), and creating
build targets by hand-editing `project.pbxproj` is too easy to get wrong in a
way that's hard to undo. This folder has the widget's Swift source already
written; you just need to wire up the Xcode target itself. Takes about 5
minutes.

## Steps

1. Open `ios/Runner.xcworkspace` in Xcode (not the `.xcodeproj`).
2. **File → New → Target… → Widget Extension.**
   - Product Name: `NapWidget`
   - Uncheck **"Include Configuration Intent"** (this widget has no user
     configuration).
   - Team/bundle id: match your existing signing setup.
   - When Xcode asks to "Activate" the new scheme, click Activate.
3. Xcode will have generated a `NapWidget/` group with its own
   `NapWidget.swift` and `NapWidgetBundle.swift` (and an `Assets.xcassets`).
   **Delete the generated `NapWidget.swift` and `NapWidgetBundle.swift`**
   (Move to Trash), then drag the two files from this repo's
   `ios/NapWidget/` folder — `NapWidget.swift` and `NapWidgetBundle.swift` —
   into the same Xcode group, making sure **"NapWidgetExtension"** (the new
   target) is checked in "Add to targets".
4. **Add the App Group capability to both targets** (so the app and the
   widget can share nap status via `UserDefaults`):
   - Select the **Runner** target → **Signing & Capabilities** → **+
     Capability** → **App Groups** → **+** → add
     `group.com.example.natalIq.nap`. Xcode will offer to create/select an
     entitlements file — point it at the existing
     `ios/Runner/Runner.entitlements` (already in the repo with this group
     pre-filled) rather than letting it create a new one.
   - Select the **NapWidgetExtension** target → **Signing & Capabilities** →
     **+ Capability** → **App Groups** → check the same
     `group.com.example.natalIq.nap` (or point it at
     `ios/NapWidget/NapWidget.entitlements`, also already in the repo).
   - **The group id must match exactly** on both targets and the constant
     `napWidgetAppGroupId` in
     `lib/features/nap/services/nap_timer_service.dart` — if you change it
     in Xcode, update that Dart constant too.
5. Build & run. Long-press the iOS Home Screen → **+** → search "Aanya" /
   "Nap Timer" → add the widget.

## What it does — and its one real limitation

- The widget shows **"Not napping"** or **"Napping since h:mm a"**, updated
  whenever the app calls `HomeWidget.updateWidget` (on nap start/stop) — not
  on a live per-second tick, since WidgetKit timelines aren't meant for
  that.
- **Tapping the widget opens the app and jumps straight to the nap timer
  screen** via the `napwidget://nap` URL scheme (already registered in
  `ios/Runner/Info.plist` and handled in `lib/main.dart`).
- **It cannot start or stop the nap directly from the widget itself.**
  WidgetKit only supports true interactive buttons (no app launch required)
  via **AppIntents on iOS 17+**, which needs more native Swift wiring
  (an `AppIntent` + `IntentTimelineProvider` changes) beyond this first
  version. Flagging this explicitly rather than shipping something that
  looks tappable-to-start but silently just opens the app.
