import 'package:flutter/material.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booknest/book.dart';
import 'package:booknest/library.dart';
import 'package:booknest/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('library prevents duplicates and derives counts', () async {
    final lib = Library();
    await lib.load();
    expect(lib.books.length, 3); // seeded samples

    const book = Book(id: '/works/OL1W', title: 'New Book', author: 'Someone');
    expect(lib.save(book), isTrue);
    expect(lib.save(book), isFalse); // same id: update, not duplicate
    expect(
      lib.save(
        const Book(id: '/works/OL2W', title: 'new book!', author: 'someone'),
      ),
      isFalse,
    ); // same title+author
    expect(lib.books.length, 4);

    lib.setStatus(book, ReadingStatus.read);
    expect(lib.readCount, 2);
    lib.remove(book);
    expect(lib.books.length, 3);
  });

  test('library persists and reloads', () async {
    final a = Library();
    await a.load();
    a.setName('Ada');
    a.setGoal(5);
    a.setStatus(a.books.first, ReadingStatus.read);
    await Future<void>.delayed(Duration.zero);

    final b = Library();
    await b.load();
    expect(b.name, 'Ada');
    expect(b.goal, 5);
    expect(b.books.length, 3);
    expect(b.readCount, 2);
  });

  test('malformed stored data is ignored', () async {
    SharedPreferences.setMockInitialValues({
      'books': 'not json',
      'seeded': true,
    });
    final lib = Library();
    await lib.load();
    expect(lib.books, isEmpty);
  });

  testWidgets('app shows home and navigates', (tester) async {
    await tester.pumpWidget(const BookNestApp());
    await tester.pumpAndSettle();
    expect(find.text('Continue Reading'), findsOneWidget);
    await tester.tap(find.text('My Books').last);
    await tester.pumpAndSettle();
    expect(find.text('All (3)'), findsOneWidget);
  });

  for (final size in [const Size(320, 640), const Size(1400, 900)]) {
    testWidgets('no layout errors at ${size.width.toInt()}px wide', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const BookNestApp());
      await tester.pumpAndSettle();
      for (final tab in ['Discover', 'My Books', 'Profile', 'Home']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tab $tab');
      }
      await tester.tap(find.text('My Books').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('The Hobbit').first);
      await tester.pumpAndSettle();
      expect(find.text('Your reading'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
