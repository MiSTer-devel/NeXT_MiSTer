#!/usr/bin/env python3
"""Type text into the MiSTer guest through the MiSTer Remote websocket,
as raw Linux keycodes (US layout), shift held for the shifted symbols.

    python type_text.py --host 192.168.99.143 --file prog.c
    python type_text.py --host 192.168.99.143 "cat > x.c" ENTER
"""
import asyncio, sys, os, argparse
import websockets

# Linux input keycodes, US layout
KEYS = {
    'a':30,'b':48,'c':46,'d':32,'e':18,'f':33,'g':34,'h':35,'i':23,'j':36,'k':37,'l':38,'m':50,
    'n':49,'o':24,'p':25,'q':16,'r':19,'s':31,'t':20,'u':22,'v':47,'w':17,'x':45,'y':21,'z':44,
    '1':2,'2':3,'3':4,'4':5,'5':6,'6':7,'7':8,'8':9,'9':10,'0':11,
    '-':12,'=':13,'[':26,']':27,';':39,"'":40,'`':41,'\\':43,',':51,'.':52,'/':53,' ':57,
    '\n':28,'\t':15,
}
SHIFTED = {
    '!':'1','@':'2','#':'3','$':'4','%':'5','^':'6','&':'7','*':'8','(':'9',')':'0',
    '_':'-','+':'=','{':'[','}':']',':':';','"':"'",'~':'`','|':'\\','<':',','>':'.','?':'/',
}
SHIFT = 42

async def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default=os.environ.get("MISTER_HOST", "192.168.99.143"))
    ap.add_argument("--port", type=int, default=8182)
    ap.add_argument("--delay", type=float, default=0.06)
    ap.add_argument("--file")
    ap.add_argument("text", nargs="*")
    a = ap.parse_args()
    if a.file:
        text = open(a.file).read()
    else:
        text = " ".join(a.text).replace("ENTER", "\n")
    url = f"ws://{a.host}:{a.port}/api/ws"
    async with websockets.connect(url) as ws:
        try:
            for _ in range(2):
                await asyncio.wait_for(ws.recv(), timeout=0.5)
        except asyncio.TimeoutError:
            pass
        n = 0
        for ch in text:
            if ch == '\r':
                continue
            up = ch.isupper() or ch in SHIFTED
            base = ch.lower() if ch.isupper() else SHIFTED.get(ch, ch)
            code = KEYS[base]
            if up:
                await ws.send(f"kbdRawDown:{SHIFT}")
                await asyncio.sleep(a.delay)
            await ws.send(f"kbdRaw:{code}")
            await asyncio.sleep(a.delay)
            if up:
                await ws.send(f"kbdRawUp:{SHIFT}")
                await asyncio.sleep(a.delay)
            n += 1
            if ch == '\n':
                await asyncio.sleep(0.25)
        print(f"typed {n} chars")

asyncio.run(main())
