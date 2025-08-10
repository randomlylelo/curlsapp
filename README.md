# Curls App

A beautifully simple iOS workout tracking app designed with Steve Jobs' philosophy of simplicity in mind - making fitness tracking accessible for beginners while powerful enough for experienced athletes.

## Features

### 🏋️ Core Functionality
- **Exercise Database**: Browse 800+ exercises with detailed instructions and muscle group information
- **Workout Tracking**: Log sets, reps, and weights with an intuitive interface
- **Custom Exercises**: Create and save your own exercises
- **Workout History**: Review past workouts with detailed analytics
- **Templates**: Save and reuse workout routines
- **Active Timer**: Track rest periods between sets

### 🎯 Design Philosophy
- **Minimalist Interface**: Clean, distraction-free design focused on the essentials
- **Beginner-Friendly**: No overwhelming features or complex workflows
- **Fast Input**: Custom number pad for quick weight and rep entry
- **Visual Feedback**: Interactive body diagrams showing targeted muscle groups

## Screenshots

[Add screenshots here]

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Clone the Repository

```bash
# Clone with submodules (includes exercise database)
git clone --recursive https://github.com/randomlylelo/curlsapp.git

# Or if you already cloned without submodules
git submodule update --init --recursive
```

### Build and Run

1. Open `curlsapp.xcodeproj` in Xcode
2. Select your target device or simulator (iPhone recommended)
3. Press `Cmd+R` to build and run

### Testing

```bash
# Run tests from command line
xcodebuild test -project curlsapp.xcodeproj -scheme curlsapp -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Project Structure

The app follows a feature-based architecture with clear separation of concerns:

- **`App/`** - Main app entry point and navigation
- **`Features/`** - Feature modules (ExerciseDatabase, Session, History, Templates)
- **`Shared/`** - Shared components, models, and utilities
- **`Resources/`** - Assets and data files
- **`free-exercise-db/`** - Exercise database submodule (MIT licensed), forked from free-exercise-db

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

**Note**: The exercise database (`free-exercise-db` submodule) is separately licensed under MIT for maximum reusability.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Security

For security vulnerabilities, please see [SECURITY.md](SECURITY.md) for our security policy and reporting process.

## Acknowledgments

- Exercise data from the `free-exercise-db` project
- Built with SwiftUI and love for simple, effective design
- Inspired by the principle that fitness tracking should be accessible to everyone

## Contact

- GitHub Issues: [Report bugs or request features](https://github.com/randomlylelo/curlsapp/issues)
- Discussions: [Join the conversation](https://github.com/randomlylelo/curlsapp/discussions)
