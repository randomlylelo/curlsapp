# Contributing to Curls App

Thank you for your interest in contributing to Curls App! We welcome contributions that align with our philosophy of simplicity, privacy, and beautiful design.

## 🎯 Our Philosophy

Before contributing, please understand our core principles:
- **Simplicity First**: Features should be intuitive and accessible to beginners
- **Privacy by Design**: No cloud dependencies, analytics, or data collection
- **Beautiful Inside and Out**: Clean code and clean UI, following Steve Jobs' design philosophy
- **Zero Dependencies**: We use only native iOS frameworks

## 🚀 Getting Started

1. **Fork the Repository**
   ```bash
   git clone --recursive https://github.com/[your-username]/curlsapp.git
   cd curlsapp
   git submodule update --init --recursive
   ```

2. **Set Up Development Environment**
   - Install Xcode (latest version)
   - Open `curlsapp.xcodeproj`
   - Select iPhone 16 simulator or your device
   - Build and run with `Cmd+R`

3. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📝 Development Guidelines

### Code Style
- Follow existing SwiftUI patterns and conventions
- Use `@Observable` for state management
- Keep views simple and extract complex logic to ViewModels
- Write self-documenting code (minimal comments)
- Follow feature-based architecture in `Features/` directory

### Testing
Before submitting, ensure:
```bash
# All tests pass
xcodebuild test -project curlsapp.xcodeproj -scheme curlsapp -destination 'platform=iOS Simulator,name=iPhone 16'

# Project builds successfully
xcodebuild build -project curlsapp.xcodeproj -scheme curlsapp -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Commit Messages
- Use clear, descriptive commit messages
- Format: `type: brief description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat: add workout pause functionality`

## 🎨 Design Guidelines

- **Minimalist UI**: Remove anything that doesn't add value
- **Consistent Animations**: Use `AnimationConstants.swift` for timing
- **Accessibility**: Ensure VoiceOver and Dynamic Type support
- **Dark Mode**: Test in both light and dark appearances
- **One-Handed Use**: Optimize for thumb reachability

## 🔧 Areas for Contribution

### Priority Areas
- Bug fixes and performance improvements
- Accessibility enhancements
- watchOS companion app (coming soon)
- Exercise database improvements
- UI/UX refinements following our simplicity principle

### Please Don't
- Add external dependencies or third-party libraries
- Implement cloud syncing or analytics
- Add complex features that compromise simplicity
- Change the privacy-first approach

## 📤 Submitting Changes

1. **Test Your Changes**
   - Run the app on simulator and device if possible
   - Verify all existing features still work
   - Add tests for new functionality

2. **Update Documentation**
   - Update README.md if adding features
   - Document any new architecture patterns in CLAUDE.md
   - Add inline documentation for complex logic

3. **Submit Pull Request**
   - Push to your fork: `git push origin feature/your-feature-name`
   - Create PR with clear description
   - Reference any related issues
   - Include screenshots for UI changes

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] UI/UX improvement
- [ ] Documentation update

## Testing
- [ ] Tested on iPhone simulator
- [ ] All tests pass
- [ ] No new warnings

## Screenshots (if applicable)
[Add screenshots here]
```

## 🐛 Reporting Issues

### Bug Reports
Include:
- iOS version
- Device model
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

### Feature Requests
- Explain the use case
- Describe how it fits our simplicity philosophy
- Provide mockups if possible

## 💬 Communication

- **Questions**: Open a [GitHub Discussion](https://github.com/randomlylelo/curlsapp/discussions)
- **Bugs**: Create an [Issue](https://github.com/randomlylelo/curlsapp/issues)
- **Ideas**: Share in Discussions first

## 📜 License

By contributing, you agree that your contributions will be licensed under the GNU GPL v3.0.

## 🙏 Thank You!

Every contribution, no matter how small, helps make Curls App better for the fitness community. We appreciate your time and effort in keeping this app simple, beautiful, and private.

---

**Remember**: When in doubt, choose simplicity. If a feature needs explanation, it might be too complex.