# Changelog

All notable changes to NutriCode will be documented in this file.

---

## [Sprint 2] - 2026-04-25 to 2026-04-28

### Added
- **Allergen Filter (T2#5)** — Users can configure personal allergens from a searchable list of 14 common allergens (Profile → My Allergens). The verdict screen shows a red alert banner when a scanned product contains a matched allergen, and a yellow warning when allergen data is unavailable.
- **Ingredient Details (T2#4)** — Expanded product view showing each ingredient classified as Good / Moderate / Avoid with colour-coded indicators and detailed info sheets. Ingredients matching user-configured allergens are flagged with a warning badge regardless of their health classification.
- **Search by Name (T2#7)** — Users can search for products by name directly from the Search tab without needing to scan a barcode.

### Changed
- Profile screen updated with a live "My Allergens" card showing the number of configured allergens and navigating to the allergen configuration screen.
- Verdict screen updated to show allergen alert banners alongside the existing traffic light verdict.

---

## [Sprint 1] - 2026-04-05 to 2026-04-21

### Added
- **Scan a Product (T2#1)** — Barcode scanning via device camera with manual barcode entry fallback.
- **View Harmful Ingredients (T2#2)** — After scanning, ingredients are fetched from the Open Food Facts API and classified using an ingredient classifier.
- **Traffic Light Verdict (T2#3)** — Scanned products receive a green / orange / red verdict based on the worst-case ingredient classification.

---

## [0.1.0] - Iteration 0 - 2026-03-24

### Added
- Initial Flutter project setup.
- Vertical prototype with core navigation structure (Scan, Search, Profile tabs).
- README with architecture, UML class diagram, and user stories.
