class ServerMessageTranslator {
  static String translate(String message) {
    final String text = message.trim();
    if (text.isEmpty) {
      return text;
    }

    final String normalized = text
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase()
        .trim();

    const Map<String, String> exactMessages = {
      'otp does not match': 'ერთჯერადი კოდი არ ემთხვევა.',
      'the otp does not match': 'ერთჯერადი კოდი არ ემთხვევა.',
      'invalid otp': 'ერთჯერადი კოდი არასწორია.',
      'invalid token': 'კოდი არასწორია.',
      'otp verified successfully': 'ერთჯერადი კოდი წარმატებით დადასტურდა.',
      'otp successfully sent': 'ერთჯერადი კოდი წარმატებით გაიგზავნა.',
      'phone number not found': 'ტელეფონის ნომერი ვერ მოიძებნა.',
      'email not found': 'ელფოსტა ვერ მოიძებნა.',
      'validation.password.uncompromised':
          'ეს პაროლი უსაფრთხო არ არის. გთხოვთ, აირჩიოთ სხვა პაროლი.',
      'the password is compromised. please choose a different one':
          'ეს პაროლი უსაფრთხო არ არის. გთხოვთ, აირჩიოთ სხვა პაროლი.',
      'the password must contain both uppercase and lowercase letters':
          'პაროლი უნდა შეიცავდეს დიდ და პატარა ასოებს.',
      'the password must contain letters': 'პაროლი უნდა შეიცავდეს ასოებს.',
      'the password must contain numbers': 'პაროლი უნდა შეიცავდეს ციფრებს.',
      'the password must contain symbols':
          'პაროლი უნდა შეიცავდეს სპეციალურ სიმბოლოს.',
      'the password is required': 'პაროლის ველი სავალდებულოა.',
      'the password field is required': 'პაროლის ველი სავალდებულოა.',
      'the type field is required': 'მიწოდების ტიპის ველი სავალდებულოა.',
      'the selected type is invalid': 'არჩეული ტიპი არასწორია.',
      'the selected otp is invalid': 'ერთჯერადი კოდი არასწორია.',
      'the selected phone is invalid': 'ტელეფონის ნომერი არასწორია.',
      'the selected email is invalid': 'ელფოსტა არასწორია.',
      'the email has already been taken': 'ეს ელფოსტა უკვე გამოყენებულია.',
      'the phone has already been taken':
          'ეს ტელეფონის ნომერი უკვე გამოყენებულია.',
      'the identity number has already been taken':
          'ეს პირადი ნომერი უკვე გამოყენებულია.',
      'the referral code is invalid': 'რეფერალური კოდი არასწორია.',
      'order cancelled succesfully': 'შეკვეთა წარმატებით გაუქმდა.',
      'order cancelled successfully': 'შეკვეთა წარმატებით გაუქმდა.',
      'order canceled successfully': 'შეკვეთა წარმატებით გაუქმდა.',
      'successfully added': 'წარმატებით დაემატა.',
      'successfully removed': 'წარმატებით წაიშალა.',
      'address deleted successfully': 'მისამართი წარმატებით წაიშალა.',
      'item already exists': 'ნივთი უკვე დამატებულია.',
      'cart item remove successfully': 'ნივთი კალათიდან წარმატებით წაიშალა.',
      'request failed': 'მოთხოვნა ვერ შესრულდა.',
      'internal server error': 'სერვერის შიდა შეცდომა.',
      'unauthenticated': 'ავტორიზაცია საჭიროა.',
      'unauthorized': 'ამ მოქმედების უფლება არ გაქვთ.',
      'not found': 'მონაცემები ვერ მოიძებნა.',
    };

    final String normalizedWithoutDot = _stripTrailingDot(normalized);
    final String? exact =
        exactMessages[normalizedWithoutDot] ?? exactMessages[normalized];
    if (exact != null) {
      return exact;
    }

    final String? fieldRequired = _translateFieldRequired(normalizedWithoutDot);
    if (fieldRequired != null) {
      return fieldRequired;
    }

    final String? minCharacters = _translateMinCharacters(normalizedWithoutDot);
    if (minCharacters != null) {
      return minCharacters;
    }

    final String? maxFileSize = _translateMaxFileSize(normalizedWithoutDot);
    if (maxFileSize != null) {
      return maxFileSize;
    }

    final String? imageValidation = _translateImageValidation(
      normalizedWithoutDot,
    );
    if (imageValidation != null) {
      return imageValidation;
    }

    final String? alreadyTaken = _translateAlreadyTaken(normalizedWithoutDot);
    if (alreadyTaken != null) {
      return alreadyTaken;
    }

    return text;
  }

  static String _stripTrailingDot(String value) {
    return value.endsWith('.') ? value.substring(0, value.length - 1) : value;
  }

  static String? _translateFieldRequired(String normalized) {
    final Match? match = RegExp(
      r'^the (.+) field is required$',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final String field = _fieldName(match.group(1) ?? '');
    return '$field ველი სავალდებულოა.';
  }

  static String? _translateMinCharacters(String normalized) {
    final Match? match = RegExp(
      r'^the (.+) (field )?must be at least ([0-9]+) characters( long)?$',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final String field = _fieldName(match.group(1) ?? '');
    final String count = match.group(3) ?? '';
    return '$field უნდა იყოს მინიმუმ $count სიმბოლო.';
  }

  static String? _translateMaxFileSize(String normalized) {
    final Match? match = RegExp(
      r'^the (.+) (field )?must not be greater than ([0-9]+) kilobytes$',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final String field = _fieldName(match.group(1) ?? '');
    return '$field-ის ფაილის ზომა ზედმეტად დიდია.';
  }

  static String? _translateImageValidation(String normalized) {
    final Match? imageMatch = RegExp(
      r'^the (.+) (field )?must be an image$',
    ).firstMatch(normalized);
    if (imageMatch != null) {
      final String field = _fieldName(imageMatch.group(1) ?? '');
      return '$field უნდა იყოს სურათი.';
    }

    final Match? mimeMatch = RegExp(
      r'^the (.+) (field )?must be a file of type: (.+)$',
    ).firstMatch(normalized);
    if (mimeMatch != null) {
      final String field = _fieldName(mimeMatch.group(1) ?? '');
      return '$field-ის ფაილის ტიპი არასწორია.';
    }

    return null;
  }

  static String? _translateAlreadyTaken(String normalized) {
    final Match? match = RegExp(
      r'^the (.+) has already been taken$',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final String field = _fieldName(match.group(1) ?? '');
    return '$field უკვე გამოყენებულია.';
  }

  static String _fieldName(String rawField) {
    final String field = rawField
        .replaceAll(RegExp(r'\.[0-9]+'), '')
        .replaceAll('_', ' ')
        .trim();

    const Map<String, String> fields = {
      'otp': 'ერთჯერადი კოდი',
      'verification code': 'დადასტურების კოდი',
      'token': 'კოდი',
      'type': 'მიწოდების ტიპი',
      'delivery type': 'მიწოდების ტიპი',
      'earning': 'კურიერის ტიპი',
      'email': 'ელფოსტა',
      'phone': 'ტელეფონის ნომერი',
      'password': 'პაროლი',
      'confirm password': 'პაროლის დადასტურება',
      'f name': 'სახელი',
      'first name': 'სახელი',
      'l name': 'გვარი',
      'last name': 'გვარი',
      'name': 'სახელი',
      'identity type': 'პირადობის ტიპი',
      'identity number': 'პირადი ნომერი',
      'identity image': 'პირადობის სურათი',
      'image': 'სურათი',
      'cover photo': 'გარეკანის ფოტო',
      'logo': 'ლოგო',
      'zone id': 'ზონა',
      'zone': 'ზონა',
      'vehicle id': 'ტრანსპორტი',
      'vehicle': 'ტრანსპორტი',
      'referral code': 'რეფერალური კოდი',
      'address': 'მისამართი',
      'store name': 'მაღაზიის სახელი',
      'store address': 'მაღაზიის მისამართი',
      'tin': 'საიდენტიფიკაციო ნომერი',
      'tax': 'გადასახადი',
      'vat tax': 'დღგ',
    };

    return fields[field] ?? field;
  }
}
