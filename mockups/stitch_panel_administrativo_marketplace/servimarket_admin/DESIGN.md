---
name: ServiMarket Admin
colors:
  surface: '#f5fbf5'
  surface-dim: '#d5dcd6'
  surface-bright: '#f5fbf5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff5ef'
  surface-container: '#e9efe9'
  surface-container-high: '#e4eae4'
  surface-container-highest: '#dee4de'
  on-surface: '#171d19'
  on-surface-variant: '#3d4a42'
  inverse-surface: '#2c322e'
  inverse-on-surface: '#ecf2ec'
  outline: '#6d7a72'
  outline-variant: '#bccac0'
  surface-tint: '#006c4a'
  primary: '#006948'
  on-primary: '#ffffff'
  primary-container: '#00855d'
  on-primary-container: '#f5fff7'
  inverse-primary: '#68dba9'
  secondary: '#5d5e61'
  on-secondary: '#ffffff'
  secondary-container: '#e2e2e5'
  on-secondary-container: '#636467'
  tertiary: '#9b3e3b'
  on-tertiary: '#ffffff'
  tertiary-container: '#ba5551'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#85f8c4'
  primary-fixed-dim: '#68dba9'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#005137'
  secondary-fixed: '#e2e2e5'
  secondary-fixed-dim: '#c6c6c9'
  on-secondary-fixed: '#1a1c1e'
  on-secondary-fixed-variant: '#454749'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ae'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#7f2928'
  background: '#f5fbf5'
  on-background: '#171d19'
  surface-variant: '#dee4de'
typography:
  display:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  h1:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.01em
  h2:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  h3:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  sidebar-width: 260px
  gutter: 24px
  container-padding: 32px
  card-gap: 24px
---

## Brand & Style

The design system is engineered for a high-scale administrative environment where clarity, efficiency, and speed of decision-making are paramount. The brand personality is **reliable, professional, and sophisticated**, leaning into a **Corporate Modern** aesthetic that balances minimalist functionalism with tactile, realistic depth.

The UI aims to evoke a sense of "calm control." By utilizing generous whitespace and a restricted, purposeful color palette, the system reduces cognitive load for administrators managing complex marketplace data. All interface copy follows a professional Spanish tone—direct, respectful, and instruction-oriented.

## Colors

The palette is anchored by a vibrant **Modern Green** primary color, symbolizing growth and operational health. This is contrasted against a deep **Sidebar Gray** (#1A1C1E) which provides a strong structural frame for navigation, ensuring the primary content area remains the focus.

- **Primary:** Used for main actions, active states, and success indicators.
- **Surface:** The background utilizes a very cool-toned light gray (#F5F7FA) to differentiate the canvas from the white card components.
- **Semantic:** Information and Alerts use "soft" variations of blue and red—sufficiently saturated for visibility but avoiding harshness to maintain the professional atmosphere.

## Typography

This design system uses **Inter** exclusively to achieve a systematic, utilitarian feel. The typeface’s high x-height and excellent legibility make it ideal for data-heavy administrative dashboards.

The hierarchy is structured to favor quick scanning. Headlines (H1-H3) use tighter letter spacing and heavier weights to anchor sections, while body text maintains a generous line height for readability. Special attention is given to `label-sm`, which uses uppercase and increased tracking for metadata and table headers, providing clear distinction from user-generated data.

## Layout & Spacing

The layout follows a **Fixed-Fluid model**. A fixed-width sidebar (260px) provides consistent navigation on the left, while the main content area expands to fill the remaining viewport width.

- **Grid:** A standard 12-column grid is used within the main content area for dashboard widgets and data tables.
- **Rhythm:** Spacing is strictly based on an 8px scale.
- **Margins:** Large views utilize a 32px padding from the window edge to provide visual breathing room, emphasizing the minimalist "Clean" aesthetic.

## Elevation & Depth

This design system utilizes **Ambient Shadows** to create a realistic sense of layering. The depth model is shallow but distinct:

- **Level 0 (Base):** The #F5F7FA background.
- **Level 1 (Cards):** Pure white surfaces with a soft, multi-layered shadow (0px 4px 20px rgba(0, 0, 0, 0.05)). This is the primary container for all data.
- **Level 2 (Dropdowns/Modals):** Elements that float above the UI use a more pronounced shadow (0px 10px 32px rgba(0, 0, 0, 0.12)) and a subtle 1px border (#E2E8F0) to ensure separation from Level 1 cards.
- **Sidebar:** Uses zero shadow, relying on color contrast (#1A1C1E) to define its presence.

## Shapes

The shape language is **Rounded**, using a 0.5rem (8px) base radius. This softens the "industrial" feel of enterprise software, making the marketplace management experience more approachable.

- **Standard Elements:** Inputs, buttons, and cards use the 8px radius.
- **Large Elements:** Modals and large feature banners scale up to 1rem (16px).
- **Interactive States:** Focus rings should follow the radius of the element they surround with a 2px offset.

## Components

### Buttons
- **Primary:** Solid green with white text. 1px inset top-border for a subtle tactile feel.
- **Secondary:** White background, 1px border (#E2E8F0), dark text.
- **States:** Hover states should be 10% darker; Active states 20% darker.

### Input Fields
- **Styling:** Soft gray background (#F9FAFB) when idle, turning white on focus.
- **Borders:** 1px solid #E2E8F0, changing to Primary Green on focus.
- **Labels:** Positioned above the input in `label-md` style.

### Data Tables
- **Header:** `label-sm` with a light gray background (#F9FAFB) and a subtle bottom stroke.
- **Rows:** 1px light gray bottom border. No vertical borders between columns to maintain the "clean" aesthetic.
- **Density:** 16px vertical padding per row for "Comfortable" density.

### Chips & Tags
- **Status:** Use a soft background (10% opacity of the color) with high-contrast text of the same hue (e.g., Soft Red background with Dark Red text for "Error").

### Cards
- **Structure:** Always include a 16px-24px internal padding. Headers within cards should have a subtle 1px bottom border to separate titles from the content body.