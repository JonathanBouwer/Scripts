from math import floor
from shutil import get_terminal_size
from struct import unpack
from time import perf_counter, sleep

def read_data():
    FILE_NAME = 'raw_bad_apple.bin'
    NUM_FRAMES = 6569
    WIDTH = 72
    HEIGHT = 54

    with open(FILE_NAME, 'rb') as f:
        return [
            # Frames are defined bottom up, but displayed top down so reverse rows
            [unpack(f'{WIDTH}B', f.read(WIDTH)) for _ in range(HEIGHT)][::-1]
            for i in range(NUM_FRAMES)
        ]

def render_video(frames, frame_rate):
    MAX_LUMINANCE = 256
    CHRS = ' ░▒▓█' # Shading characters
    PROGRESS_BAR_SIZE = 2 * len(frames[0][0]) - 2 # Pixel = 2 chrs, Ends = '[', ']'

    i = 0
    start_time = perf_counter()
    while i < len(frames):
        # Simulate
        frame_buffer = [
            ''.join([f'{CHRS[floor(val / MAX_LUMINANCE * len(CHRS))]}' * 2 for val in row])
            for row in frames[i]
        ]

        percent = PROGRESS_BAR_SIZE * i // len(frames)
        frame_buffer.append(f'[{"#" * percent}{" " * (PROGRESS_BAR_SIZE - percent)}]')

        frame_buffer.append('\n' * (get_terminal_size().lines - len(frame_buffer)))

        # Render
        print('\n'.join(frame_buffer), end='', flush=True)

        # Sleep (or skip frames)
        current_time = perf_counter()
        expected_time = start_time + i / frame_rate
        if current_time < expected_time:
            sleep(expected_time - current_time)
        else:
            i += floor((current_time - expected_time) * frame_rate)

        i += 1
    print('\n' * get_terminal_size().lines)

def main():
    FRAME_RATE = 30
    frames = read_data()
    render_video(frames, FRAME_RATE)
    
main()