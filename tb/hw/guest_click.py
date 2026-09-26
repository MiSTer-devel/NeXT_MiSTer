#!/usr/bin/env python3
"""guest_click.py X Y [click|dclick|move]: put the NeXT guest's pointer on a
screen pixel and click, measuring the pointer from screenshots each round
(relative motion with acceleration, as in the Quadra's scripts/guest/click.sh).
"""
import asyncio, subprocess, sys, os, time
import websockets
from PIL import Image, ImageChops

HOST = "192.168.99.143"
SSH = ["ssh", "-o", "BatchMode=yes", "-i", os.path.expanduser("~/.ssh/mister_only"), f"root@{HOST}"]
SCR = os.environ.get("NEXT_HW_SCRATCH", os.path.dirname(os.path.abspath(__file__)))

async def send(msgs, delay=0.02):
    async with websockets.connect(f"ws://{HOST}:8182/api/ws") as ws:
        try:
            for _ in range(2):
                await asyncio.wait_for(ws.recv(), timeout=0.3)
        except asyncio.TimeoutError:
            pass
        for m in msgs:
            if m.startswith("sleep:"):
                await asyncio.sleep(float(m[6:])); continue
            await ws.send(m)
            await asyncio.sleep(delay)

def grab(name):
    subprocess.run(["curl", "-s", "-m", "10", "-X", "POST", f"http://{HOST}:8182/api/screenshots", "-o", os.devnull])
    time.sleep(1.5)
    f = subprocess.run(SSH + ["ls -t /media/fat/screenshots/NeXT/ | head -1"], capture_output=True, text=True).stdout.strip()
    subprocess.run(["scp", "-q", "-i", os.path.expanduser("~/.ssh/mister_only"), f"root@{HOST}:/media/fat/screenshots/NeXT/{f}", name])
    return Image.open(name).convert("L")

def locate(bg, cur):
    d = ImageChops.difference(bg, cur).point(lambda v: 255 if v > 40 else 0)
    # ignore the dock clock
    d.paste(0, (1040, 60, 1109, 125))
    box = d.getbbox()
    return box

def steps(n, dx, dy):
    return [f"mouseMove:{dx},{dy}"] * n

async def main():
    tx, ty = int(sys.argv[1]), int(sys.argv[2])
    mode = sys.argv[3] if len(sys.argv) > 3 else "click"
    await send(steps(60, -12, -12))
    bg = grab(os.path.join(SCR, "_bg.png"))
    cx = cy = 0
    sx = sy = 1.0   # px per event
    for attempt in range(12):
        dx, dy = tx - cx, ty - cy
        if abs(dx) <= 3 and abs(dy) <= 3:
            print(f"on target ({cx},{cy})")
            if mode == "click":
                await send(["mouseBtn:left_down", "sleep:0.15", "mouseBtn:left_up"])
            elif mode == "dclick":
                await send(["mouseBtn:left_down", "sleep:0.08", "mouseBtn:left_up", "sleep:0.12",
                            "mouseBtn:left_down", "sleep:0.08", "mouseBtn:left_up"])
            return 0
        ex = int(dx / sx / 2) or (1 if dx > 3 else -1 if dx < -3 else 0)
        ey = int(dy / sy / 2) or (1 if dy > 3 else -1 if dy < -3 else 0)
        ex = max(-300, min(300, ex)); ey = max(-300, min(300, ey))
        msgs = []
        if ex: msgs += steps(abs(ex), 1 if ex > 0 else -1, 0)
        if ey: msgs += steps(abs(ey), 0, 1 if ey > 0 else -1)
        await send(msgs)
        cur = grab(os.path.join(SCR, "_cur.png"))
        box = locate(bg, cur)
        if not box:
            print("cursor not found; nudging"); await send(steps(3, 1, 1)); continue
        # the diff shows the old and the new cursor; the old one sits at (cx,cy)
        # so take the box corner farthest from it
        nx = box[2] - 16 if box[2] - 16 > cx + 4 else box[0]
        ny = box[3] - 22 if box[3] - 22 > cy + 4 else box[1]
        nx = max(nx, 0); ny = max(ny, 0)
        mx, my = nx - cx, ny - cy
        if abs(ex) > 2 and mx * ex > 0: sx = max(0.5, min(8.0, abs(mx) / abs(ex)))
        if abs(ey) > 2 and my * ey > 0: sy = max(0.5, min(8.0, abs(my) / abs(ey)))
        print(f"sent ({ex},{ey}) box {box} -> at ({nx},{ny}) target ({tx},{ty}) scale {sx:.2f}/{sy:.2f}")
        cx, cy = nx, ny
        bg = cur
    print("failed"); return 3

sys.exit(asyncio.run(main()))
