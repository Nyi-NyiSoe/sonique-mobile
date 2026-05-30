---
target: home page
total_score: 18
p0_count: 0
p1_count: 3
timestamp: 2026-05-30T13-53-48Z
slug: lib-representation-screens-home-page-dart
---
# Impeccable Critique: Home Page

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Loading is visible, but mostly as generic centered spinners; async action progress is not local to the affected shelf or row. |
| 2 | Match System / Real World | 3 | Albums, artists, songs, play, like, queue, and playlist are familiar music concepts. |
| 3 | User Control and Freedom | 2 | Main flows have back/navigation paths, but nested song action sheets add friction and there is no undo for queue/like/playlist actions. |
| 4 | Consistency and Standards | 2 | Song rows use `Material` and `InkWell`; album and artist cards use raw `GestureDetector`, hard-coded green, and radius drift. |
| 5 | Error Prevention | 1 | Null assertions on album data can crash, action errors are generic, and empty playlist/album states do not prevent dead-end flows. |
| 6 | Recognition Rather Than Recall | 2 | Categories are visible, but albums are cover-only and important song actions are hidden behind `More`. |
| 7 | Flexibility and Efficiency | 1 | No fast lane such as recent playback, search shortcut, filters, or efficient playlist action path. |
| 8 | Aesthetic and Minimalist Design | 3 | The page is compact, flat, and restrained; repeated green icons and low-information shelves keep it generic. |
| 9 | Error Recovery | 1 | Error states show raw or generic messages with no retry path or next action. |
| 10 | Help and Documentation | 1 | Empty states and first-run states do not teach the user what to do next. |
| **Total** | | **18/40** | **Poor-to-Acceptable boundary** |

## Anti-Patterns Verdict

**LLM assessment**: The home page does not look like obvious AI slop in the decorative sense. It avoids gradient text, glass panels, giant rounded cards, wide decorative shadows, and heavy animation. The issue is defaultness: logo row, horizontal albums, horizontal artists, vertical songs, repeated green section icons, cover-only albums, centered spinners, and thin empty states. It currently reads as a catalog index more than the `Personal Studio Shelf` described in `DESIGN.md`.

**Deterministic scan**: `detect.mjs` returned `[]` for `lib/Representation/screens/home_page.dart`. Counts: 0 findings. Rules triggered: none. File locations: none. False positives: none.

**Visual overlays**: No reliable user-visible overlay is available. Browser automation is unavailable in this session, so the critique uses CLI detector output plus source inspection.

## Overall Impression

The home page is functional and familiar, but it does not yet express a strong product point of view. Its biggest opportunity is to stop acting like a database catalog and start acting like a listening home: give the user a clear next action, then support browsing below it.

## What's Working

1. The basic information architecture is familiar. A music listener will understand Albums, Artists, and Songs immediately.
2. The song row is the strongest component: flat surface, 8px radius, clipped artwork, one-line title/artist metadata, and tappable row behavior.
3. The palette is mostly restrained. Green is visible, but the screen does not become a saturated Spotify-green clone.

## Priority Issues

**[P1] The home page is a catalog, not a listening home**

**Why it matters**: Sonique exists for playback and personal music use, but the first screen asks users to choose a category before it creates momentum. There is no `Continue listening`, `Recently played`, liked music shortcut, or clear primary path.

**Fix**: Add one primary top module: `Continue listening`, `Recently played`, or `Start with songs`. Keep Albums, Artists, and Songs below it. If there is no history, show a first-run prompt that routes to Songs or Library.

**Suggested command**: `$impeccable shape home listening module`

**[P1] Album and artist cards have weak affordance and accessibility**

**Why it matters**: `CustomAlbumCard` uses `GestureDetector` around cover art only. There is no ripple, no title, no semantic label visible in source, and users must infer what tapping a cover does. Artist cards use a similar raw `GestureDetector` pattern in `home_page.dart`.

**Fix**: Convert album and artist items to `Material` + `InkWell`, add semantic labels, show album title/artist where data exists, and keep card corners aligned to the 8px design system unless circular artist imagery is the intended pattern.

**Suggested command**: `$impeccable audit home cards`

**[P1] Loading, error, and empty states are too generic**

**Why it matters**: Spinners make slow shelves feel unfinished. Empty messages like `No albums yet` and `No songs available` give no next step. Raw backend errors can leak into the UI and do not help the user recover.

**Fix**: Use skeleton shelves or fixed-size placeholders for loading. Give error states retry actions. Rewrite empty states with next steps, such as `No albums yet. Browse songs while artists upload releases.`

**Suggested command**: `$impeccable harden home states`

**[P2] Component vocabulary drifts from the design system**

**Why it matters**: `DESIGN.md` defines 8px radius, theme-aware tonal surfaces, and green as action/state. The home page and related components use hard-coded `Colors.green`, hard-coded grey placeholders, 12px album radius, and red liked color outside the documented token strategy.

**Fix**: Pull accent and semantic colors from `theme.colorScheme`, standardize album/card radius to 8px, and define liked/error semantics centrally.

**Suggested command**: `$impeccable polish home page`

**[P2] Song action flow is modal-heavy**

**Why it matters**: The overflow sheet opens another bottom sheet for playlist selection. That stack creates extra cognitive load for a common action and makes cancel/recovery behavior less clear.

**Fix**: Use one action sheet with an expandable playlist section, or make `Add to Playlist` open one dedicated picker with Cancel, loading, empty, and success states.

**Suggested command**: `$impeccable distill song actions`

## Persona Red Flags

**Alex (Power User)**: Alex wants to start listening fast. The home page has no recent playback shortcut, no search shortcut, no filtering, no bulk actions, and playlist actions require nested sheets.

**Jordan (First-Timer)**: Jordan understands the section names, but album covers are unlabeled and empty states do not explain what to do next. `More` hides important actions with no preview.

**Sam (Accessibility-Dependent User)**: Raw `GestureDetector` on album/artist items is weaker than the `InkWell` song rows. Cover-only album cards likely have poor screen-reader meaning unless semantics are added elsewhere. Liked state relies on icon/color feedback without broader state messaging.

**Casey (Distracted Mobile User)**: Casey can tap song rows comfortably, but top shelves require horizontal swiping plus vertical scrolling. Slow image loads show many small spinners, and nested playlist sheets are fragile when interrupted.

## Minor Observations

- The header copy `Fresh albums, artists, and songs` is accurate but emotionally flat.
- Section icons repeat green as decoration; green should mostly mean action, current state, or selection.
- `album.coverImageUrl!` and `album.id!` can turn missing data into a crash instead of an error state.
- `Customsongcard` class casing is inconsistent with Dart conventions and surrounding component names.
- Error/empty states are visually polite but not useful enough.

## Questions to Consider

- What is the one thing Sonique wants the listener to do within five seconds: resume, discover, search, or manage?
- If the app is `personal`, why does the home page lead with global catalog shelves instead of user-specific music?
- Should albums be browsable objects with names, or just decorative covers?
- Which action deserves to be one tap from every song row: like, queue, playlist, or play only?
