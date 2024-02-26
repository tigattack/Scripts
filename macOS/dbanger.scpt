-- Please don't look at this, it's horrible.

-- Delay handler func
on delay duration
	do shell script "/bin/sleep " & duration
end delay

set jqCmd to "/opt/homebrew/bin/jq"

set daynum to (do shell script "cat ~/dbanger.txt")
set dailyBangers to "_tig's Occasional Bangers " & daynum & "._ <https://open.spotify.com/playlist/3eGUeJSesiyuTp3hvPZc0P>"

set lfmCurrentTrack to do shell script "curl -sX GET -G http://ws.audioscrobbler.com/2.0 -d 'method=user.getrecenttracks' -d 'user=tigattack' -d 'api_key=LFM_API_KEY_HERE' -d 'format=json' | " & jqCmd & " -r '.recenttracks.track[] | select(.[\"@attr\"].nowplaying == \"true\") | \"\\(.artist.\"#text\") - \\(.name)\"'"

if length of lfmCurrentTrack is equal to 0 then
	set dialogText to "LFM scrobbling broken? No current track found."
	set dialogAnswer to the button returned of (display dialog dialogText buttons {"Cancel"} default button "Cancel" cancel button "Cancel")
else
	set dialogText to "Current track is " & lfmCurrentTrack & ".

Add the track to \"tig's Shared Bangers\" to check for dupe, then confirm."
	set dialogAnswer to the button returned of (display dialog dialogText buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel")
end if

if dialogAnswer is "OK" then
	tell application "Discord Canary" to activate
	-- Switch to #music channel in Homelab
	tell application "System Events" to keystroke "k" using command down
	delay 1
	tell application "System Events" to keystroke "music homelab"
	delay 0.5
	tell application "System Events" to keystroke return
	delay 1.5
	-- Trigger Last.FM embed from bot
	tell application "System Events" to keystroke "^fmm" & return
	
	delay 3.5
	
	tell application "Discord Canary" to activate
	tell application "System Events"
		-- Delete ^fmm message
		-- Up
		key code 126
		-- Backspace
		key code 51
		key code 51
		key code 51
		key code 51
		-- Submit
		keystroke return
		-- Confirm deletion prompt
		keystroke return
		delay 1
		
		-- Post bangers message defined above
		keystroke dailyBangers & return
	end tell
	
	--delay 3.5
	-- Return to previous channel
	--tell application "System Events" to keystroke "k" using command down
	--delay 0.5
	--tell application "System Events" to keystroke return
	
	-- Bump dbanger number
	set nextnum to daynum + 1 as text
	do shell script "echo " & quoted form of nextnum & " > ~/dbanger.txt"
end if
