# VS Code Workspace Configuration

This directory contains workspace-specific configuration files for Visual Studio Code, designed to provide a consistent development environment across the team.

## Files Overview

### 1. `launch.json`
Contains debug and run configurations for the project. 

**Flutter Configurations:**
- **Dev (Debug/Profile)**: Runs the mobile app with the development environment (`env/dev.json`).
- **Staging (Debug)**: Runs the mobile app with the staging environment (`env/staging.json`).
- **Prod (Debug/Release)**: Runs the mobile app with the production environment (`env/prod.json`).

### 2. `settings.json`
Workspace-specific settings to enforce consistency:
- Pins the local Flutter SDK to the version managed by FVM (`.fvm/versions/...`).
- Configures Code Spell Checker (`cSpell`) to include both English and Vietnamese (`vi`) languages.
- Provides a whitelist of project-specific words to avoid false positive spelling errors.

### 3. `extensions.json`
A list of recommended extensions for this workspace. When opening this project in VS Code for the first time, you'll be prompted to install these extensions to ensure full feature support (such as Vietnamese spell-checking dictionaries).

---

## Usage Tips

- Always use the **Run and Debug** view (`Cmd+Shift+D` on Mac) to select your target environment. 
- For full Flutter support, ensure you have the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) installed.
