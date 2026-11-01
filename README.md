# BookNest

A warm, editorial-style book tracking app built with Flutter, inspired by Goodreads. Search for books, build your own library, track what you are reading, rate and review books, and work towards a yearly reading goal. Everything is stored on your device.

Built as a 3rd-year CSE college project. Runs on Android and in Chrome.

## Features

- **Home**: greeting, reading-goal progress ring, Continue Reading (with progress bars), sample "Pick Up Your Next Read" suggestions, Recently Added, and a Reading Inspiration quote card (sample quotes).
- **Discover**: search by title, author or keyword using the [Open Library](https://openlibrary.org/developers/api) API, plus genre chips (Fiction, Fantasy, Mystery, Romance, Science Fiction). Search waits for you to stop typing before sending a request. If you are offline, matching built-in sample books are shown instead.
- **Book details**: cover, author, first-published year, publisher and a description loaded from Open Library (with Read more / Show less). Descriptions are never invented; if none exists a short note is shown. You can set the reading status, progress, favorite, a 1-5 star rating and a personal review.
- **My Books**: tabs for All / Want to Read / Currently Reading / Read with live counts, sorting (recently added, title, rating), quick status changes, and removal with confirmation.
- **Profile**: editable display name, reading stats calculated from your library, an editable yearly goal, and a System / Light / Dark theme choice.
- Duplicate books are prevented (matched by Open Library ID or by title + author).
- On first launch three clearly-labelled sample books are added to the library. They are only added once.
- If saving to the device fails, the app keeps working for the session and shows a message.

## Tech

- Flutter / Dart (Material 3, custom theme)
- Packages: [`http`](https://pub.dev/packages/http) (Open Library requests) and [`shared_preferences`](https://pub.dev/packages/shared_preferences) (local storage)
- State: a single `ChangeNotifier` (`Library`) shared through an `InheritedNotifier`, with no state-management package
- No backend, accounts, API keys or Firebase

## Project structure

| File | Purpose |
| --- | --- |
| `lib/main.dart` | App entry, theme mode, bottom navigation (tabs keep their state) |
| `lib/book.dart` | `Book` model, reading statuses, JSON conversion, sample books and quotes |
| `lib/library.dart` | `Library`: saves/loads books and preferences, add/update/remove, counts and sorting |
| `lib/api.dart` | Open Library search and description requests |
| `lib/widgets.dart` | Design tokens (spacing, radii), light/dark themes, reusable widgets (covers, tiles, chips, empty states) |
| `lib/home.dart`, `discover.dart`, `details.dart`, `my_books.dart`, `profile.dart` | The screens |
| `test/widget_test.dart` | Tests for the library logic, persistence, corrupt data, navigation and layout at narrow and wide widths |

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```bash
flutter pub get
flutter run -d chrome     # run in Chrome
flutter run               # run on a connected Android device or emulator
```

Quality checks:

```bash
flutter analyze
flutter test
flutter build web
```

On Windows, building for Android (or any plugin-based desktop build) requires Developer Mode to be enabled for symlink support: run `start ms-settings:developers`.

## Data and privacy

Your library, rating, reviews, goal, name and theme are stored locally with `shared_preferences` (browser storage in Chrome). Nothing is sent anywhere except search and description requests to Open Library. Book covers are loaded directly from Open Library.

## Credits

Book data and covers: [Open Library](https://openlibrary.org).
