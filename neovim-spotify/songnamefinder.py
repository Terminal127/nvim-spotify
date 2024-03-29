import spotipy
import os
import json
import sys
from dotenv import load_dotenv

# Suppress stdout and stderr
sys.stdout = open(os.devnull, 'w')
sys.stderr = open(os.devnull, 'w')

# Define your Spotify credentials
load_dotenv()
username = os.getenv('SPOTIFY_USERNAME')
clientID = os.getenv('SPOTIFY_CLIENT_ID')
clientSecret = os.getenv('SPOTIFY_CLIENT_SECRET')
redirect_uri = 'http://localhost:5000/callback'

# Initialize the SpotifyOAuth object
scope = 'user-read-playback-state user-modify-playback-state'
oauth_object = spotipy.SpotifyOAuth(clientID, clientSecret, redirect_uri, scope=scope)

# Get the access token
token_dict = oauth_object.get_access_token()
token = token_dict['access_token']
spotifyObject = spotipy.Spotify(auth=token)
user_name = spotifyObject.current_user()
devices = spotifyObject.devices()

# Restore stdout and stderr
sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__

# Function to search and return a list of song names and artist names
def search_songs(query):
    results = spotifyObject.search(query, 10, 0, "track")
    songs_dict = results['tracks']
    song_items = songs_dict['items']
    songs = []
    for item in song_items:
        song_name = item['name']
        artist_name = item['artists'][0]['name']
        songs.append(f"{song_name} - {artist_name}")
    return songs

if __name__ == "__main__":
    query = " ".join(sys.argv[1:])
    songs = search_songs(query)
    print(json.dumps(songs))

