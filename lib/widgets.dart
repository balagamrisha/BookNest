import 'package:flutter/material.dart';

import 'book.dart';
import 'library.dart';

// ---------- Design tokens ----------
// Spacing, radii and sizes live here so every screen stays consistent.

class Sp {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const page = 20.0; // side padding of every screen
}

const kRadius = 12.0; // cards, inputs, buttons
const kCoverRadius = 6.0; // book covers
const kCoverRatio = 2 / 3; // width / height of every cover
const kTileTextHeight = 62.0; // title + author area under a cover tile

const _serifFonts = ['Georgia', 'Cambria', 'Times New Roman', 'serif'];

// ---------- Theme ----------
// Colour roles:  primary = sage, secondary = bronze,
// surface = page background, surfaceContainer = cards,
// onSurface = main text (ivory in dark mode), onSurfaceVariant = muted text.

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark
      ? const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF9DBBA6), // sage
          onPrimary: Color(0xFF0E1F18),
          primaryContainer: Color(0xFF223A2E),
          onPrimaryContainer: Color(0xFFCFE3D5),
          secondary: Color(0xFFD39B6F), // bronze
          onSecondary: Color(0xFF2A1A0C),
          secondaryContainer: Color(0xFF3A2B1F),
          onSecondaryContainer: Color(0xFFEBC9A8),
          error: Color(0xFFE59A8A),
          onError: Color(0xFF2B0F0A),
          surface: Color(0xFF0F1D17), // deep forest
          onSurface: Color(0xFFF1EADA), // ivory
          onSurfaceVariant: Color(0xFFA9B7AC),
          surfaceContainer: Color(0xFF16271F),
          surfaceContainerHighest: Color(0xFF1F342A),
          outline: Color(0xFF47594F),
          outlineVariant: Color(0xFF2B4035),
        )
      : const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF2E5744), // forest
          onPrimary: Color(0xFFF8F3E7),
          primaryContainer: Color(0xFFDDE8DF),
          onPrimaryContainer: Color(0xFF1B3A2C),
          secondary: Color(0xFF9A5B30), // terracotta
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFF1E0CF),
          onSecondaryContainer: Color(0xFF5A3216),
          error: Color(0xFFB3412F),
          onError: Colors.white,
          surface: Color(0xFFF6F1E6), // ivory paper
          onSurface: Color(0xFF1B2B24),
          onSurfaceVariant: Color(0xFF5B6A60),
          surfaceContainer: Color(0xFFFFFCF5),
          surfaceContainerHighest: Color(0xFFEAE2D1),
          outline: Color(0xFF9AA399),
          outlineVariant: Color(0xFFDDD3BE),
        );

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kRadius),
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadius),
    borderSide: BorderSide(color: scheme.outlineVariant),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    dividerColor: scheme.outlineVariant,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamilyFallback: _serifFonts,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 66,
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 24,
          color: s.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          letterSpacing: 0.2,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: s.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Sp.md,
        vertical: 14,
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        side: BorderSide(color: scheme.outline),
        minimumSize: const Size(0, 44),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: scheme.secondaryContainer,
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      labelStyle: TextStyle(fontSize: 13.5, color: scheme.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: shape,
        side: BorderSide(color: scheme.outlineVariant),
        selectedBackgroundColor: scheme.primaryContainer,
        selectedForegroundColor: scheme.onPrimaryContainer,
        foregroundColor: scheme.onSurfaceVariant,
        backgroundColor: scheme.surfaceContainer,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: scheme.outlineVariant,
      indicatorColor: scheme.secondary,
      labelColor: scheme.onSurface,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.secondary,
      thumbColor: scheme.secondary,
      inactiveTrackColor: scheme.outlineVariant,
      valueIndicatorColor: scheme.secondary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.surfaceContainerHighest,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.secondary,
      linearTrackColor: scheme.outlineVariant,
      circularTrackColor: scheme.outlineVariant,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: shape,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      shape: shape,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      shape: shape,
    ),
  );
}

// ---------- Text styles ----------

/// Serif style for headings and quotes.
TextStyle serif(
  BuildContext context, {
  double size = 20,
  FontWeight weight = FontWeight.w700,
  Color? color,
  double? height,
}) => TextStyle(
  fontFamilyFallback: _serifFonts,
  fontSize: size,
  fontWeight: weight,
  height: height,
  color: color ?? Theme.of(context).colorScheme.onSurface,
);

/// Small uppercase label used above sections and for metadata.
TextStyle overline(BuildContext context, {Color? color}) => TextStyle(
  fontSize: 11.5,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.2,
  color: color ?? Theme.of(context).colorScheme.secondary,
);

TextStyle muted(BuildContext context, {double size = 13}) => TextStyle(
  fontSize: size,
  color: Theme.of(context).colorScheme.onSurfaceVariant,
);

// ---------- State access ----------

class LibraryScope extends InheritedNotifier<Library> {
  const LibraryScope({
    super.key,
    required Library library,
    required super.child,
  }) : super(notifier: library);
}

extension LibraryContext on BuildContext {
  /// The shared library. Widgets that call this rebuild when it changes.
  Library get lib =>
      dependOnInheritedWidgetOfExactType<LibraryScope>()!.notifier!;
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// ---------- Reusable widgets ----------

/// Keeps page content readable on wide screens (Chrome).
class Constrained extends StatelessWidget {
  const Constrained({super.key, required this.child, this.maxWidth = 820});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 30});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: c.secondary, width: 1.4),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.auto_stories,
            color: c.secondary,
            size: size * 0.58,
          ),
        ),
        const SizedBox(width: 10),
        Text('BookNest', style: serif(context, size: size * 0.68)),
      ],
    );
  }
}

/// A book cover with a fixed 2:3 shape. Falls back to a plain placeholder
/// (never an illustration) when there is no image or it fails to load.
class BookCover extends StatelessWidget {
  const BookCover(
    this.book, {
    super.key,
    this.width,
    this.radius = kCoverRadius,
  });
  final Book book;
  final double?
  width; // height follows from the 2:3 ratio; null = fill parent width
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final placeholder = Container(
      padding: const EdgeInsets.all(8),
      color: c.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        book.title,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: serif(
          context,
          size: 12,
          weight: FontWeight.w600,
          color: c.onSurfaceVariant,
        ),
      ),
    );
    final url = book.coverUrl;
    final cover = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: kCoverRatio,
          child: url == null
              ? placeholder
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : ColoredBox(color: c.surfaceContainerHighest),
                ),
        ),
      ),
    );
    return width == null ? cover : SizedBox(width: width, child: cover);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Sp.xl, bottom: Sp.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: serif(context, size: 21)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: muted(context, size: 12.5)),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Sp.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.outlineVariant),
                  color: c.surfaceContainer,
                ),
                child: Icon(icon, size: 30, color: c.secondary),
              ),
              const SizedBox(height: Sp.md),
              Text(
                title,
                style: serif(context, size: 19),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Sp.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: muted(context, size: 14).copyWith(height: 1.45),
              ),
              if (onAction != null) ...[
                const SizedBox(height: Sp.lg),
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel ?? 'OK'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill showing a reading status.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      ReadingStatus.wantToRead => (Colors.transparent, c.onSurfaceVariant),
      ReadingStatus.reading => (c.primaryContainer, c.onPrimaryContainer),
      ReadingStatus.read => (c.secondaryContainer, c.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == ReadingStatus.wantToRead
              ? c.outline
              : Colors.transparent,
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.5,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Stars extends StatelessWidget {
  const Stars(this.rating, {super.key, this.size = 15, this.onChanged});
  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          onChanged == null
              ? Icon(
                  i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: size,
                  color: color,
                )
              : IconButton(
                  tooltip: '$i star${i > 1 ? 's' : ''}',
                  visualDensity: VisualDensity.compact,
                  // tapping the current rating again clears it
                  onPressed: () => onChanged!(i == rating ? 0 : i),
                  icon: Icon(
                    i <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: size,
                    color: color,
                  ),
                ),
      ],
    );
  }
}

/// Thin progress bar used for goals and reading progress.
class ProgressBar extends StatelessWidget {
  const ProgressBar(this.value, {super.key, this.height = 5});
  final double value; // 0..1
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
    ),
  );
}

/// A book in a grid or carousel: 2:3 cover, then title and author in a
/// fixed-height area so every tile lines up.
class BookTile extends StatelessWidget {
  const BookTile(
    this.book, {
    super.key,
    required this.onTap,
    this.saved = false,
  });
  final Book book;
  final VoidCallback onTap;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(kCoverRadius),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              BookCover(book),
              if (saved)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: c.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 14, color: c.onSecondary),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: kTileTextHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: Sp.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted(context, size: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal row of [BookTile]s with a consistent size.
class BookCarousel extends StatelessWidget {
  const BookCarousel({
    super.key,
    required this.books,
    required this.onOpen,
    this.tileWidth = 118,
  });
  final List<Book> books;
  final void Function(Book) onOpen;
  final double tileWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: tileWidth / kCoverRatio + kTileTextHeight,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(width: Sp.md),
      itemBuilder: (_, i) => SizedBox(
        width: tileWidth,
        child: BookTile(books[i], onTap: () => onOpen(books[i])),
      ),
    ),
  );
}

/// Bordered panel used to group related controls.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.md),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}
