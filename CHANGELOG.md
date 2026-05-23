# Changelog

All notable changes to NutriCode will be documented in this file.

---

## [Sprint 3] - 11/05/2026 to 25/05/2026

### Added
- **Save Favourite Products (T2#8)** — Users can now bookmark their favourite products, making them easily accessible in a dedicated favorites screen.
- **Scan History (T2#6)** — A new history log automatically saves previously scanned products, allowing users to quickly review products they have analyzed in the past.
- **App Settings and Help & Support (T2#28)** — Added a comprehensive settings menu along with a Help & Support section to assist users with app functionality and account management.

---

## [Sprint 2] - 20/04/2026 to 11/05/2026

### Added
- **Allergen Filter (T2#5)** — Users can configure personal allergens from a searchable list of 14 common allergens (Profile → My Allergens). The verdict screen shows a red alert banner when a scanned product contains a matched allergen, and a yellow warning when allergen data is unavailable.
- **Ingredient Details (T2#4)** — Expanded product view showing each ingredient classified as Good / Moderate / Avoid with colour-coded indicators and detailed info sheets. Ingredients matching user-configured allergens are flagged with a warning badge regardless of their health classification.
- **Search by Name (T2#7)** — Users can search for products by name directly from the Search tab without needing to scan a barcode.
- **User Authentication (T2#20)** — Implementation of a complete authentication system using Firebase Auth, supporting Email/Password login, registration, and Google Sign-In. Includes an AuthWrapper for automatic session management.
- **User Profile Management (T2#19)** — User data is now persisted in Firestore, allowing for cross-device synchronization of dietary preferences (allergens, vegan status) and profile details (name, profile picture).
- **Vegan Products (T2#26)** — Users can enable "Vegan Mode" in their profile. When enabled, products are analyzed for non-vegan ingredients, and a "VEGAN" or "NOT VEGAN" badge is displayed on the product screen.

### Changed
- Profile screen updated with a live "My Allergens" card showing the number of configured allergens and navigating to the allergen configuration screen.
- Verdict screen updated to show allergen alert banners and vegan status badges alongside the existing traffic light verdict.
- **Refactoring for Testability** — Transitioned from singleton-based service access to dependency injection using the `Provider` pattern. This resolves Firebase initialization issues in unit and integration tests, ensuring 100% test reliability.

---

## [Sprint 1] - 06/04/2026 to 20/04/2026

### Added
- **Scan a Product (T2#1)** — Barcode scanning via device camera with manual barcode entry fallback.
- **View Harmful Ingredients (T2#2)** — After scanning, ingredients are fetched from the Open Food Facts API and classified using an ingredient classifier.
- **Traffic Light Verdict (T2#3)** — Scanned products receive a green / orange / red verdict based on the worst-case ingredient classification.

---

## [Sprint 0] - 06/04/2026

### Added
- Initial Flutter project setup.
- Vertical prototype with core navigation structure (Scan, Search, Profile tabs).
- README with architecture, UML class diagram, and user stories.
