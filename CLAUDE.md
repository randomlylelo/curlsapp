- Whenever you finish a task make sure to build the project, if it fails to build, iterate until it works.
- When testing using xcodebuild use iPhone16
- When designing and coding keep the principal of Steve Job's simplicity in mind. the product should be simple and beautiful inside and outside.

# Project Architecture: Feature-Based Structure

This project uses a Feature-Based architecture with clear separation of concerns:

## Folder Structure
```
curlsapp/
├── App/
│   ├── curlsappApp.swift                    # Main app entry point
│   └── ContentView.swift                    # Main tab view with workout timer bar
├── Features/
│   ├── ExerciseDatabase/                    # Exercise browsing & details feature
│   │   ├── Models/
│   │   │   └── Exercise.swift               # Exercise data model with custom exercise support
│   │   ├── ViewModels/
│   │   │   ├── ExercisesViewModel.swift     # Exercise list business logic
│   │   │   └── ExerciseDetailViewModel.swift # Exercise detail business logic
│   │   ├── Views/
│   │   │   ├── ExercisesView.swift          # Exercise list UI
│   │   │   ├── ExerciseDetailView.swift     # Exercise detail UI
│   │   │   ├── BodyDiagramView.swift        # Interactive body diagram component
│   │   │   └── MuscleSelectionView.swift    # Muscle group selection UI
│   │   └── Services/
│   │       └── ExerciseService.swift        # Exercise data operations
│   ├── History/                             # Workout history & analytics feature
│   │   ├── Models/
│   │   │   ├── CompletedExercise.swift      # Completed exercise data model
│   │   │   ├── CompletedSet.swift           # Completed set data model
│   │   │   └── CompletedWorkout.swift       # Completed workout data model
│   │   ├── Services/
│   │   │   └── WorkoutStorageService.swift  # Workout persistence operations
│   │   ├── ViewModels/
│   │   │   └── HistoryViewModel.swift       # History business logic
│   │   └── Views/
│   │       ├── HistoryView.swift            # Workout history list UI
│   │       ├── WorkoutDetailView.swift      # Individual workout detail UI
│   │       └── WorkoutListItemView.swift    # Workout list item component
│   ├── Session/                             # Active workout tracking feature
│   │   ├── Models/
│   │   │   └── WorkoutInput.swift           # Workout session input data
│   │   ├── ViewModels/
│   │   │   └── WorkoutInputFocusManager.swift # Input focus management
│   │   └── Views/
│   │       ├── CompactExerciseTitleView.swift # Compact exercise title component
│   │       ├── CustomNumberPad.swift        # Custom numeric input pad
│   │       ├── ExerciseCardView.swift       # Exercise card in session
│   │       ├── ExerciseSelectionView.swift  # Exercise selection UI
│   │       ├── WorkoutSessionView.swift     # Active workout session UI
│   │       └── WorkoutView.swift            # Main workout tab UI
│   └── Templates/                           # Workout template management feature
│       ├── Models/
│       │   └── WorkoutTemplate.swift        # Template data models
│       ├── Services/
│       │   ├── TemplateStorageService.swift # Template persistence
│       │   └── TemplateValidationService.swift # Template validation logic
│       └── Views/
│           ├── SaveTemplateModal.swift      # Save template dialog
│           ├── TemplateCard.swift           # Template card component
│           ├── TemplateEditorView.swift     # Template editing UI
│           └── TemplateExerciseCardView.swift # Template exercise card
├── Shared/
│   ├── Components/
│   │   └── AlphabetIndexView.swift          # Alphabet index sidebar component
│   ├── Extensions/
│   │   └── Date+Extensions.swift            # Date utility extensions
│   ├── Models/
│   │   ├── BodyPart.swift                   # Body part definitions
│   │   ├── BodyBack.swift                   # Back body diagram data
│   │   ├── BodyFront.swift                  # Front body diagram data
│   │   ├── ExtendedBodyPart.swift           # Enhanced body part model
│   │   ├── MuscleGroup.swift                # Muscle group definitions
│   │   └── WorkoutManager.swift             # Global workout state manager
│   ├── Services/
│   │   └── TimeFormatter.swift              # Time formatting utilities
│   └── Views/
│       ├── AddCustomExerciseView.swift      # Custom exercise creation UI
│       └── ExerciseTitleCardView.swift      # Exercise title display component
└── Resources/
    └── Data/
        ├── exercises.json                   # Exercise database
        └── schema.json                      # Data schema definition
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

## Current Features

### ExerciseDatabase
- **Complete**: Exercise browsing, filtering, and detailed views
- **Body diagram**: Interactive muscle group selection
- **Custom exercises**: Support for user-created exercises
- **Search & filter**: By muscle groups, equipment, difficulty level

### Session (Active Workouts)
- **Complete**: Full workout tracking with timer
- **Exercise selection**: From database with custom exercise creation
- **Set tracking**: Weight, reps, and rest timer functionality
- **Input management**: Custom number pad and focus management
- **Session state**: Global workout manager with minimization support

### History
- **Complete**: Workout history storage and display
- **Persistence**: Local workout storage with completed exercise/set models
- **Analytics**: Duration, volume, and set count tracking
- **Detail views**: Individual workout review and analysis

### Templates
- **Complete**: Workout template creation and management
- **Template creation**: Save workouts as reusable templates
- **Template usage**: Start workouts from saved templates
- **Validation**: Template data validation and integrity checks
- **Management**: Template editing and organization

## Key Architectural Patterns

### State Management
- `WorkoutManager.shared`: Global singleton for active workout state
- `@Observable` ViewModels for feature-specific state
- Persistent storage through dedicated services

### Data Flow
1. **Services** load and persist data (JSON files, local storage)
2. **ViewModels** manage UI state and coordinate with services
3. **Views** bind to ViewModels using SwiftUI data binding
4. **Models** define data structures with Codable support

### UI Components
- **Feature Views**: Main screens for each feature area
- **Shared Components**: Reusable UI elements across features
- **Custom Components**: Specialized UI like body diagrams and number pads
- **Extensions**: Utility extensions for common functionality