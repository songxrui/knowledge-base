import soundfile as sf
import os
d = r"D:\KnowledgeBase\videos\k-shaped-economy\assets"
total = 0
for i in range(1, 9):
    f = os.path.join(d, "f{}.wav".format(i))
    try:
        data, sr = sf.read(f)
        dur = len(data) / sr
        total += dur
        print("f{}: {:.1f}s".format(i, dur))
    except Exception as e:
        print("f{} error: {}".format(i, e))
print("Total: {:.1f}s ({:.1f}min)".format(total, total/60))