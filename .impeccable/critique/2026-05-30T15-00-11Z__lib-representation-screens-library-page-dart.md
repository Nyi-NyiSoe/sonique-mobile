---
target: library page
total_score: 17
p0_count: 0
p1_count: 3
timestamp: 2026-05-30T15-00-11Z
slug: lib-representation-screens-library-page-dart
---
# Impeccable Critique: Library Page

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Playlist loading/error states exist, but create playlist has no saving, success, or failure feedback in this surface. |
| 2 | Match System / Real World | 3 | `Library`, `Liked Songs`, and `Playlists` are familiar music concepts; `releases` in the subtitle is less clear for non-artist users. |
| 3 | User Control and Freedom | 2 | The create dialog has Cancel, but the plus SpeedDial hides actions and empty-title submit silently does nothing. |
| 4 | Consistency and Standards | 2 | The page uses Material tiles, but hard-coded colors and saturated gradients break the documented theme system. |
| 5 | Error Prevention | 1 | Empty playlist names are silently ignored, `playlist.id!` can crash on malformed data, and failed create/fetch paths have weak guardrails. |
| 6 | Recognition Rather Than Recall | 2 | Library tiles are visible, but create/upload actions are hidden behind a role-dependent plus FAB. |
| 7 | Flexibility and Efficiency | 1 | No search, sort, recent playlists, inline create affordance, or faster power path. |
| 8 | Aesthetic and Minimalist Design | 2 | The layout is clean, but decorative gradients and competing icon colors dilute the restrained studio system. |
| 9 | Error Recovery | 1 | Playlist errors display a message, but provide no retry or contextual fix. |
| 10 | Help and Documentation | 1 | Empty states describe absence but do not teach the next action. |
| **Total** | | **17/40** | **Poor: core structure is present, but state, recovery, and system discipline need work.** |

## Anti-Patterns Verdict

**LLM assessment**: This is not classic decorative AI slop, but it does show product-UI defaultness: generic music tiles, saturated category gradients, hard-coded `Colors.green`, and a FAB SpeedDial that feels more like a mobile template than Sonique's `Personal Studio Shelf`. The page is functional and familiar, but it does not yet feel restrained, theme-aware, or personal.

**Deterministic scan**: `detect.mjs --json lib/Representation/screens/library_page.dart` returned `[]`. Counts: 0 findings. Rules triggered: none. File locations: none. False positives: none.

**Visual overlays**: No reliable user-visible overlay is available. Browser automation is unavailable in this session, so the critique uses CLI detector output plus source inspection.

## Overall Impression

The library page has the right backbone: liked songs, playlists, and conditional artist tools. The biggest problem is that it hides the page's most meaningful actions behind a floating plus button while making decorative category colors too loud. A better Library would feel like a saved-music shelf first, then reveal artist tools as a clearly separate management band.

## What's Working

1. The information architecture is basically right for Sonique's small Spotify-style scope: Liked Songs, Playlists, and Artist Tools.
2. `_LibraryTile` uses one-line truncation for title and subtitle, which matches the One-Line Metadata Rule in `DESIGN.md`.
3. The base tile surface uses `theme.cardColor` and 8px radius, so the underlying component shape is aligned with the documented design system.

## Priority Issues

**[P1] Theme discipline is broken by hard-coded accent colors**

**Why it matters**: Sonique supports Studio Dark, Studio Light, and Midnight, but Library uses hard-coded green, pink/red gradients, lightGreen/tealAccent gradients, and blueAccent. Midnight cannot own its cyan accent here, and the page violates the `Accent Budget Rule`.

**Fix**: Replace hard-coded color blocks with `theme.colorScheme.primary`, tonal containers, and neutral icon wells. Use one consistent icon background treatment per tile type instead of full-saturation gradients.

**Suggested command**: `$impeccable colorize library page`

**[P1] Primary actions are hidden and overloaded in the SpeedDial**

**Why it matters**: Creating a playlist is a core Library action, but it is hidden behind a generic plus FAB. For artists, the same FAB mixes listener work and artist upload work.

**Fix**: Add an inline `Create playlist` button or row in the Playlists section, especially in the empty state. Move artist upload actions into the Artist Tools section so listener and artist tasks are separated.

**Suggested command**: `$impeccable layout library page`

**[P1] Empty and error states do not help users recover**

**Why it matters**: `No playlists yet` and playlist errors identify the state but do not offer the next step. First-time users have to infer that the FAB is the recovery path.

**Fix**: Give empty playlists a direct `Create playlist` action. Give playlist errors a `Try again` action that dispatches the fetch event. For empty liked songs, point users toward Home or song browsing.

**Suggested command**: `$impeccable onboard library page`

**[P2] Create playlist has silent validation and weak operation feedback**

**Why it matters**: Pressing Create with an empty title silently does nothing. Successful submit closes immediately without visible confirmation; failed submit is not surfaced here.

**Fix**: Add inline validation, disable Create while the trimmed title is empty, show a loading state while creating when the bloc supports it, and show a success or failure snackbar.

**Suggested command**: `$impeccable harden create playlist`

**[P2] Listener and artist mental models are blurred**

**Why it matters**: The subtitle says `saved songs, playlists, and releases`, but non-artists do not see releases. Artists get upload actions and album management inside the same listener Library.

**Fix**: Change subtitle by role, or split Artist Tools into a distinct management band with upload track, upload album, and Your Albums colocated.

**Suggested command**: `$impeccable clarify library page`

## Persona Red Flags

**Jordan (First-Timer)**: Jordan sees `No playlists yet` but no visible create action in that section. The plus FAB may be guessed, but the page does not teach it. The subtitle mentions `releases`, which may not mean anything to a listener.

**Sam (Accessibility-Dependent User)**: State and category are partly color-dependent: liked songs, playlists, and albums are distinguished mainly by icon/color treatment. The SpeedDial labels help, but low-alpha secondary text and saturated icon wells may vary in contrast across themes.

**Casey (Distracted Mobile User)**: Core actions are split between top content, scrollable tiles, bottom navigation, mini-player, and FAB. With MiniPlayer active, the FAB/SpeedDial area risks becoming a crowded bottom-right interaction zone.

## Minor Observations

- Playlist loading uses an icon/text message rather than a skeleton, so the list jumps from state message to populated tiles.
- `playlist.id!` can crash if backend data is malformed.
- `AlbumByArtistBloc` count defaults to `0 albums` when not loaded, which can mislead artists.
- Hard-coded route strings like `/library/likedSong` sit beside `Routes.*`, making navigation vocabulary inconsistent.
- `_StateMessage` is reusable but too passive; it needs optional action slots.

## Questions to Consider

- Is Library primarily a listener shelf, or is it also the artist dashboard?
- Why is `Create playlist` less visible than `Liked Songs` when playlist creation is one of the few meaningful Library actions?
- What would this page look like if every tile used album-shelf restraint instead of category-color decoration?
- Should Artist Tools be a separate Profile or Studio surface instead of living inside the listener's Library?
