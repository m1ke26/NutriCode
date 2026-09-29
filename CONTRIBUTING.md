# Contributing to Nutricode 🥗

Thank you for your interest in Nutricode! We’re excited to have you help us make barcode scanning and product evaluation better for everyone using Open Food Facts.

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started (Flutter Setup)](#getting-started-flutter-setup)
3. [Project Architecture](#project-architecture)
4. [How to Contribute](#how-to-contribute)
5. [Style Guide](#style-guide)
6. [Testing & QA](#testing--qa)

---

## Code of Conduct
By participating, you agree to uphold our [Code of Conduct](CODE_OF_CONDUCT.md). Please be kind and constructive.

## Getting Started (Flutter Setup)

To set up the Nutricode development environment:

1.  **Install Flutter:** We are currently using **Flutter 3.x**. Run `flutter doctor` to ensure your environment is ready.
2.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/LEIC-ES-2025-26-2LEIC01/T2.git](https://github.com/LEIC-ES-2025-26-2LEIC01/T2.git)
    cd T2
    cd nutricode
    ```
3.  **Fetch Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Platform Specifics:**
    * **Android:** Ensure you have the latest Android SDK. Camera permissions are handled via the `AndroidManifest.xml`.
    * **iOS:** Run `cd ios && pod install && cd ..`. Ensure `Info.plist` contains the necessary `NSCameraUsageDescription`.
5.  **Run the App:** * `flutter run`
    * **Note:** A physical device is strongly recommended to test the **Google Mobile Scanner** functionality.

---

## Project Architecture

* **Scanner:** Powered by `google_mobile_scanner`.
* **Data Source:** We use the [Open Food Facts API](https://world.openfoodfacts.org/data) to fetch product nutritional information.
* **State Management:** Provider.

---

## How to Contribute

### Reporting Bugs
* Ensure the bug is reproducible on the latest version.
* Include your **Device Model** and **OS version**.
* **API Issues:** If a specific product returns wrong data, please check if the data is correct on the [Open Food Facts website](https://world.openfoodfacts.org/) first.

### Submitting a Pull Request (PR)
1.  **Branching:** Create a feature branch: `git checkout -b feature/amazing-feature`.
2.  **Commits:** Use [Conventional Commits](https://www.conventionalcommits.org/).
3.  **UI Changes:** If you modify the product evaluation screens, please include screenshots or a screen recording in your PR.

---

## Style Guide

### Dart & Flutter
* Follow the [Official Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
* Run `dart format .` before committing.
* Use `debugPrint()` instead of `print()`.

---

## Testing & QA

1.  **Scanner Testing:** If you modify scanning logic, you **must** test on a physical device. Emulators do not accurately simulate camera focus or the Google Mobile Scanner's performance.
2.  **API Mocking:** When writing unit tests for product evaluation, use mock data to avoid unnecessary hits to the Open Food Facts production servers.
3.  **Run Tests:** Execute `flutter test` to ensure no regressions.

---

## Contact
Maintainers:
| Name | ID | Email |
| :--- | :--- | :--- |
| **José Maio** | `up202404872` | [up202404872@up.pt](mailto:up202404872@up.pt) |
| **Miguel Mimoso** | `up202407610` | [up202407610@up.pt](mailto:up202407610@up.pt) |
| **Vasco Guimarães** | `up202403604` | [up202403604@up.pt](mailto:up202403604@up.pt) |
| **Victor Gomez** | `up202406138` | [up202406138@up.pt](mailto:up202406138@up.pt) |

Open Food Facts Community: [Link to Forum](https://forum.openfoodfacts.org/)