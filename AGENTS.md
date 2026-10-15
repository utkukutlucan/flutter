# AGENTS.md

Guidance for AI agents and developers working on this repository.

## Project overview

A Flutter **Tic Tac Toe** game (Turkish UI). Single-screen app rendered on
web (Chrome) and other Flutter targets. All application code lives in one file.

- **Framework:** Flutter 3.47.x / Dart SDK `^3.13.5`
- **Package name:** `my_first_app`
- **Entry point:** `lib/main.dart`
- **UI language:** Turkish (labels and game status messages)

## Commands

Run from the repository root. On Windows use PowerShell (no `&&`, no `head`/`tail`).

| Task            | Command                          |
| --------------- | -------------------------------- |
| Install deps    | `flutter pub get`                |
| Run (Chrome)    | `flutter run -d chrome`          |
| Run (Windows)   | `flutter run -d windows`         |
| Analyze / lint  | `flutter analyze`                |
| Tests           | `flutter test`                   |
| Build web       | `flutter build web`              |

Note: Android SDK and Visual Studio are not installed in this environment.
Chrome is the only verified working run target.

## Code layout

```
lib/main.dart        All app code: MyApp + GamePage (stateful game logic + UI)
web/index.html       Web host page (Flutter bootstrap)
test/widget_test.dart Stale default template test (see Known issues)
pubspec.yaml         Dependencies and Flutter config
analysis_options.yaml Lints; excludes build/, android/, web/, windows/
```

## Architecture (`lib/main.dart`)

- `MyApp` — `MaterialApp`, Material 3, indigo seed color, dark text on light gradient.
- `GamePage` / `_GamePageState` — owns all game state:
  - `board` — `List<String>` of 9 cells (`''`, `'X'`, `'O'`).
  - `player` — current turn, `'X'` starts every round.
  - `winner` — `null`, `'X'`, `'O'`, or `'Draw'`.
  - `winsX`, `winsO`, `draws` — cumulative score across rounds.
  - `moveHistory` — ordered list of tapped cell indices (for the history panel).
  - `winningCells` — indices of the winning line, used for highlight animation.
- Win detection uses the `winningLines` constant (8 lines) in `checkWinner()`.
- Animations: `_turnController` (pulsing turn badge), `_winController`,
  plus `AnimatedContainer` / `AnimatedScale` on cells.

### State mutation rules

- All state changes go through `setState`.
- `tap(i)` ignores taps on filled cells or after a game ends.
- `resetRound()` clears the board/history but keeps scores.
- `resetAll()` clears the board, history, and all scores.
- Adding new mutable state: initialize in the field declarations, reset it in
  both `resetRound()` and `resetAll()` as appropriate, and dispose any new
  `AnimationController` in `dispose()`.

## Conventions

- Single-file app; keep related UI + logic in `lib/main.dart` unless a refactor
  is explicitly requested.
- Follow existing style: `const` constructors, `withValues(alpha: ...)` for
  opacity (not the deprecated `withOpacity`), Material 3 buttons.
- **Do not add code comments** unless asked.
- Turkish user-facing strings; keep the same tone as existing labels.

## Known issues

- `test/widget_test.dart` is the unmodified Flutter counter template and will
  fail (`MyApp` has no counter / `Icons.add`). Update or rewrite it before
  relying on `flutter test`.

## Verification checklist

After changes, run `flutter analyze` and `flutter run -d chrome`. Confirm:
turn badge reflects the active player, winning line highlights, score and
move-history panels update correctly, and both reset buttons behave as
described above.
