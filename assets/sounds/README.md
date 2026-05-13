# Sound assets

Drop a short notification-bell `.mp3` here as `bell.mp3`.

The free-tier completion sound plays via `AudioService.playCompletionSound()`,
which loads `assets/sounds/bell.mp3`. If the file is missing, the timer still
works — `AudioService` swallows the exception silently.

Suggested sources for royalty-free notification sounds:
- https://freesound.org (filter by Creative Commons 0)
- https://pixabay.com/sound-effects/

Recommended characteristics:
- Duration: 0.5–2 seconds
- Format: MP3, 44.1 kHz, mono or stereo
- Volume: pre-normalized to ~-6 dB
