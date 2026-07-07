import soundfile as sf
import numpy as np
import os

d = r"D:\KnowledgeBase\videos\k-shaped-economy\assets"
all_audio = []
sr = None
for i in range(1, 9):
    f = os.path.join(d, "f{}.wav".format(i))
    data, rate = sf.read(f)
    if sr is None:
        sr = rate
    all_audio.append(data)

combined = np.concatenate(all_audio)
out = os.path.join(r"D:\KnowledgeBase\videos\k-shaped-economy\assets", "full_audio.wav")
sf.write(out, combined, sr)
print("Combined audio: {:.1f}s at {}Hz".format(len(combined)/sr, sr))