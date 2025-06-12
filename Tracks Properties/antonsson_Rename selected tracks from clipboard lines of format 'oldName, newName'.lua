-- @description Rename selected tracks from clipboard lines of format 'oldName, newName'
-- @author Egill Antonsson
-- @version 0.0.2
-- @changelog: Fixed script to work as expected
-- @about
--   # Rename selected tracks from clipboard lines of format 'oldName, newName'
--
--   The script will find to the 'newName' where the 'oldName' is found.
--   I used cfillion's script Rename selected tracks from clipboard lines as a starting point. Thanks bro :)
--   
--   ## The input format
--   The input should be in the CVS format 'oldName, newName' (without a header line)
--   
--   ### Example:
--   Egill_says_goodbye, Egill_says_hello
--   Egill_said_some_old_stuff, Egill_says_some_new_stuff
--
-- @tags: utility, tracks
-- @license: MIT (Do whatever you like with this code)

local script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")
local UNDO_STATE_TRACKCFG = 1
local ctx = reaper.ImGui_CreateContext('my context')
local clipboard = reaper.ImGui_GetClipboardText(ctx)
if clipboard:len() < 1 or reaper.CountSelectedTracks(0) < 1 then
  reaper.defer(function() end) -- no undo point
end
reaper.Undo_BeginBlock()
reaper.ClearConsole()
local function trim(s)
    return s:match "^%s*(.-)%s*$"
end
for line in clipboard:gmatch("([^\r\n]*)[\r\n]*") do
  local oldName = ""
  local newName = ""
  local count = 1
  for word in string.gmatch(line, "([^,]+)") do
      if(count == 1) then
        oldName = trim(word)
      end
      if(count == 2) then
        newName =  trim(word)
      end
      count = count + 1
  end

  index = 0
  local activeProject = 0
  while (index ~= -1) do
	local track = reaper.GetSelectedTrack(activeProject, index)
	if not track then
		index = -1
		break
	end
	success, trackName = reaper.GetTrackName(track)
	if (trackName == oldName) then
		reaper.ShowConsoleMsg("Renamed track from '" .. oldName .. "' to '" .. newName .. "'\n")
		reaper.GetSetMediaTrackInfo_String(track, 'P_NAME', newName, true)
	end
	index = index + 1
  end
end
reaper.Undo_EndBlock(script_name, UNDO_STATE_TRACKCFG)
