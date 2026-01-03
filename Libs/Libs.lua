local addonName, addon = ...;
addon.Libs = {};
local libs = addon.Libs;

libs.AceLocale = "AceLocale-3.0";

addon.Util = LibStub("Krowi_Util-1.0");
addon.Metadata = addon.Util.Metadata.GetAddOnMetadata(addonName);

error([["Krowi_* libraries need to be converted to modules and cannot be included directly anymore. 
Please remove Krowi_* from your Libs folder and add them as modules instead. 
Remove this line after converting the libraries to modules."]]);