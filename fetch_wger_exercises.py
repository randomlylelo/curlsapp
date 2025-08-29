#!/usr/bin/env python3
"""
Fetch exercises from wger.de API and convert to curlsapp format.

This script fetches exercise data directly from the public wger API
and transforms it into the JSON format used by curlsapp.
"""

import requests
import json
import re
from typing import List, Dict, Any
from html import unescape

# API endpoints
BASE_URL = "https://wger.de/api/v2"
EXERCISE_ENDPOINT = f"{BASE_URL}/exerciseinfo/"
CATEGORY_ENDPOINT = f"{BASE_URL}/exercisecategory/"
MUSCLE_ENDPOINT = f"{BASE_URL}/muscle/"
EQUIPMENT_ENDPOINT = f"{BASE_URL}/equipment/"

# Headers for API requests
HEADERS = {
    'User-Agent': 'curlsapp-exercise-fetcher/1.0'
}

def fetch_all_paginated(url: str) -> List[Dict]:
    """Fetch all results from a paginated API endpoint."""
    results = []
    while url:
        response = requests.get(url, headers=HEADERS)
        response.raise_for_status()
        data = response.json()
        results.extend(data['results'])
        url = data.get('next')
    return results

def clean_html_description(html_text: str) -> List[str]:
    """Convert HTML description to array of instruction steps."""
    if not html_text:
        return []
    
    # Remove HTML tags
    clean_text = re.sub(r'<[^>]+>', '', html_text)
    # Unescape HTML entities
    clean_text = unescape(clean_text)
    # Split by paragraphs and clean up
    steps = [step.strip() for step in clean_text.split('\n') if step.strip()]
    # Remove empty steps and tips
    filtered_steps = []
    for step in steps:
        if step and not step.startswith('Tip:') and not step.startswith('Note:'):
            filtered_steps.append(step)
    
    return filtered_steps[:10]  # Limit to 10 steps max

def map_equipment_name(equipment_list: List[Dict]) -> str:
    """Map wger equipment to curlsapp format."""
    if not equipment_list:
        return "body only"
    
    equipment_map = {
        "Barbell": "barbell",
        "SZ-Bar": "barbell", 
        "Dumbbell": "dumbbell",
        "Kettlebell": "kettlebell",
        "Pull-up bar": "pull-up bar",
        "none (bodyweight exercise)": "body only",
        "Swiss Ball": "exercise ball",
        "Gym mat": "body only",
        "Bench": "body only",
        "Incline bench": "body only",
        "Resistance band": "bands",
        "Cable": "cable"
    }
    
    # Use the first equipment item
    first_equipment = equipment_list[0].get('name', '')
    mapped_name = equipment_map.get(first_equipment, first_equipment.lower())
    return mapped_name if mapped_name else "other"

def map_muscle_name(muscle: Dict) -> str:
    """Map wger muscle to curlsapp muscle name."""
    muscle_map = {
        "Biceps brachii": "biceps",
        "Anterior deltoid": "shoulders", 
        "Pectoralis major": "chest",
        "Triceps brachii": "triceps",
        "Rectus abdominis": "abdominals",
        "Gastrocnemius": "calves",
        "Gluteus maximus": "glutes",
        "Trapezius": "traps",
        "Quadriceps femoris": "quadriceps",
        "Biceps femoris": "hamstrings",
        "Latissimus dorsi": "lats",
        "Soleus": "calves",
        "Obliquus externus abdominis": "abdominals",
        "Deltoid": "shoulders",
        "Rhomboideus major": "middle back",
        "Teres major": "lats",
        "Infraspinatus": "shoulders",
        "Brachialis": "biceps",
        "Brachioradialis": "forearms",
        "Tibialis anterior": "shins",
        "Erector spinae": "lower back"
    }
    
    name = muscle.get('name', '')
    name_en = muscle.get('name_en', '')
    
    # Prefer mapped values, then name_en, then name
    mapped_name = muscle_map.get(name, name_en.lower() if name_en else name.lower())
    return mapped_name if mapped_name else "other"

def map_category_to_app_category(category_name: str) -> str:
    """Map wger category to app category."""
    category_map = {
        "Arms": "arms",
        "Legs": "legs", 
        "Abs": "abs",
        "Chest": "chest",
        "Back": "back",
        "Shoulders": "shoulders",
        "Calves": "calves"
    }
    return category_map.get(category_name, category_name.lower())

def determine_force_type(primary_muscles: List[str], category: str, exercise_name: str) -> str:
    """Determine if exercise is push, pull, or static."""
    name_lower = exercise_name.lower()
    
    # Static exercises
    if any(word in name_lower for word in ['stretch', 'hold', 'plank', 'static']):
        return "static"
    
    # Pull exercises
    pull_muscles = ['lats', 'middle back', 'biceps', 'traps']
    pull_names = ['pull', 'row', 'chin-up', 'pulldown', 'curl']
    
    if (any(muscle in primary_muscles for muscle in pull_muscles) or 
        any(name in name_lower for name in pull_names)):
        return "pull"
    
    # Default to push for most other exercises
    return "push"

def determine_mechanic(muscle_count: int, exercise_name: str) -> str:
    """Determine if exercise is compound or isolation."""
    name_lower = exercise_name.lower()
    
    # Common isolation exercises
    isolation_words = ['curl', 'extension', 'fly', 'raise', 'flye']
    if any(word in name_lower for word in isolation_words):
        return "isolation"
    
    # If targeting multiple muscle groups, likely compound
    return "compound" if muscle_count >= 2 else "isolation"

def determine_level(description: str, exercise_name: str) -> str:
    """Determine exercise difficulty level."""
    text = (description + " " + exercise_name).lower()
    
    if any(word in text for word in ['beginner', 'basic', 'easy', 'simple']):
        return "beginner"
    elif any(word in text for word in ['advanced', 'expert', 'difficult', 'complex']):
        return "advanced"
    else:
        return "intermediate"

def generate_exercise_id(name: str) -> str:
    """Generate a unique ID from exercise name."""
    # Remove equipment part if present
    clean_name = re.sub(r'\s*\([^)]*\)\s*$', '', name)
    # Convert to snake_case
    id_str = re.sub(r'[^a-zA-Z0-9\s]', '', clean_name)
    id_str = re.sub(r'\s+', '_', id_str.strip())
    return id_str.lower()

def transform_exercise(exercise_data: Dict, categories: Dict = None, muscles: Dict = None, equipment: Dict = None) -> Dict:
    """Transform a wger exercise to curlsapp format."""
    # Get English translation (language ID 2 is English in wger)
    english_translation = None
    for translation in exercise_data.get('translations', []):
        if translation.get('language') == 2:  # English
            english_translation = translation
            break
    
    if not english_translation:
        return None
    
    # Get category info (now it's a nested object)
    category_obj = exercise_data.get('category', {})
    category_name = category_obj.get('name', 'Other')
    
    # Get muscle info (now they're nested objects)
    muscle_objects = exercise_data.get('muscles', [])
    secondary_muscle_objects = exercise_data.get('muscles_secondary', [])
    
    primary_muscles = [map_muscle_name(muscle) for muscle in muscle_objects]
    secondary_muscles = [map_muscle_name(muscle) for muscle in secondary_muscle_objects]
    
    # Clean up muscle names
    primary_muscles = [m for m in primary_muscles if m and m != '']
    secondary_muscles = [m for m in secondary_muscles if m and m != '']
    
    # Get equipment info (now they're nested objects)
    equipment_objects = exercise_data.get('equipment', [])
    equipment_name = map_equipment_name(equipment_objects)
    
    # Build exercise name
    base_name = english_translation.get('name', 'Unknown Exercise')
    if equipment_objects and equipment_name != "body only":
        exercise_name = f"{base_name} ({equipment_objects[0].get('name', '')})"
    else:
        exercise_name = base_name
    
    # Get instructions
    description = english_translation.get('description', '')
    instructions = clean_html_description(description)
    
    # Determine properties
    total_muscle_count = len(primary_muscles) + len(secondary_muscles)
    force_type = determine_force_type(primary_muscles, category_name, base_name)
    mechanic = determine_mechanic(total_muscle_count, base_name)
    level = determine_level(description, base_name)
    
    # Get license information
    license_obj = exercise_data.get('license', {})
    exercise_license_author = exercise_data.get('license_author', '')
    translation_license_author = english_translation.get('license_author', '')
    
    # Build license info
    license_info = {
        "license_name": license_obj.get('short_name', 'Unknown'),
        "license_url": license_obj.get('url', ''),
        "exercise_author": exercise_license_author,
        "translation_author": translation_license_author,
        "source": "wger.de"
    }
    
    # Build the exercise object
    exercise = {
        "name": exercise_name,
        "altNames": [],  # Could be populated from exercise aliases if needed
        "force": force_type,
        "level": level,
        "mechanic": mechanic,
        "equipment": equipment_name,
        "primaryMuscles": primary_muscles,
        "secondaryMuscles": secondary_muscles,
        "instructions": instructions,
        "category": "strength",  # Most wger exercises are strength
        "id": generate_exercise_id(base_name),
        "original_name": base_name,
        "app_category": map_category_to_app_category(category_name),
        "license": license_info
    }
    
    return exercise

def main():
    """Main function to fetch and transform exercises."""
    print("Fetching exercises from wger API...")
    
    # Fetch exercises (they now include all nested data)
    exercises_data = fetch_all_paginated(EXERCISE_ENDPOINT)
    
    print(f"Processing {len(exercises_data)} exercises...")
    
    # Transform exercises
    transformed_exercises = []
    for exercise_data in exercises_data:
        try:
            transformed = transform_exercise(exercise_data)
            if transformed:
                transformed_exercises.append(transformed)
        except Exception as e:
            print(f"Error processing exercise {exercise_data.get('id', 'unknown')}: {e}")
            continue
    
    print(f"Successfully transformed {len(transformed_exercises)} exercises")
    
    # Save to JSON file
    output_file = "wger_exercises.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(transformed_exercises, f, indent=2, ensure_ascii=False)
    
    print(f"Exercises saved to {output_file}")
    
    # Print some stats
    categories_found = set(ex['app_category'] for ex in transformed_exercises)
    equipment_found = set(ex['equipment'] for ex in transformed_exercises)
    
    print(f"\nStats:")
    print(f"  Categories: {sorted(categories_found)}")
    print(f"  Equipment types: {sorted(equipment_found)}")

if __name__ == "__main__":
    main()