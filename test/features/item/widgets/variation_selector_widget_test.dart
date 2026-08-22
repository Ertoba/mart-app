import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/item/widgets/variation_selector_widget.dart';

void main() {
  group('technical variation brand resolution', () {
    test(
      'recognizes supported model attribute titles in all app languages',
      () {
        expect(isTechnicalModelTitle('Model'), isTrue);
        expect(isTechnicalModelTitle('მოდელი'), isTrue);
        expect(isTechnicalModelTitle('Телефонис модели'), isFalse);
        expect(isTechnicalModelTitle('Модель'), isTrue);
        expect(isTechnicalModelTitle('ტელეფონის მოდელი'), isTrue);
        expect(isTechnicalBrandTitle('Brand'), isTrue);
        expect(isTechnicalBrandTitle('ბრენდი'), isTrue);
        expect(isTechnicalBrandTitle('Бренд'), isTrue);
      },
    );

    test('maps the production shorthand models to the correct brands', () {
      expect(inferTechnicalBrandKey('A16'), 'samsung');
      expect(inferTechnicalBrandKey('S24 Ultra'), 'samsung');
      expect(inferTechnicalBrandKey('აიფონ 11'), 'iphone');
      expect(inferTechnicalBrandKey('17 Pro Max'), 'iphone');
      expect(inferTechnicalBrandKey('Redmi Note 14'), 'redmi');
    });

    test('selects the matching hidden legacy brand atomically with model', () {
      const brands = <String>['აიფონი', 'სამსუნგი'];

      expect(legacyBrandIndexForTechnicalModel('A16', brands), 1);
      expect(legacyBrandIndexForTechnicalModel('აიფონ 11', brands), 0);
      expect(
        legacyBrandIndexForTechnicalModel('Unknown model', brands),
        isNull,
      );
    });
  });
}
