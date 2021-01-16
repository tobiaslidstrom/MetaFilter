--[[
	comments
]]

local function sectionsForTopOfDialog( f )
	return {
		{
			title = Plugin.Name,
			f:row {
				spacing = f:control_spacing(),
				f:static_text {
					title = Plugin.Name .. ' gives you control over how to handle all metadata during exports.\nDeveloped by Tobias Lidström.',
					fill_horizontal = 1
				}
			}
		}
	}
end

return {
	sectionsForTopOfDialog = sectionsForTopOfDialog
}