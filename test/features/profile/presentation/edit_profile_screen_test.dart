import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrapify/features/profile/presentation/edit_profile_screen.dart';
import 'package:scrapify/features/profile/domain/repositories/profile_repository.dart';
import 'package:scrapify/features/auth/providers/auth_provider.dart';
import 'package:scrapify/features/auth/domain/models/user.dart';
import 'package:scrapify/features/profile/providers/profile_provider.dart';
import 'package:scrapify/core/network/api_response.dart';
import 'package:scrapify/features/auth/domain/repositories/auth_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<ApiResponse<void>> updateProfile({
    String? name,
    String? email,
    int? cityId,
    File? profilePhoto,
    bool removePhoto = false,
  }) async {
    return ApiResponse.success(null, statusCode: 200);
  }
}

class FakeAuthRepository implements AuthRepository {
  final User mockUser;
  FakeAuthRepository(this.mockUser);

  @override
  Future<String?> getToken() async => 'fake_token';

  @override
  Future<User?> getUser() async => mockUser;

  @override
  Future<ApiResponse<User>> fetchProfile() async =>
      ApiResponse.success(mockUser);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('EditProfileScreen renders without exploding', (
    WidgetTester tester,
  ) async {
    final mockUser = User(
      id: 1,
      name: 'Test Name',
      phone: '1234567890',
      roles: [],
      cityId: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(mockUser),
          ),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: const MaterialApp(home: EditProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });
}
