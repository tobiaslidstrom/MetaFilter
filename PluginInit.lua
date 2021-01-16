--[[
	do stuff on plugin load.
]]

require 'functions.lua'

-- Namespaces
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrXml = import 'LrXml'
local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrView = import 'LrView'
local LrErrors = import 'LrErrors'
local LrTasks = import 'LrTasks'
local LrDate = import 'LrDate'
local LrMD5 = import 'LrMD5'
local LrPasswords = import 'LrPasswords'
local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

-- Global variables
authorize = nil
authorize_id = LrApplication.macAddressHash()


Plugin = {
	Name = 'MetaFilter',
	metadataXML = LrPathUtils.child(_PLUGIN.path, "/lib/metadata.xml"),
	exiftoolPath = LrPathUtils.child(_PLUGIN.path, "/lib/exiftool/exiftool.exe"),
	errorInfo = 'Please reinstall the plugin or file a bug report.'
}


-- Reverse table order.
-- @param tbl Array.
-- @return array Returns a table.
function table.reverse(tbl)
	local arr = {}
	for i = #tbl, 1, -1 do
		table.insert(arr, tbl[i])
	end
	return arr
end


-- Parses XML data into array.
-- @return Returns an array of XML tags.
function parseXML(xml, id, tag)
	local arr = {}
	local group = {}
	for i = 1, xml:childCount() do
		for j = 1, xml:childAtIndex(i):childCount() do
			if xml:childAtIndex(i):childAtIndex(j):attributes()['id']['value'] == id then
				for k = 1, xml:childAtIndex(i):childAtIndex(j):childCount() do
					group[k] = xml:childAtIndex(i):childAtIndex(j):childAtIndex(k)
				end
			end
		end
		if (type(group) == 'table') then
			if (tag == 'groups') then
				return #group
			else
				for i = 1, #group do
					if (tag == 'group_title') then
						table.insert(arr, tostring(group[i]:childAtIndex(1):childAtIndex(1):text()))
					elseif (tag == 'group_items') then
						table.insert(arr, tostring(group[i]:childAtIndex(2):childCount()))
					else
						for j = 1, group[i]:childAtIndex(2):childCount() do
							local items = group[i]:childAtIndex(2):childAtIndex(j)
							if (tag == 'name') then
								table.insert(arr, tostring(items:name()))
							elseif (tag == 'text') then
								table.insert(arr, tostring(items:text()))
							else
								table.insert(arr, tostring(items:attributes()[tag]['value']))
							end
						end
					end
				end
				return arr
			end
		end
	end
	return false
end

-- Array of export settings.
-- @param tbl Array of propertyTable.
-- @return table Array of export setting keys and values.
function exportSettings(tbl)
	local arr = {}
	for key,val in pairs(tbl) do
		for tbl_key,tbl_val in pairs(tbl[key]) do
			if not (string.sub(tostring(tbl_key), 1, 3) == 'LR_' or string.sub(tostring(tbl_key), 1, 3) == 'ALL') then
				table.insert(arr, tostring(tbl_key) .. '=' .. tostring(tbl_val))
			end
		end
	end
	return arr
end


function DebugWindow(msg)
	LrDialogs.message(Plugin.Name .. ' Debug', msg)
end

