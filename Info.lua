--[[
	MetaFilter v1.1
	Copyright (c) 2010-2020 by Tobias Lidström
]]

return {
	LrSdkVersion = 9.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'com.nerdized.lightroom.export.MetaFilter',
	LrPluginName = 'MetaFilter',
	LrPluginInfoUrl = 'https://github.com/TobiasLidstrom/MetaFilter/',
	VERSION = {
		major=1, minor=1
	},
	LrInitPlugin = 'PluginInit.lua',
	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	--LrExportServiceProvider = {
		--title = 'MetaFilter',
		--file = 'ExportServiceProvider.lua'
	--},
	LrExportFilterProvider = {
		title = 'Metadata Filter',
		id = 'MetaFilter.MetadataFilter',
		file = 'MetadataFilter.lua'
	}
}