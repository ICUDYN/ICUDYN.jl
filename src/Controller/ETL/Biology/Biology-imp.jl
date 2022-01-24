function ETL.Biology.computeBiologyVars(window::DataFrame)

    prefiltered = window |>
        n -> filter(x -> startswith(x,"PtLabResult_"),n) |>
        n -> filter(x -> !isnothing(match(r"\d", x)),n)


        molecules = Dict(
            :lactate => r"PtLabResult_Acide lactique",
            :uric_acid => r"PtLabResult_Acide urique",
            :alat => r"PtLabResult_ALAT \(TGP\)",
            :albumin => r"PtLabResult_Albumine \(CR_IOAL_V1_HEG\)",
            :ammonia => r"PtLabResult_Ammoniémie \(CR_SAMM_VV_EDT\)",
            :asat => r"PtLabResult_ASAT \(TGO\)",
            :bilirubin => r"PtLabResult_Bilirubine totale",
            :blasts => r"PtLabResult_Blastes \(HC_FBLA_VV_EDT\)",
            :bnp => r"PtLabResult_Brain Natriuretic Peptide (BNP)",
            :calcium => r"PtLabResult_Calcium",
            :calcium_i => r"PtLabResult_Calcium ionisé",
            :chloremia => r"PtLabResult_Chlore",
            :cholesterol => r"PtLabResult_Cholestérol total (CR_LCHO_VV_HEG)",
            :transferin_iron_saturation => r"PtLabResult_Coefficient de saturation en fer de la transferrine \\(CH_FCSR_VV",
            :cpk => r"PtLabResult_CPK (CR_CCPK_V1_HEG)",
            :creat => r"PtLabResult_Créatinine",
            :crp => r"PtLabResult_CRP (CR_SCRP_VV_HEG)",
            :d_dimers => r"PtLabResult_D-Dimères (exclusion EP + TVP) (HH_DDVD_VV_CIT)",
            :ethanol => r"PtLabResult_Ethanol",
            :factor5 => r"PtLabResult_Facteur V",
            :fibrinogen => r"PtLabResult_Fibrinogène",
            :glucosoria_gram_per_l => r"PtLabResult_Glucose (CR_UGLL_VV_URI)",
            :glycemia_gram_per_l => r"PtLabResult_Glycémie sanguine",
            :aptoglobin => r"PtLabResult_Haptoglobine",
            :bicarbonate => r"PtLabResult_HCO3 artériel",
            :red_blood_cells => r"PtLabResult_Hématies",
            :hematocrite => r"PtLabResult_Hématocrite",
            :hemoglobin => r"PtLabResult_Hémoglobine",
            :heparinemia => r"PtLabResult_Héparinémie (HNF/HBPM) (HH_HEPA_VV_CIT)",
            :inr => r"PtLabResult_INR",
            :ldh => r"PtLabResult_Lactico-déshydrogénase (LDH)",
            :white_blood_cells => r"PtLabResult_Leucocytes (Giga/L)",
            :lipase => r"PtLabResult_Lipase",
            :magnesium => r"PtLabResult_Magnésium",
            :natriuria => r"PtLabResult_Natriurie",
            :osmolality => r"PtLabResult_Osmolalité",
            :alkaline_phosphatase => r"PtLabResult_Phosphatases alcalines",
            :arterial_pco2 => r"PtLabResult_pCO2 artériel",
            :ph => r"PtLabResult_pH artériel",
            :phosphoremia => r"PtLabResult_Phosphore",
            :plaquettes => r"PtLabResult_Plaquettes (Giga/L)",
            :neutrophils => r"PtLabResult_Polynucléaires neutrophiles (Giga/L)",
            :arterial_po2 => r"PtLabResult_pO2 artériel",
            :potassium_gaz => r"PtLabResult_Potassium (CD_GKXX_VV_GZA)",
            :potassium_blood => r"PtLabResult_Potassium (mmol/l)",
            :procalcitonin => r"PtLabResult_Procalcitonine",
            :proteinuria => r"PtLabResult_Protéines (CR_UPTL_VV_URI)",
            :proteins => r"PtLabResult_Protéines sériques \(CP_EPRO_VV_SER\)|PtLabResult_Protides (g/l)",
            :alcalin_reserve => r"PtLabResult_Réserve Alcaline",
            :sao2 => r"PtLabResult_SaO2", # supprimé parce que pas assez renseigné
            :natremia => r"PtLabResult_Sodium \(CD_GNAX_VV_GZA\)|PtLabResult_Sodium \(mmol/l\)",
            :prothrombin_time => r"PtLabResult_Taux de prothrombine (TP)",
            :troponin => r"PtLabResult_Troponine",
            :urea_blood => r"PtLabResult_Urée",
            :urea_urin => r"PtLabResult_Urée urinaire"
        )
    
end


function ETL.Biology.computeCreatinine(window::DataFrame) 

end


function ETL.Biology.computeUrea(window::DataFrame)

end