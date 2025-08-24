- Whenever you finish a task make sure to build the project, if it fails to build, iterate until it works.
- When testing using xcodebuild use iPhone16
- When designing and coding keep the principal of Steve Job's simplicity in mind. the product should be simple and beautiful inside and outside.
- If any instructions are unclear or there are some edge cases that I yet to consider when I write it in the prompt, ask the question before implementing.

# Project Architecture & Design Philosophy

## Purpose of This Document

This CLAUDE.md serves as an architectural guide and design philosophy reference. It focuses on the *why* and *how* of our engineering decisions rather than specific implementation details that can be discovered by reading the code. The goal is to maintain consistency in architectural thinking and design principles while allowing the codebase to evolve without requiring constant documentation updates.

## Core Design Philosophy

This is a SwiftUI iOS fitness app that helps users track their workouts, built around **Steve Jobs' principle of simplicity** - the product should be simple and beautiful both inside (clean, readable code) and outside (intuitive user experience). Every technical and design decision should serve this goal.

The codebase uses a **Feature-Based architecture** with clear separation of concerns, prioritizing:
- **Simplicity over complexity** - Choose the simpler solution when it achieves the same goal
- **Clarity over cleverness** - Code should be immediately understandable
- **User-focused design** - Every feature should make the workout experience better, not just add functionality

## Project Structure

To understand the current folder structure, explore the codebase starting from the root directory. The project is organized as:
- **App/**: Main app entry point and root view
- **Features/**: Each major feature in its own folder (e.g., ExerciseDatabase, Session, History, Templates)
- **Shared/**: Reusable components, models, and utilities
- **Resources/**: Static data files (JSON databases)

### Feature Organization Pattern

Each feature follows the same organizational pattern. For a concrete example, examine the `Features/ExerciseDatabase/` folder which demonstrates the standard structure:
- **Models/**: Data structures (e.g., `Exercise.swift`)
- **ViewModels/**: Business logic and state management (e.g., `ExercisesViewModel.swift`)
- **Views/**: SwiftUI UI components (e.g., `ExercisesView.swift`)
- **Services/**: Data operations and business logic (e.g., `ExerciseService.swift`)

When creating new features, follow this same pattern for consistency.

## Architecture Guidelines

### Services
- Handle data operations (loading JSON, filtering, searching)
- No UI dependencies
- Pure business logic functions
- Example: `ExerciseService.loadExercises()`, `ExerciseService.searchExercises()`

### ViewModels
- Bridge between Services and Views
- Handle UI state (`@Observable` classes)
- Transform data for display
- Example: `ExercisesViewModel.searchText`, `ExerciseDetailViewModel.getSelectedBodyParts()`

### Views
- Pure SwiftUI UI components
- Minimal business logic
- Use ViewModels for data and state
- Example: `ExercisesView` uses `ExercisesViewModel`

### Models
- Data structures only
- `Codable` for JSON parsing
- Shared models go in `Shared/Models/`
- Feature-specific models go in `Features/{FeatureName}/Models/`

## Current Features

The app includes four main features that can be explored in the `Features/` directory:
- **ExerciseDatabase**: Exercise browsing, filtering, and detailed views with interactive body diagrams
- **Session**: Active workout tracking with timer, set tracking, and custom input management
- **History**: Workout history storage, analytics, and detailed workout reviews
- **Templates**: Workout template creation, management, and reusable workout patterns

Explore each feature folder to understand specific implementations and capabilities.

## Key Architectural Patterns

Follow the established patterns in the codebase for state management, data flow, and UI components. Examine existing implementations to understand how features coordinate with each other and manage their lifecycle.