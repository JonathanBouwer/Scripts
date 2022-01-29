from urllib.request import urlopen, Request
from os.path import exists
import json
import time
import os

FILE_NAME = "bad_apple_data.json"
CHRS = " ░▒▓"
FRAME_RATE = 18 # Video is native 18 FPS
REFRESH_FREQ = 1 / FRAME_RATE

data = {}
if exists(FILE_NAME):
    with open(FILE_NAME) as f:
      data = json.load(f)
else:
    req = Request("https://adryd.co/tba3")
    raw_data = urlopen(req).read().decode('utf-8')
    data = json.loads(raw_data)

    with open(FILE_NAME, "w") as f:
      f.write(raw_data)

term_size = os.get_terminal_size()
lines = term_size.lines

start_time = time.perf_counter()
expected_time = 0
for i, block in enumerate(data['c']):
  frame_start = time.perf_counter()
  expected_time = start_time + i * REFRESH_FREQ
  if (time.perf_counter() - expected_time > REFRESH_FREQ):
    continue

  out = ""
  for col_idx in range(len(block)):
    row = [row[col_idx] for row in block]
    out += "".join([f'{CHRS[val // 64]}'*2 for val in row]) + "\n"
  os.system('cls')
  print(out, flush=True)

  frame_time = time.perf_counter() - frame_start
  if frame_time < REFRESH_FREQ:
    time.sleep(REFRESH_FREQ - frame_time)
