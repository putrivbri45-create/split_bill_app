---
name: Patungan Modern Split-Bill
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#6df5e1'
  on-secondary-container: '#006f64'
  tertiary: '#005ac2'
  on-tertiary: '#ffffff'
  tertiary-container: '#71a1ff'
  on-tertiary-container: '#00367a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#71f8e4'
  secondary-fixed-dim: '#4fdbc8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#d8e2ff'
  tertiary-fixed-dim: '#adc6ff'
  on-tertiary-fixed: '#001a42'
  on-tertiary-fixed-variant: '#004395'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
  amount-display:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  amount-inline:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '700'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style
The design system establishes a clean, modern, tactilely reassuring, and socially comfortable financial interface tailored for group expense sharing and split-bill workflows. The emotional tone is fair, frictionless, and transparent—eliminating the social awkwardness of debt tracking through welcoming visual ergonomics and unambiguous clarity.

Rooted in modern financial mobile application paradigms, the visual style balances warm consumer approachability with crisp utility. Generous whitespace, softly rounded contours, micro-textured translucent overlays, and deliberate typographic rhythm prevent cognitive fatigue during complex multi-way calculations and settle-up flows.

## Colors
The color architecture reflects financial balance, equity, and trust:

- **Primary (`#10B981`)**: Emerald Green symbolizes financial health, positive balances, successful settlements, and primary calls-to-action.
- **Secondary (`#14B8A6`)**: Fresh Teal acts as a collaborative secondary tone for group active states, split chips, and verified receipts.
- **Tertiary (`#3B82F6`)**: Bright Blue supports informational highlights, transfer confirmations, and deep links to bank/e-wallet integrations (QRIS, GoPay, OVO, BCA).
- **Accents**:
  - **Warning / Pending (`#F59E0B`)**: Amber for pending settlements, reminders, and unassigned bill line items.
  - **Danger / Owes (`#F43F5E`)**: Rose for outstanding balances owed, deletion prompts, and overdue notices.
- **Neutrals & Canvas**:
  - Background base is `#F8FAFC` (Slate 50), providing soft daylight contrast without sterile glare.
  - Elevated surfaces use pristine `#FFFFFF`.
  - Primary text runs on `#0F172A` (Slate 900) for strict readability, while supporting copy rests on `#64748B` (Slate 500). Subtle outlines use `#E2E8F0` (Slate 200).

## Typography
Plus Jakarta Sans is utilized across all typographic scales to deliver a friendly, human, yet tightly engineered fintech experience.

- **Currency Numerals**: Indonesian Rupiah displays (e.g., `Rp 148.500`) prioritize tabular numbers (`font-variant-numeric: tabular-nums`) to ensure vertical column alignment across itemized bills.
- **Scale Hierarchy**: Heavy display sizes are reserved for aggregated summaries (Total Tagihan, Bagian Kamu). Line items, payer attribution, and secondary metadata use clean, well-spaced medium and regular weights to maintain high legibility under dense information loads.

## Layout & Spacing
A fluid 4-column layout is implemented for mobile viewports, transitioning to 8 columns on tablet devices.

- **Mobile First Canvas**: Screen edge padding is fixed at `1rem` (16px) for compact thumb reach, scaling to `1.5rem` (24px) on tablet viewports.
- **Rhythm**: All vertical gaps strictly adhere to a 4px/8px incremental grid. Bill breakdown lists utilize `space-sm` (8px) internal row gaps, while card blocks and modular summary sections separate by `space-md` (16px) to `space-lg` (20px).
- **Safe Tap Ergonomics**: All interactive tap areas (avatar selection, quantity steppers, checkbox targets, settle triggers) adhere to a minimum physical bounding box of `48px x 48px` regardless of visual shape dimensions.

## Elevation & Depth
Depth is communicated through luminous surface separation and soft, diffused ambient shadows rather than harsh borders or dark elevation steps:

- **Level 0 (Canvas Base)**: Flat `#F8FAFC`.
- **Level 1 (Card & Content Containers)**: Solid `#FFFFFF` elevated with ambient shadow `0 2px 8px -2px rgba(15, 23, 42, 0.04), 0 8px 16px -4px rgba(15, 23, 42, 0.03)` and a hairline outer rim `1px solid #F1F5F9`.
- **Level 2 (Interactive Floating Elements, Floating Modals & Sticky CTA bars)**: Solid `#FFFFFF` layered over `0 12px 24px -6px rgba(16, 185, 129, 0.08), 0 4px 12px -2px rgba(15, 23, 42, 0.05)`.
- **Level 3 (Popovers & Bottom Sheets)**: Soft backdrop blur (`backdrop-filter: blur(8px)`) over `rgba(15, 23, 42, 0.4)` with sheet surface shadow `0 -8px 24px rgba(15, 23, 42, 0.08)`.

## Shapes
Roundedness level 2 governs the component system:

- **Cards & Containers**: Standard cards, receipt modules, and summary banners use `rounded-lg` (1rem / 16px) to `rounded-xl` (1.25rem / 20px).
- **Controls & Form Elements**: Input wrappers, dropdowns, and button containers use `rounded` (0.5rem / 8px) or `rounded-lg` (0.75rem / 12px).
- **Chips, Badges & Avatars**: Segment tags, split method toggles, and status badges utilize complete pill radii (`9999px`).
- **Dividers & Cutouts**: Digital receipt representations make deliberate use of subtle scalloped edges or dashed hairline patterns to evoke physical bill transparency.

## Components

### Buttons
- **Primary**: Solid `#10B981` background, white text, 48px minimum height, 12px border radius. Subtle emerald glow shadow on active press (`0 4px 12px rgba(16, 185, 129, 0.3)`).
- **Secondary / Subdued**: Pale emerald tint (`rgba(16, 185, 129, 0.1)`), `#0F766E` label, zero border.
- **Ghost / Tertiary**: Transparent base, `#64748B` text, highlighting to `#F1F5F9` on touch.

### Cards
- **Transaction & Split Card**: `#FFFFFF` background, 16px–20px corner radius, 16px internal padding. Left-hand dynamic status indicator strip (Green = You are owed / Red = You owe / Grey = Settled).
- **Hero Balance Card**: Gradient surface from `#10B981` to `#059669` with 20px corner radius, containing inverted white text, large tabular balances, and instant action pills.

### Chips & Split Toggles
- **Filter & Method Chips**: Pill shape, 36px height. Inactive state: `#FFFFFF` border `1px solid #E2E8F0`, text `#64748B`. Active state: `#10B981` surface with white text, or pale tint `#ECFDF5` with `#065F46` text and border `#A7F3D0`.

### Form Fields & Amount Inputs
- **Currency Input**: Large font size (24px–28px) with static prefix (`Rp`), bold zero-padded placeholder text (`0`), and active outline glowing `#10B981`. Min-height 56px for thumb usability.
- **Standard Input**: 48px height, 12px corner radius, light grey border `#CBD5E1`, focusing to 1.5px solid `#10B981`.

### Checkboxes, Radio Buttons & Avatar Selectors
- **Multi-user Bill Allocation Selector**: Circular avatar chips with checkmark badges overlaying top-right. Selected states trigger an active `#10B981` ring border (2px) and slight inward scale.
- **Standard Control**: Rounded checkbox (4px radius) and smooth circular radio button with emerald fill when toggled.

### Lists & Receipt Breakdown Items
- **Line Item Row**: Flex arrangement featuring item title, participant avatar cluster (overlapping -8px avatars), and aligned right-hand price formatting (`Rp XX.XXX`).
- **Separator**: 1px dashed `#E2E8F0` for line item listings, solid `#F1F5F9` for section groups.

### Specialized Component: Settle-up Bottom Sheet
- Persistent bottom docking modal featuring direct transfer copy buttons (BCA, Mandiri, GoPay, QRIS) with single-tap clipboard copy feedback and settlement confirmation triggers.