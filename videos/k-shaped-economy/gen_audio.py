from kokoro_onnx import Kokoro
import soundfile as sf
import sys, os, urllib.request

model_dir = sys.argv[1]
os.chdir(model_dir)

# Download model files if needed
base_url = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0"
for fname in ["kokoro-v1.0.onnx", "voices-v1.0.bin"]:
    if not os.path.exists(fname):
        print(f"Downloading {fname}...")
        urllib.request.urlretrieve(f"{base_url}/{fname}", fname)
        print(f"  Downloaded {fname}")

kokoro = Kokoro("kokoro-v1.0.onnx", "voices-v1.0.bin")
print("Model loaded")

texts = [
    ("f1", "我们真的要提前想想出路了。一份报告说，灵活就业人数今年可能到3.2亿。2021年2亿，2024年底2.4亿。按这个速度，再过两年中国一半的就业人口都是灵活就业。"),
    ("f2", "这个概念叫K型分布。经济不再一起涨一起跌，而是劈成两条路。一部分往上走，一部分往下走。中间那波人越来越少，这就是你最近常听到的消失的中产。"),
    ("f3", "为什么出现K型分化？因为发展动能正在换挡。旧动能是房地产、基建、低端制造，劳动密集型，养人。新动能是人工智能、新能源、半导体，技术密集型，不养人。"),
    ("f4", "寒武纪，AI芯片公司，市值6000亿，员工一千多人。平均一个人肩上是五个多亿。这种产业资本喜欢政策支持，K的上臂。传统行业下行缩利，人就被吐出来了。"),
    ("f5", "美国七八十年代也经历过。汽车、钢铁、纺织干不过全球竞争，工厂关了。留下铁锈带。代价是什么？蓝领失业变K下臂，硅谷华尔街变K上臂。"),
    ("f6", "怎么跟上？不需要学编程。科技红利永远只有两波人能吃到，创造技术的人和使用技术的人。做好使用者就够了。"),
    ("f7", "第一，把你手头的技能跟AI结合。第二，别再卖产品了，卖你自己。第三，持续做内容，从一千个人里筛选出十个相信你的人。"),
    ("f8", "我就是一个灵活就业者，去年裸辞，靠AI和做内容养活自己。与其被动接受，不如从现在开始做准备。"),
]

assets_dir = os.path.join(model_dir, "..")
for fid, text in texts:
    print(f"Generating {fid}...")
    samples, sample_rate = kokoro.create(text, voice="zf_xiaobei", speed=1.0, lang="zh")
    path = os.path.join(assets_dir, f"{fid}.wav")
    sf.write(path, samples, sample_rate)
    duration = len(samples) / sample_rate
    print(f"  {duration:.1f}s")
print("DONE")
