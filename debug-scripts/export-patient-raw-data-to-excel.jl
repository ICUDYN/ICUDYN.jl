# 1. Nom, prénom, date => ID
# 2. ID => getPatientRawDFFromSrcDB
# 3. Write xlsx => exportToExcel

include("../scripts/using.jl")

firstname = "Yves"
lastname = "Le Bozec"
birthdate = Date("1947-02-05")

patientPrettyCodename = ICUDYNUtil.getPatientPrettyCodename(
    firstname, lastname, birthdate) * ".xlsx"

patientIDs = ETL.getPatientIDsFromSrcDB(
    firstname,
    lastname,
    birthdate)


rawDF = ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
    ETL.getPatientRawDFFromSrcDB(patientIDs , false, dbconn)
end

rawDataFilepath = joinpath("tmp", patientPrettyCodename)

ICUDYNUtil.exportToExcel(rawDF; filepath=rawDataFilepath)
