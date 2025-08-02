- Whenever you finish a task make sure to build the project, if it fails to build, iterate until it works.
- When testing using xcodebuild use iPhone16

# Project Architecture: Feature-Based Structure

This project uses a Feature-Based architecture with clear separation of concerns:

## Folder Structure
```
curlsapp/
├── App/
│   ├── curlsappApp.swift                    # Main app entry point
│   └── ContentView.swift                    # Main tab view
├── Features/
│   ├── ExerciseDatabase/                    # Exercise browsing & details feature
│   │   ├── Models/
│   │   │   └── Exercise.swift               # Exercise data model
│   │   ├── ViewModels/
│   │   │   ├── ExercisesViewModel.swift     # Exercise list business logic
│   │   │   └── ExerciseDetailViewModel.swift # Exercise detail business logic
│   │   ├── Views/
│   │   │   ├── ExercisesView.swift          # Exercise list UI
│   │   │   └── ExerciseDetailView.swift     # Exercise detail UI
│   │   └── Services/
│   │       └── ExerciseService.swift        # Exercise data operations
│   ├── WorkoutSession/                      # Active workout tracking feature
│   │   └── Views/
│   │       └── HistoryView.swift            # Workout history UI (placeholder)
│   └── WorkoutHistory/                      # Workout history & analytics feature
│       └── Views/
│           └── WorkoutView.swift            # Active workout UI (placeholder)
├── Shared/
│   ├── Models/
│   │   ├── BodyPart.swift                   # Body part definitions
│   │   ├── BodyBack.swift                   # Back body diagram data
│   │   ├── BodyFront.swift                  # Front body diagram data
│   │   └── ExtendedBodyPart.swift           # Enhanced body part model
│   └── Components/
│       └── PlaceholderImageView.swift       # Reusable body diagram component
└── Resources/
    └── Data/
        ├── exercises.json                   # Exercise database
        ├── bodyparts.json                   # Body parts data
        ├── equipments.json                  # Equipment types
        └── muscles.json                     # Muscle groups
```

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

### Future Features
When expanding WorkoutSession and WorkoutHistory features:
1. Add Models, ViewModels, and Services folders to each feature as needed
2. Follow same structure: Models, ViewModels, Views, Services
3. Move business logic from placeholder Views into proper ViewModels
4. Create Services for workout data persistence and tracking

