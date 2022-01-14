function loadConf end

function getConf end

function getDataDir end

function getDataInputDir end

function getDataOutputDir end

function getICUDYNTempDir end

function getICUDYNTempFile end

function getETLAIntegrerDir end

function blindBakeIsRequired end

function getWindowSize end

function getWindowUnit end

"""
    Renvoie le chemin du dossier contenant les fichiers zip déjà intégrés
"""
function getETLDejaIntegreDir end

function getMissingFilePath end

function getETLMaxSizeBeforeDBCommit end

function getETLTnterruptionFilepath end

"""
Renvoie la timezone de l'application.

Invoquée sans argument, renvoie la timezone instanciée par rapport au nom
  (Exemple : 'Europe/Paris').

Invoquée avec une date, renvoie une time zone sous la forme d'un shift par
rapport à l'UTC (Exemple : 'UTC+1').
"""
function getTimeZone end

function openDBConn end
function openDBConnAndBeginTransaction end
function beginDBTransaction end
function commitDBTransaction end
function rollbackDBTransaction end
function closeDBConn end

function json2Entity end

function initialize_http_response_status_code end

function sendemail end

function prepareDataFrameForExcel! end

function exportToExcel end

function formatDate end

function formatDateTime end

function formatDate end

function formatDateTime end

function formatExceptionAndStackTrace end

function formatExceptionAndStackTraceCore end

function convertStringToBool end

function convertStringToDate end

function convertStringOfTimeWithHoursPassed24HoursTo1970DateTime end

function convertStringOfTimeToSeconds end

function convertStringToDateTime end

# eg. "1970-01-01T12:35:00+01:00"
function convertStringToZonedDateTime end

# Returns the path of the temp directory containing the unziped files
function unzipFileInTempDir end

function readdirWithFullpath end

function extension end

function diffInSecondsAsInt end

function timeDiffInGivenUnit end

function nowInCurrentTimeZone end

function nowInUTC end

# TODO: We should manage to specify that the datatype is an Enum
function listEnums end

function hasRole end

function addTimeToZonedDateTime end

function addTimeToDate end

function getDateOfZonedDateTime end

function agregerEnStringJSON end

function openDBConnectionAndExecuteQuery end

function fusionColumnsInNewColum! end

function ajouterCol_course_id! end

function addPrefixToColNames! end

function getFileFullPath end

function cancelFile! end
function replaceMissingsBy0s! end

function createTablePartition end
function createAllTablesPartitionsIfNextYearIsClose end
function createAllTablesPartitions end
function tableOrPartitionExists end
function getTablesPartitionnees end
function getTables end
function getTablePartitionName end
function vacuumAndReindexTablesPartitionnees end

function getCurrentFrontendVersion end

function createZip end

function overwriteConfForPrecompilation end
function restoreConfAfterPrecompilation end

function setToMissing end

function cutAt end

function isMissing end

function prepareDataFrameForExcel! end
function exportToExcel end
