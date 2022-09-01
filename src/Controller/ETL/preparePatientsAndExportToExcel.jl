function ETL.preparePatientsAndExportToExcel(
    patients::Vector{PatientInSrcDB},
    useCache::Bool,
    dbconn::ODBC.Connection,
    ;filepath = "$(tempname()).xlsx"
)

    patientsPreparedData::Vector{Union{DataFrame,Missing}} = DataFrame[]
    patientsCodeNames = String[]

    for p in patients

        patientCodeName = ICUDYNUtil.getPatientPrettyCodename(
            p.firstname, p.lastname, p.birthdate
        )


        rawDF = ETL.getPatientRawDFFromSrcDB(
            p.srcDBIDs,
            useCache,
            dbconn
        )

        # Export patient raw data to patient dir
        rawDataFilepath  = ICUDYNUtil.getWebserverFilenameForPatientRawData(p)

        ICUDYNUtil.exportToExcel(
            filter(r->begin
                r.attributeDictionaryPropName ∈ [
                    "PtAssessment_VentModeInt.VentModeList",
                    "PtAssessment_O2DeliveryInt.Debit_O2",
                    "PtAssessment_VentModeInt.VentModeList",
                    "PtAssessment_Calcul_seances_VS_sur_tube.Etat",
                    "PtAssessment_Calcul_seances_VS_sur_tube.Duree",
                    "PtAssessment_Volume_minute_lmin.mesure",
                    "PtAssessment_Frequence_respiratoire_par_min.mesuree",
                    "PtAssessment_Fraction_en_oxygene_FiO2.mesure",
                    "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",
                    "PtAssessment_Pression_positive_PEP_cmH2O.mesure"]
                end,
                rawDF)
            ;filepath=rawDataFilepath
        )

        push!(
            patientsPreparedData,
            ETL.processPatientRawHistoryWithFileLogging(rawDF,patientCodeName)
        )

        push!(patientsCodeNames, patientCodeName)

    end

    filter!(x -> !ismissing(x),patientsPreparedData)


    ICUDYNUtil.exportToExcel(
        patientsPreparedData,
        patientsCodeNames
        ;filepath = filepath
    )

end
