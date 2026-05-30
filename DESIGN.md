---
name: Sonique
description: A simple personal Flutter music app with restrained studio styling.
colors:
  studio-green: "#35D07F"
  studio-green-deep: "#159957"
  midnight-cyan: "#64D2FF"
  studio-dark-bg: "#101211"
  studio-dark-surface: "#191C1A"
  studio-light-bg: "#F7F8F5"
  studio-light-surface: "#FFFFFF"
  midnight-bg: "#090D16"
  midnight-surface: "#121827"
  ink-dark: "#151A17"
  ink-light: "#FFFFFF"
  ink-midnight: "#F3F7FF"
  error: "#FF0000"
  success: "#00FF00"
  warning: "#FFA500"
  info: "#00FFFF"
typography:
  display:
    fontFamily: "system-ui, Roboto, San Francisco, sans-serif"
    fontSize: "32px"
    fontWeight: 700
  headline:
    fontFamily: "system-ui, Roboto, San Francisco, sans-serif"
    fontSize: "24px"
    fontWeight: 600
  title:
    fontFamily: "system-ui, Roboto, San Francisco, sans-serif"
    fontSize: "20px"
    fontWeight: 700
  body:
    fontFamily: "system-ui, Roboto, San Francisco, sans-serif"
    fontSize: "16px"
    fontWeight: 400
  label:
    fontFamily: "system-ui, Roboto, San Francisco, sans-serif"
    fontSize: "12px"
    fontWeight: 500
rounded:
  sm: "8px"
spacing:
  xs: "8px"
  sm: "10px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.studio-green}"
    textColor: "{colors.ink-light}"
    rounded: "{rounded.sm}"
    padding: "16px"
  card-surface:
    backgroundColor: "{colors.studio-dark-surface}"
    textColor: "{colors.ink-light}"
    rounded: "{rounded.sm}"
    padding: "12px"
  nav-bar:
    backgroundColor: "{colors.studio-dark-surface}"
    textColor: "{colors.ink-light}"
    rounded: "{rounded.sm}"
---

# Design System: Sonique

## 1. Overview

**Creative North Star: "Personal Studio Shelf"**

Sonique should feel like a compact music shelf that belongs to the user: familiar, direct, and focused on listening rather than promotion. The app can borrow standard music-app structure, but it must stay quieter than a commercial streaming clone. Screens should help users browse, play, save, and manage songs without ornamental complexity.

The visual system is a restrained Material 3 product UI. It uses flat tonal layering, 8px corners, system typography, and a small accent budget. Green marks primary action, selection, and current state; it is not a decorative wash across every surface.

It rejects the product anti-references from PRODUCT.md: an over-saturated green palette, full Spotify-copy styling, heavy animation, elaborate page transitions, and visual effects that reduce mobile performance.

**Key Characteristics:**
- Compact music-app familiarity with Flutter Material controls.
- Restrained accent color used for action and state only.
- Flat, tonal surfaces instead of decorative shadows.
- Mobile-first density with short labels and predictable affordances.
- Minimal motion focused on feedback, never page choreography.

## 2. Colors

The palette is a dark studio-neutral system with green as the main action accent, plus a lighter theme and a cyan midnight alternate.

### Primary
- **Studio Green**: Main accent for selected navigation, primary buttons, upload actions, section icons, focus borders, and positive music states. Use it sparingly.
- **Deep Studio Green**: Light-theme primary accent where the brighter green would feel too loud.

### Secondary
- **Midnight Cyan**: Alternate accent for the Midnight theme. It belongs to that theme only and should not mix with Studio Green on the same surface without a specific state reason.

### Neutral
- **Studio Dark Background**: Default dark scaffold surface.
- **Studio Dark Surface**: Cards, bottom navigation, theme option tiles, song rows, and other contained controls.
- **Studio Light Background**: Light theme scaffold surface.
- **Studio Light Surface**: Light theme cards and controls.
- **Midnight Background**: Deep contrast scaffold for the Midnight theme.
- **Midnight Surface**: Midnight cards and panels.
- **Ink Dark, Ink Light, Ink Midnight**: Foreground text colors for their matching themes.

### Named Rules
**The Accent Budget Rule.** Studio Green should stay under 10 percent of any normal app screen. If the screen reads green before it reads music, it is too much.

**The Theme Separation Rule.** Studio Dark, Studio Light, and Midnight are separate theme families. Do not blend their accent colors casually.

## 3. Typography

**Display Font:** System Flutter font stack with Roboto or San Francisco fallback
**Body Font:** System Flutter font stack with Roboto or San Francisco fallback
**Label/Mono Font:** Same system stack

**Character:** The type system is practical and familiar. It supports scanning song rows, album shelves, playlist actions, and settings without introducing a brand display face.

### Hierarchy
- **Display** (700, 32px): App name, login title, and top-level screen identity when space allows.
- **Headline** (600, 24px): Secondary page headings and high-emphasis screen titles.
- **Title** (700, 20px): Section headers such as Latest Albums, Artists, Songs, Theme, and Library groups.
- **Body** (400 to 500, 16px): Form text, row metadata, general copy, and snackbar messages.
- **Label** (400 to 700, 10px to 14px): Navigation labels, small metadata such as song counts, and compact secondary text.

### Named Rules
**The Product Type Rule.** Use one system sans family for UI labels, data, actions, and headings. Do not add display fonts to the app shell.

**The One-Line Metadata Rule.** Song titles, artist names, playlist counts, and subtitles should truncate cleanly with ellipsis instead of wrapping into cramped rows.

## 4. Elevation

Sonique is flat by default. Depth comes from tonal surfaces, clipped artwork, spacing, and selected-state color, not from large shadows. Current app components mostly use `elevation: 0`, `Material` surfaces, and 8px clipping. The login logo has a soft green glow; treat that as a local flourish, not the general card model.

### Shadow Vocabulary
- **Login Logo Glow** (`blurRadius: 24px; offset: 0 12px; green at 16% alpha`): Only for the login brand mark or a future equivalent identity moment.

### Named Rules
**The Flat Shelf Rule.** Cards and rows sit on tonal layers at rest. Do not add wide soft shadows to song cards, playlist tiles, navigation bars, or settings tiles.

## 5. Components

### Buttons
- **Shape:** Gently squared Material controls (8px radius).
- **Primary:** Studio Green background, white text, 16px vertical padding, zero elevation.
- **Hover / Focus:** Keep state treatment native to Material. Focus uses the theme primary color, especially on fields and selected controls.
- **Secondary / Ghost / Tertiary:** Use `TextButton`, icon buttons, and bottom-sheet actions for secondary commands.

### Cards / Containers
- **Corner Style:** 8px radius across song rows, playlist tiles, album art clips, theme options, and icon containers.
- **Background:** Theme `cardColor` or `colorScheme.surface`.
- **Shadow Strategy:** Flat by default; use tonal separation and spacing.
- **Border:** Rare. Theme swatches use a divider border. Avoid border plus soft shadow decoration.
- **Internal Padding:** Compact mobile padding from 10px to 14px for rows, 20px to 24px for page edges.

### Inputs / Fields
- **Style:** Custom form fields use Material input behavior with label, hint, prefix icon, and optional suffix icon.
- **Focus:** Focused underline shifts to the active theme accent at 2px.
- **Error / Disabled:** Use Material validation states and plain error messages. Error red should be functional, not decorative.

### Navigation
- **Style:** Bottom `NavigationBar` with three primary destinations: Home, Library, Profile.
- **Active State:** Selected icon becomes filled, label weight increases to 700, and the indicator uses the theme accent at low alpha.
- **Mobile Treatment:** Keep bottom navigation persistent. The MiniPlayer stacks above it when a song is active.

### Song Row
Song rows are the core repeated component. They use 66px clipped artwork, a bold title, a muted one-line artist name, and an optional overflow menu. The entire row is tappable for playback.

### MiniPlayer
The MiniPlayer is a compact playback control above bottom navigation. It should use theme-aware surface and accent tokens when polished; avoid fixed gray or black overrides unless they match the active theme.

## 6. Do's and Don'ts

### Do:
- **Do** keep green restrained and tied to primary actions, selected state, focus, and current music feedback.
- **Do** preserve the 8px radius system for app controls and repeated rows.
- **Do** use flat tonal layers for cards, shelves, bottom navigation, and settings tiles.
- **Do** keep motion minimal and performance-safe, with transitions only for state feedback.
- **Do** keep the app recognizable as a simple music product with Home, Library, Profile, playlist, and playback patterns.

### Don't:
- **Don't** create an over-saturated green palette or a screen that feels like a full Spotify clone with fewer features.
- **Don't** add heavy animation, elaborate page transitions, decorative motion, or visual effects that could reduce performance on mobile devices.
- **Don't** add complex premium-streaming patterns that the product does not actually support.
- **Don't** pair a 1px border with a soft wide shadow on the same card or button.
- **Don't** use large rounded cards, glass panels, gradient text, or decorative stripe backgrounds.
