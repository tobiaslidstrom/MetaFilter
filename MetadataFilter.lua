--[[
	comments
]]

require 'PluginInit.lua'

local LrView = import 'LrView'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrXml = import 'LrXml'
local LrErrors = import 'LrErrors'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrDate = import 'LrDate'
local LrMD5 = import 'LrMD5'
local LrBinding = import 'LrBinding'
local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

local bind = LrView.bind
local MetadataFilter = {}
local xml = LrXml.parseXml(LrFileUtils.readFile(Plugin.metadataXML))

local row1_groups = parseXML(xml, '1', 'groups')
local row1_group_title = parseXML(xml, '1', 'group_title')
local row1_group_items = parseXML(xml, '1', 'group_items')
local row1_name = parseXML(xml, '1', 'name')
local row1_text = parseXML(xml, '1', 'text')
local row1_arg = parseXML(xml, '1', 'arg')

local row2_groups = parseXML(xml, '2', 'groups')
local row2_group_title = parseXML(xml, '2', 'group_title')
local row2_group_items = parseXML(xml, '2', 'group_items')
local row2_name = parseXML(xml, '2', 'name')
local row2_text = parseXML(xml, '2', 'text')
local row2_arg = parseXML(xml, '2', 'arg')


--visible = LrBinding.keyIsNot('LR_embeddedMetadataOption', 'copyrightOnly')

-- Checks for errors
function sanityCheck(propertyTable)
	local message = nil

	if propertyTable.LR_embeddedMetadataOption ~= 'all' then
		message = "Incorrect metadata value."
	end

	--if authorize == nil then
	--	message = "Trial has ended. Please purchase a license to continue using this plugin, thank you!"
	--end

	--DebugWindow('bah status: ' .. prefs.settings['exportLimit'])

	-- Show error message and disable Export button
	if message then
		propertyTable.message = message
		propertyTable.LR_cantExportBecause =  message
	else
		propertyTable.message = nil
		propertyTable.LR_cantExportBecause = nil
	end
end

-- Run on Export dialog load
function MetadataFilter.startDialog(propertyTable)
	propertyTable:addObserver('LR_embeddedMetadataOption', sanityCheck)

	-- Run sanity check on Export dialog
	sanityCheck(propertyTable)
end



MetadataFilter.exportPresetFields = {
	{ key = 'metadata_strip', default = false }
}
for i = 1, #row1_name do
	table.insert(MetadataFilter.exportPresetFields, { key = tostring('metadata_row1_' .. row1_name[i]), default = true })
end
for i = 1, #row2_name do
	table.insert(MetadataFilter.exportPresetFields, { key = tostring('metadata_row2_' .. row2_name[i]), default = true })
end

function MetadataFilter.sectionForFilterInDialog(viewFactory, propertyTable)
	local size = 0
	local arr = {}
	local row1 = {}
	local row2 = {}
	local col_row1 = {}
	local col_row2 = {}
	prefs.metadata = {}

	for i = 1, #row1_name do
		prefs.metadata['row1_' .. row1_name[i]] = row1_arg[i]
	end
	for i = 1, #row2_name do
		prefs.metadata['row2_' .. row2_name[i]] = row2_arg[i]
	end
	for i = 1, row1_groups do
		for j = 1, #row1_name do
			row1[j] = viewFactory:checkbox {
				title = row1_text[j],
				value = bind (tostring('metadata_row1_' .. row1_name[j])),
				width_in_chars = 35,
				enabled = bind {
					key = 'metadata_strip',
					transform = function(value, fromTable)
						if propertyTable.metadata_strip == false then
							return true
						else
							return false
						end
					end
				}
			}
		end
		size = size + tonumber(row1_group_items[i])
		for k = 1, #row1 do
			begin = size - (tonumber(row1_group_items[i]) - 1)
			if (k >= begin and k <= size) then
				table.insert(arr, row1[k])
			end
		end
		col_row1[i] = viewFactory:column {
			viewFactory:row {
				viewFactory:group_box {
					title = row1_group_title[i],
					viewFactory:row {
						spacing = viewFactory:control_spacing(),
						viewFactory:column(arr)
					}
				}
			},
			viewFactory:row {
				viewFactory:spacer {
					height = 10
				}
			}
		}
	end
	local size = 0
	local arr = {}
	for i = 1, row2_groups do
		for j = 1, #row2_name do
			row2[j] = viewFactory:checkbox {
				title = row2_text[j],
				value = bind (tostring('metadata_row2_' .. row2_name[j])),
				width_in_chars = 35,
				enabled = bind {
					key = 'metadata_strip',
					transform = function(value, fromTable)
						if propertyTable.metadata_strip == false then
							return true
						else
							return false
						end
					end
				}
			}
		end
		size = size + tonumber(row2_group_items[i])
		for k = 1, #row2 do
			begin = size - (tonumber(row2_group_items[i]) - 1)
			if (k >= begin and k <= size) then
				table.insert(arr, row2[k])
			end
		end
		col_row2[i] = viewFactory:column {
			viewFactory:row {
				viewFactory:group_box {
					title = row2_group_title[i],
					viewFactory:row {
						spacing = viewFactory:control_spacing(),
						viewFactory:column(arr)
					}
				}
			},
			viewFactory:row {
				viewFactory:spacer {
					height = 10
				}
			}
		}
	end

	return {
		title = Plugin.Name,
		viewFactory:row {
			spacing = viewFactory:control_spacing(),
			viewFactory:static_text {
				title = 'Select the metadata you wish to be included in the exported images.\n\nNote: Some of the metadata options may not be available in the original images and therefore will not be included in the exported images.',
				wrap = true,
				width_in_chars = 60,
				height_in_lines = 4
			}
		},
		viewFactory:row {
			viewFactory:separator {
				fill_horizontal = 1
			}
		},
		viewFactory:row {},
		viewFactory:row {
			spacing = viewFactory:control_spacing(),
			viewFactory:static_text {
				title = "Metadata Options",
				font = "<system/small/bold>"
			}
		},
		viewFactory:row {
			spacing = viewFactory:control_spacing(),
			viewFactory:checkbox {
				title = 'Strip all Metadata',
				value = bind 'metadata_strip'
			}
		},
		viewFactory:row {},
		viewFactory:row {
			spacing = viewFactory:control_spacing(),
			viewFactory:column(col_row1)
		},
		viewFactory:row {},
		viewFactory:row {
			spacing = viewFactory:control_spacing(),
			viewFactory:column(col_row2)
		},
		viewFactory:row {
			viewFactory:spacer {
				height = 30
			}
		}
	}
end

function MetadataFilter.postProcessRenderedPhotos(functionContext, filterContext)
	local renditionOptions = {
		plugin = _PLUGIN,
		renditionsToSatisfy = filterContext.renditionsToSatisfy,
		filterSettings = function(renditionToSatisfy, exportSettings)
		end
	}
	local settings = exportSettings(filterContext.propertyTable)

	for sourceRendition, renditionToSatisfy in filterContext:renditions(renditionOptions) do
		local success = sourceRendition:waitForRender()
		if success then
			local dest_file = sourceRendition.destinationPath

			local arr = {}
			local arg = {}

			for key,val in pairs(settings) do
				local option = string.split(val, '=')
				local value = tostring(prefs.metadata[string.sub(option[1], 10)])
				if (option[1] == 'metadata_strip') then
					if (option[2] == 'true') then
						arr = {}
						break
					end
				else
					if (option[2] == 'true') then
						table.insert(arr, value)
					elseif (option[2] == 'false') then
						if not (string.find(value, ':all', 1, true)) then
							table.insert(arr, string.gsub(value, ' ', '= ') .. '=')
						end
					end
				end
			end
			if (#arr > 0) then
				for i = 1, #arr do
					if not (string.find(arr[i], '=', 1, true)) then
						table.insert(arg, '--' .. string.gsub(arr[i], ' ', ' --'))
					else
						table.insert(arg, '-' .. string.gsub(arr[i], ' ', ' -'))
					end
				end
			end

			local arg = table.concat(arg, ' ')
			local cmd_rewrite = Plugin.exiftoolPath .. ' -overwrite_original -all= ' .. arg .. ' ' .. dest_file

			if not (LrTasks.execute(cmd_rewrite) == 0) then
				renditionToSatisfy:renditionIsDone(false, 'Error writing metadata to file.')
			end
		end
	end
end

if not LrFileUtils.exists(Plugin.metadataXML) then
	LrErrors.throwUserError('Metadata XML could not be found.\n\n' .. Plugin.errorInfo)
elseif not LrFileUtils.exists(Plugin.exiftoolPath) then
	LrErrors.throwUserError('Exiftool could not be found.\n\n' .. Plugin.errorInfo)
end

return MetadataFilter