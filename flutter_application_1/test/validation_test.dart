import 'package:flutter_application_1/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Email Validation', () {
    test('Valid email returns true', () {
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name@domain.co'), true);
    });

    test('Invalid email returns false', () {
      expect(isValidEmail('testexample.com'), false);
      expect(isValidEmail('user@.com'), false);
      expect(isValidEmail('user@domain'), false);
      expect(isValidEmail(''), false);
    });
  });

  group('Password Validation', () {
    test('Valid password returns true', () {
      expect(isValidPassword('Password1'), true);
      expect(isValidPassword('StrongPass123'), true);
    });

    test('Invalid password returns false', () {
      expect(isValidPassword('password'), false); //without capital +num
      expect(isValidPassword('PASSWORD'), false); //without small +mun
      expect(isValidPassword('Pass'), false);  //less than 8
      expect(isValidPassword('pass1234'), false); //without capital
      expect(isValidPassword(''), false);
    });
  });
}
