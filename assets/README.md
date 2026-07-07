# Adventure Buddies - Assets

## Real Assets (Designer-Generated)
These images were created by the UI/UX Designer and should be placed in this directory:
- `buddy_default.png` — Default Buddy character
- `world_forest_letters.png` — Forest of Letters world theme
- `world_number_beach.png` — Number Beach world theme
- `world_shape_city.png` — Shape City world theme
- `world_feelings_garden.png` — Feelings Garden world theme
- `app_icon_concepts.png` — App icon design concepts

Source: `/home/team/shared/design/images/`

## Placeholder Assets
These directories contain placeholder or missing assets:

### `/sounds/`
Sound effects and music are **not yet included** in this MVP build. The following sound files need to be sourced:
- `button_pop.mp3` — Button press sound
- `correct_chime.mp3` — Correct answer sound
- `gentle_boing.mp3` — Gentle error sound
- `reward_jingle.mp3` — Reward celebration sound
- `bgm_forest.mp3` — Forest of Letters background music
- `bgm_beach.mp3` — Number Beach background music
- `bgm_city.mp3` — Shape City background music
- `bgm_garden.mp3` — Feelings Garden background music

Sound design recommendations are documented in `/home/team/shared/design/SOUND_AND_ANIMATION.md`

### `/fonts/`
The app uses Google Fonts (Fredoka One + Quicksand) via the `google_fonts` package at runtime. No local font files are required for development.

## Integration Notes
- Assets are referenced in `pubspec.yaml` under the `flutter/assets:` section
- Image paths in code use `assets/images/` prefix
- Sound files should use `assets/sounds/` prefix
- For production, replace all placeholder assets with finalized versions