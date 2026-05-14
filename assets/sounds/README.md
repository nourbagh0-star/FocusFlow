# Sound assets

`bell.mp3` is the completion sound played by `AudioService.playCompletionSound()`
when a Pomodoro phase finishes.

**Current asset:** "Alert bells echo" by Mixkit (royalty-free, free for
commercial and personal use — https://mixkit.co/free-sound-effects/bell/).

Replace `bell.mp3` with another short `.mp3` if you'd like — the app loads
whichever file lives at this path. If the file is missing, the timer still
works; `AudioService` swallows the load error silently.

Recommended characteristics for a replacement:
- Duration: 0.5–2 seconds
- Format: MP3, 44.1 kHz, mono or stereo
- Volume: pre-normalized to ~-6 dB

Other royalty-free sources:
- https://freesound.org (filter by Creative Commons 0)
- https://pixabay.com/sound-effects/
