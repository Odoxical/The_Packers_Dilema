extends AudioStreamPlayer
var track_to_play = 1



#Music names and files
enum MusicTracks {Track1, Track2, Track3, Track4, Track5}
var Music_Tracks = {MusicTracks.Track1:preload("res://Audio/Music/Diagetic/Old Amnesia.mp3"), MusicTracks.Track2:preload("res://Audio/Music/Diagetic/Old Airport 1_4.mp3"), MusicTracks.Track3:preload("res://Audio/Music/Diagetic/Old airport 2_4.mp3"), MusicTracks.Track4:preload("res://Audio/Music/Diagetic/Old Airport 3_4.mp3"), MusicTracks.Track5:preload("res://Audio/Music/Diagetic/Airline Old 4_4.mp3")}
# Called when the node enters the scene tree for the first time.
func _ready():
	track_to_play = randi_range(1,5)
	if track_to_play == 1:
		play(MusicTracks.Track1) 
	if track_to_play == 2:
		play(MusicTracks.Track2) 
	if track_to_play == 3:
		play(MusicTracks.Track3) 
	if track_to_play == 4:
		play(MusicTracks.Track4) 
	if track_to_play == 5:
		play(MusicTracks.Track5) 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
