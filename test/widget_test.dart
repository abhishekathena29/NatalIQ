import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/main.dart';

void main() {
  testWidgets('Signed-out users land on the login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugOverrideBackends(
      auth: MockFirebaseAuth(signedIn: false),
      firestore: FakeFirebaseFirestore(),
    );
    await AuthService.instance.init();

    await tester.pumpWidget(const AanyaApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
