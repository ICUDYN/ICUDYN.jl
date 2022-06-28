function preparePatientsCurrentlyInUnitAndExportToExcel end
function preparePatientsAndExportToExcel end

function getPatientRawDFFromSrcDB end
function getPatientsCurrentlyInUnitFromSrcDB end
function getPatientIDsFromSrcDB end
function getPatientBasicInfoFromSrcDB end
function cutPatientDF end
function initializeWindow end
function refineWindow1stPass! end
function refineWindow1stPass end
function refineWindow2ndPass! end
function processPatientRawHistory end
function processPatientRawHistoryWithFileLogging end
function combineRefinedWindows end
function enrichResultsOfRefiningModule! end
function getRefiningFunctions end
function get1stPassRefiningFunctions end
function get2ndPassRefiningFunctions end
function orderColmunsOfRefinedHistory! end
function updateCache! end
function getCachedVariable end
function refreshCache! end
function enrichModuleResultWithFunctionResult! end
function enrichWindowModulesResultsWith2ndPassFunctionResult! end


# Deprecated
function preparePatientsFromRawExcelFile end
function getPatientDFFromExcel end
