import spotipy
import webbrowser
import os
import json
import sys
from dotenv import load_dotenv


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

sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__

# Function to search and play a song
def search_and_play(song_name):
    results = spotifyObject.search(song_name, 2, 0, "track")
    songs_dict = results['tracks']
    song_items = songs_dict['items']
    if not song_items:
        print("No results found for the given song name.")
        return
    song = song_items[0]['external_urls']['spotify']
    device_id = "6a2ebc31f406670ec1756affe94fc0b9510bbe4e"
    spotifyObject.start_playback(device_id=device_id, uris=[song])
    print(f'Starting playback on the specified device ({device_id}).')

if __name__ == "__main__":
    import sys
    song_name = " ".join(sys.argv[1:])
    print (song_name)
    search_and_play(song_name)
