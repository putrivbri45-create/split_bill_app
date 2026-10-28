# Design System & UI/UX Specifications
## Application: Patungan - Split Bill App

---

### 1. Brand Identity & Aesthetic Philosophy
The design language of **Patungan** embodies trust, effortless clarity, and modern financial empowerment. Guided by the tagline **"Biar adil, nggak ribet."**, the interface avoids the cold rigidity of traditional banking apps, opting instead for a friendly, high-contrast, emerald-accented modern visual hierarchy.

---

### 2. Design Tokens & Color Palette

#### Primary Palette (Emerald Financial Theme)
- **Primary**: `#006C49` (Deep Forest Emerald - Key actions, primary text accents)
- **Primary Container**: `#10B981` (Vibrant Emerald - CTA buttons, active status badges)
- **Primary Fixed**: `#6FFBBE` (Soft Mint Glow)
- **Primary Fixed Dim**: `#4EDEA3` (Mid Mint)
- **On Primary**: `#FFFFFF` (Crisp White on Emerald)
- **On Primary Container**: `#00422B` (Deep Emerald Shadow on container)

#### Secondary Palette (Teal & Cyan Support)
- **Secondary**: `#006B5F` (Dark Teal)
- **Secondary Container**: `#6DF5E1` (Fresh Aquamarine / Cyan Accent)
- **On Secondary**: `#FFFFFF`
- **On Secondary Container**: `#006F64`

#### Tertiary Palette (Accent Indigo / Royal Blue)
- **Tertiary**: `#005AC2` (Deep Indigo)
- **Tertiary Container**: `#71A1FF` (Gentle Sky Indigo)
- **On Tertiary**: `#FFFFFF`

#### Surface & Background Tones (Light Theme Spec)
- **Background**: `#FAF8FF` (Ultra-light airy lilac-white)
- **Surface**: `#FAF8FF`
- **Surface Container Lowest**: `#FFFFFF` (Pure white cards & sheets)
- **Surface Container Low**: `#F2F3FF` (Soft background chips & input fills)
- **Surface Container**: `#EAEDFF` (Borders, card dividers, neutral fills)
- **Surface Container High**: `#E2E7FF` (Hover states)
- **Surface Container Highest**: `#DAE2FD` (Selected neutral items)
- **On Surface**: `#131B2E` (Deep navy-slate for high legibility)
- **On Surface Variant**: `#3C4A42` (Slate grey for descriptions & metadata)
- **Outline**: `#6C7A71` (Form field borders & subtle icons)
- **Outline Variant**: `#BBCABF` (Muted line separators)

#### Semantic Status Colors
- **Error (Must Pay / Expense)**: `#BA1A1A`
- **Error Container**: `#FFDAD6` (Soft Rose Red - Badge background)
- **On Error Container**: `#93000A` (Dark Wine text)
- **Warning / Pending**: `#F59E0B` (Amber)
- **Success / Settled**: `#10B981` (Emerald Green)

---

### 3. Typography Scale (Plus Jakarta Sans)

| Token Name | Font Size | Line Height | Weight | Letter Spacing | Usage |
|---|---|---|---|---|---|
| `headline-xl` | 36px | 44px | Bold (700) | -0.02em | Hero values & Display titles |
| `headline-xl-mobile` | 30px | 38px | Bold (700) | -0.02em | Mobile hero totals |
| `headline-lg` | 26px | 34px | Bold (700) | -0.015em | Screen headings |
| `headline-md` | 20px | 28px | SemiBold (600) | -0.01em | Card section titles |
| `headline-sm` | 18px | 24px | SemiBold (600) | Normal | Group & modal titles |
| `amount-display` | 28px | 36px | ExtraBold (800) | -0.02em | Currency figures |
| `amount-inline` | 15px | 20px | Bold (700) | Normal | In-list price tags |
| `body-lg` | 16px | 24px | Regular (400) | Normal | Form inputs, narrative |
| `body-md` | 14px | 20px | Regular (400) | Normal | Standard body copy |
| `body-sm` | 12px | 16px | Regular (400) | Normal | Timestamps, subtitles |
| `label-lg` | 14px | 20px | SemiBold (600) | +0.01em | Button labels |
| `label-md` | 12px | 16px | SemiBold (600) | +0.02em | Status chips & pills |
| `label-sm` | 11px | 14px | SemiBold (600) | +0.03em | Micro-badges & counters |

---

### 4. Elevation & Visual Depth
- **Card Shadow**: `box-shadow: 0 2px 8px -2px rgba(15, 23, 42, 0.04), 0 8px 16px -4px rgba(15, 23, 42, 0.03);`
- **Badge Shadow**: `box-shadow: 0 12px 24px -6px rgba(16, 185, 129, 0.12), 0 4px 12px -2px rgba(15, 23, 42, 0.06);`
- **Button Glow**: `box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);`
- **Border Radius**:
  - Small Pills / Badges: `9999px` (Full)
  - Cards: `16px` to `20px` (`rounded-2xl`)
  - Inputs & Buttons: `12px` to `16px` (`rounded-xl` / `rounded-2xl`)

---

### 5. Micro-Interactions & Transitions
- **Button Press**: `scale(0.97)` on tap with 150ms ease-out spring.
- **Tab Switching**: Smooth animated slide transition with indicator bar.
- **Card Hover / Tap**: Elevation rise with border color illumination.
- **Number Counter**: Animated ticker for balance updates.
