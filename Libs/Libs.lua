local addonName, addon = ...;
addon.Libs = {};
local libs = addon.Libs;

libs.AceLocale = "AceLocale-3.0";

addon.Util = LibStub("Krowi_Util-1.0");
addon.Metadata = addon.Util.Metadata.GetAddOnMetadata(addonName);