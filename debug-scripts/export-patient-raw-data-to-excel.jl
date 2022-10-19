# 1. Nom, prénom, date => ID
# 2. ID => getPatientRawDFFromSrcDB
# 3. Write xlsx => exportToExcel

include("../scripts/using.jl")

firstname = "Yves" 
lastname = "Le Bozec" 
birthdate = Date("1947-02-05")

patientPrettyCodename = ICUDYNUtil.getPatientPrettyCodename(
    firstname, lastname, birthdate) + ".xlsx"

patientID = ETL.getPatientIDsFromSrcDB(
    firstname,
    lastname,
    birthdate)

ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
    rawDF = ETL.getPatientRawDFFromSrcDB(patientID , false, dbconn)
end

rawDataFilepath = joinpath(ICUDYNUtil.getICUDYNTempDir(), patientPrettyCodename)

ICUDYNUtil.exportToExcel(rawDF; filepath=rawDataFilepath)



