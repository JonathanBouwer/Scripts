@echo off
rem = """
python -x "%~f0" %*
pause
exit /b %errorlevel%
"""

from urllib.parse import urlencode
from urllib.request import urlopen, Request
import json
import re

DEBUG=False
# Create a file called anime_movie_jwt.txt with your token
STERKINIKOR_JWT=open("anime_movie_jwt.txt").read()

def debug_print(val):
    if DEBUG:
        print(val)


def string_to_keyword_set(val):
    if val == None:
        return set()
    return set([x.lower() for x in re.sub(r"[^a-zA-Z0-9 ]", "", val).split(' ')])


def query_anilist(search_title, runtime):
    query = '''
query ($search: String, $duration_greater: Int, $duration_lesser: Int) {
  Page (page: 1, perPage: 50) {
    pageInfo {
      total
      currentPage
      lastPage
      hasNextPage
      perPage
    }
    media (search: $search,
           duration_greater: $duration_greater,
           duration_lesser: $duration_lesser,
           type: ANIME,
           format: MOVIE,
           popularity_greater: 1000) {
      id
      title {
        romaji
        english
      }
      staff {
        edges {
          role
          node {
            id
            name {
              first
              last
            }
          }
        }
      }
    }
  }
}
    '''

    # Define our query variables and values that will be used in the query request
    variables = {
        'search': search_title,
        'duration_greater': runtime - 5,
        'duration_lesser': runtime + 5
    }

    url = 'https://graphql.anilist.co'
    standard_headers = {'User-Agent' : 'Magic Browser', 'Content-Type': 'application/json','Accept': 'application/json',}
    data = json.dumps({'query': query, 'variables': variables})

    request = Request(url, data=data.encode('utf-8'), headers=standard_headers)
    response = {}
    debug_print(f'Searching for {search_title} in AniList')
    try:
        raw_response = urlopen(request).read().decode('utf-8')
        response = json.loads(raw_response)
    except Exception as err:
        raise RuntimeError(err.read().decode('utf-8'))

    return response


def parse_anilist_response(response, search_title, search_staff):
    search_term_words = string_to_keyword_set(search_title)
    data = response['data']['Page']
    total = data['pageInfo']['total']
    if total == 0:
        debug_print('Found no matching anime')
        return False

    debug_print(f'Found {total} similarly named anime')
    results = []

    for anime_entry in data['media']:
        staff_names = set()
        for staff_member in anime_entry['staff']['edges']:
            staff_name = staff_member['node']['name']
            first_name = '' if staff_name['first'] == None else staff_name['first'].lower()
            last_name = '' if staff_name['last'] == None else staff_name['last'].lower()
            staff_names.add(f'{first_name} {last_name}')
            staff_names.add(f'{last_name} {first_name}')

        rank = 0
        for staff_name in search_staff:
            if staff_name.lower() in staff_names:
                rank += 2

        title_words = string_to_keyword_set(anime_entry['title']['english'])
        romaji_words = string_to_keyword_set(anime_entry['title']['romaji'])
        title_words = title_words.union(romaji_words)

        for word in search_term_words:
            if word in title_words:
                rank += 1

        results.append({'rank': rank, 'romaji_title': anime_entry['title']['romaji'], 'anilist_url': f'https://anilist.co/anime/{anime_entry["id"]}'})

    best_matches = sorted([result for result in results if result['rank'] > 0], key=lambda x: x['rank'], reverse=True)
    debug_print(f'Found {len(best_matches)} anime which match closely')
    if len(best_matches) == 0:
        return False

    best_match = best_matches[0]
    print(f'Best Match - {best_match["romaji_title"]} - {best_match["anilist_url"]}')
    return True


def is_in_anilist(search_title, search_staff, runtime):
    response = query_anilist(search_title, runtime)
    return parse_anilist_response(response, search_title, search_staff)


def query_animated_movie():
    url = 'https://www.sterkinekor.com/middleware/api/v2/movies'
    standard_headers = {'User-Agent' : 'Magic Browser', "x-session": STERKINIKOR_JWT}
    request = Request(url, headers=standard_headers)
    response = {}
    try:
        raw_response = urlopen(request).read().decode('utf-8')
        response = json.loads(raw_response)
    except Exception as err:
        raise RuntimeError(err.read().decode('utf-8'))

    movies = response['data']['movies']
    animated_movies = []
    for movie in movies:
        for genre in movie["genres"]:
            if genre['name'].upper() == 'ANIMATION':
                break
        else:
            continue
        url = f'https://www.sterkinekor.com/details/{movie["id"]}/{movie["title_slug"]}'
        staff = []
        for key, staff_members in movie['cast'].items():
            for staff_member in staff_members:
                staff.append(f'{staff_member["FirstName"]} {staff_member["LastName"]}')

        animated_movies.append({'title': movie['title'], 'url': url, 'staff': staff, 'runtime': int(movie['runtime'])})

    return animated_movies


def main():
    animated_movies = query_animated_movie()
    found = False
    for animated_movie in animated_movies:
        if is_in_anilist(animated_movie['title'], animated_movie['staff'], animated_movie['runtime']):
            print(f'Ster-kinekor - {animated_movie["title"]}: {animated_movie["url"]}')
            print()
            found = True

    if not found:
        print("Nothing Found")


if __name__=='__main__':
    main()