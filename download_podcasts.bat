@echo off
rem = """
python -x "%~f0" %*
pause
exit /b %errorlevel%
"""

import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor
from urllib.request import urlopen, Request
from os import listdir, mkdir
from os.path import exists as dir_exists, isfile
from math import floor
from re import match
from time import perf_counter

podcasts = [
  # {
  #     'name'   : NAME, 
  #     'url'    : RSS_FEED,
  #     'rename' : lambda x, i: f'{x}',
  #     'look_back' : 0 # (Can be excluded)
  # },
]

def get_episode_list(podcast_url):
    request = Request(podcast_url, headers={'User-Agent' : 'Magic Browser'})
    xml_data = urlopen(request).read()
    episodes = []
    for item in ET.fromstring(xml_data).iter('item'):
        enclosure = item.find('enclosure')
        length = 0
        try:
            length = int(enclosure.get('length', default='0'))
        except:
            pass

        try:
            episodes.append({
                'title': item.find('title').text,
                'url': enclosure.get('url'),
                'size': length
            })
        except:
            print('Couldn\'t find url for ' + item.find('title').text)

    episodes.reverse()
    return episodes

def print_download_info(size, gotten, speed, LOADING_BAR_SIZE = 20):
    percent = floor(gotten / size * LOADING_BAR_SIZE)
    time_remaining = (size - gotten) // speed
    minutes_remaining = int(time_remaining // 60)
    seconds_remaining = int(time_remaining % 60)
    remaining = '' if minutes_remaining == 0 else str(minutes_remaining) + 'm'
    remaining += str(seconds_remaining)+ 's'
    size = size // 1024
    gotten = gotten // 1024
    speed = speed // 1024
    loading_bar = '#' * percent + '_' * (LOADING_BAR_SIZE - percent)
    print('\r', end='')
    if time_remaining > 0:
        print('[{}] {}Kb / {}Kb | {} Kb/s {} remaining {}'.format(loading_bar, gotten, size, speed, remaining, ' '*20), end='')
    else:
        print('[{}] {}Kb / {}Kb | {} Kb/s {}'.format(loading_bar, gotten, size, speed, ' '*20), end='')  

def print_summary(size, duration):
    speed = size // duration
    size = size // 1024
    speed = speed // 1024
    minutes_taken = int(duration // 60)
    duration = int(duration % 60)
    print('\r', end='')
    print('Download complete | {} Kb | {} Kb/s | {}m{}s{}\n'.format(size, speed, minutes_taken, duration, ' '*30))

def fetch_podcast_feed(podcast):
    print('Checking ' + podcast['name'])

    if not dir_exists(podcast['name']):
        mkdir(podcast['name'])

    gotten_episodes = [item for item in listdir(podcast['name']) if isfile(podcast['name'] + '/' + item)]
    gotten_episodes = gotten_episodes + [item for item in listdir() if isfile(item)]

    return podcast, gotten_episodes, get_episode_list(podcast['url'])

def download_episode(episode, filename, CHUNK_SIZE = 128 * 1024, UPDATE_FREQUENCY = 10):
    print('Downloading: {}'.format(episode['title']))    
    request = Request(episode['url'], headers={'User-Agent' : "Magic Browser"})
    response = urlopen(request)
    episode['size'] = int(response.headers['content-length'])
    got = 0

    start_time = perf_counter()
    with open(filename, 'wb') as file:
        while True:
            chunk = response.read(CHUNK_SIZE)
            if got % (UPDATE_FREQUENCY * CHUNK_SIZE) == 0:
                speed = got / (perf_counter() - start_time)
            if not chunk:
                break
            file.write(chunk)
            got += CHUNK_SIZE
            print_download_info(episode['size'], got, max(speed, 1))
    print_summary(episode['size'], perf_counter() - start_time)

illegal_chars = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', '\n']
def main():
    print('Checking for new podcasts')
    to_download = []
    with ThreadPoolExecutor() as executor:
        for podcast, gotten_episodes, episodes in executor.map(fetch_podcast_feed, podcasts):
            if podcast.get('look_back', 0) > 0:
                episodes = episodes[-podcast.get('look_back'):]
            
            new_episodes = False
            for index, episode in enumerate(episodes, 1):
                filename = episode['title']
                try:
                    filename = podcast['rename'](filename, index)
                except:
                    continue
                for char in illegal_chars:
                    filename = filename.replace(char, '')
                filename = filename + '.mp3'

                if filename in gotten_episodes:
                    continue
                new_episodes = True
                to_download.append((episode, filename))
                print('New Episode: {} ({})'.format(episode['title'], filename))
            if new_episodes:
                print()

    if len(to_download) == 0:
        print('No new podcast episodes to download')
        return

    for episode, filename in to_download:
        download_episode(episode, filename)

if __name__ == "__main__":
    main()
