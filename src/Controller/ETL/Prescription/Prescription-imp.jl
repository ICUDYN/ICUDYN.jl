function ETL.Prescription.computePrescriptionBaseVars(window::DataFrame)
    
    molecules = Dict(

        #
        # Amine agents
        #
        :norepinephrine => r"PtMedication_Norepinephrine",
        :epinephrine => r"PtMedication_epinephrine",
        # Dobutamine is present in the data in unit gamma (i.e. micro gram) per kg per min
        :dobutamine => r"dobutamine", attributeDictionaryPropNameForDrip => r"PtMedication_dripAdmIntervention.formularyAdditiveWtDoseRate",
    
        #
        # Sedative agents    
        #
        :midazolam => r"midazolam",
        :sufentanyl => r"sufenta",
        :propofol => r"propofol",
        :clonidine => r"clonidine",
        
        #
        # Blocking agents, Induction agents
        #
        :cisatracurium => r"PtMedication_Cisatracurium",
        :atracurium => r"PtMedication_Atracurium",
        :rocuronium => r"PtMedication_Rocuronium",
        :etomidate => r"Etomidate|Hypnomidate",
        :celocurine => r"Celocurine",
        
        #
        # Anticoagulant
        #
        :heparine => r"Heparine",
        :enoxaparine => r"enoxaparine|lovenox",
        :innohep => r"innohep|tinzaparine",
        :fraxiparine => r"Fraxiparine|Nadroparine",
        :fragmine => r"Fragmine|Dalteparine",
        :calciparine => r"Calciparine",
        :naco => r"PtMedication_Naco|apixaban|eliquis|pradaxa|dabigatran|xarelto|rivaroxaban",
        :coumadine => r"coumadine|warfarine|previscan|fluindione|sintrom|acenocoumarole",
        
        # 
        # Antiplatelet
        #
        :aspirine1 => r"aspirine|aspegic|kardegic|ticlid|ticlopidine", # PROBLEM
        :aspirine2 => r"efient|prasugrel|plavix|clopidogrel|brilique|ticagrélor", # PROBLEM
        
        #
        # Insuline
        #
        :insuline => r"Insuline",
        
        #
        # Antibiotics
        #
        :cefepime => r"Cefepime|Axepim",
        :amikacine => r"Amikacine|amiklin",
        :cefotaxime => r"Cefotaxime|claforan",
        :ceftazidime => r"Ceftazidime|fortum",
        :imipenem => r"Imipenem|tienam",
        :meropenem => r"Meropenem|meronem",
        :vancomycine => r"Vancomycine",
        :linezolide => r"Linezolide|zyvoxid",
        :colimycine => r"Colimycine|colistine",
        :piperacilline => r"piperacilline",
        :tazocilline => r"Tazocilline|tazobactam", # PROBLEM
        :amoxicilline => r"Amoxicilline|clamoxyl",
        :dalacine => r"Dalacine|Clindamycine",
        :ceftriaxone => r"Ceftriaxone|Rocephine",
        :metronidazole => r"Metronidazole|flagyl",
        :sulfamethoxazole => r"Sulfamethoxazole|Bactrim|Cotrimoxazole",
        :oxacilline => r"oxacilline|bristopen",
        :gentamicine => r"gentamicine|gentalline",
        
        #
        # Antifungal
        #
        :caspofungine => r"Caspofungine|Cancidas",
        :voriconazole => r"Voriconazole|vfend",
        :echinocandine => r"Echinocandine|mycamine|mycafungin",
        :ambisome => r"Ambisome|Amphotericine",
        :fluconazole => r"Fluconazole|triflucan",
        
        #
        # Anti-hypertensive_agent
        #
        :urapidil => r"Urapidil|eupressyl",
        :nicardipine => r"Nicardipine|loxen",
        :labetalol => r"Labetalol|Trandate",
        :risordan => r"Risordan|trinitrine",
        
        #
        # Diuretic_agent
        #
        :furosemide => r"Furosemide|Frusemide|Lasilix",
        
        #
        # Steroids
        #
        :steroids => r"Prednisolone|prednisone|solumedrol|solupred|hydrocortisone",
        :hydrocortisone => r"hydrocortisone|HSHC",
        
        #
        # Temperature_mgt_agent
        #
        :paracetamol => r"Paracetamol|dafalgan|dafalgan|efferalgan|perfalgan",
        
        #
        # Analgesic
        #
        :morphine => r"Morphine",
        :nefopam => r"Nefopam|Acupan",
        
        #
        # Arrhythmia
        #
        :cordarone => r"Cordarone|tildiem|diltiazen|amiodarone")

    
    return missing
end


function ETL.Prescription.computeAmineAgentsAdditionalVars(
    window::DataFrame,
    norepinephrineMeanMgHeure, 
    epinephrineMeanMgHeure, 
    dobutamineMeanGammaKgMinute,
    weightAtAdmission)

    norepinephrineStatus = epinephrineStatus = dobutamineStatus = missing
    norepinephrineMeanGammaKgMinute = epinephrineMeanGammaKgMinute = missing
    amineAgent = false

    if !ismissing(weightAtAdmission) && isa(weightAtAdmission, Number)
        
        #Norepinephrine
        if !ismissing(norepinephrineMeanMgHeure) && isa(norepinephrineMeanMgHeure, Number)
            norepinephrineMeanGammaKgMinute = round((norepinephrineMeanMgHeure * 1000 / weightAtAdmission / 60), digits=2)
            println("norepinephrineMeanGammaKgMinute : $norepinephrineMeanGammaKgMinute")
            
            if norepinephrineMeanGammaKgMinute < 0.5
                println("LOW")
                norepinephrineStatus = "LOW"
            elseif 0.5 <= norepinephrineMeanGammaKgMinute && norepinephrineMeanGammaKgMinute < 1
                println("HIGH")
                norepinephrineStatus = "HIGH"
            elseif 1 <= norepinephrineMeanGammaKgMinute
                println("VERY HIGH")
                norepinephrineStatus = "VERY_HIGH"
            end
        end
        
        #Epinephrine
        if !ismissing(epinephrineMeanMgHeure) && isa(epinephrineMeanMgHeure, Number)            
            epinephrineMeanGammaKgMinute = round((epinephrineMeanMgHeure * 1000 / weightAtAdmission / 60), digits = 2)
            println("epinephrineMeanGammaKgMinute : $epinephrineMeanGammaKgMinute")
            
            if epinephrineMeanGammaKgMinute < 0.5
                println("LOW")
                epinephrineStatus = "LOW"
            elseif 0.5 <= epinephrineMeanGammaKgMinute && epinephrineMeanGammaKgMinute < 1
                println("HIGH")
                epinephrineStatus = "HIGH"
            elseif 1 <= epinephrineMeanGammaKgMinute
                println("VERY HIGH")
                epinephrineStatus = "VERY_HIGH"
            end
        end
    end

    #
    # Dobutamine
    #
    # NOTE: The variable is already present in the data in unit gamma (i.e. micro gram) per kg per min
    if !ismissing(dobutamineMeanGammaKgMinute) && isa(dobutamineMeanGammaKgMinute, Number)
        if dobutamineMeanGammaKgMinute < 10
            println("LOW")
            dobutamineStatus = "LOW"
        elseif 10 <= dobutamineMeanGammaKgMinute
            println("HIGH")
            dobutamineStatus = "HIGH"
        end
    end
    #
    # Amine agent (bool)
    #
    if (!ismissing(norepinephrineMeanMgHeure)
        && !ismissing(epinephrineMeanMgHeure)
        && !ismissing(dobutamineMeanGammaKgMinute))
        println("amineAgent : true")
        
        amineAgent = true
    end


    return Dict(
        :norepinephrineStatus => norepinephrineStatus,
        :norepinephrineMeanGammaKgMinute => norepinephrineMeanGammaKgMinute,
        :epinephrineStatus => epinephrineStatus,
        :epinephrineMeanGammaKgMinute => epinephrineMeanGammaKgMinute,
        :dobutamineStatus => dobutamineStatus,
        :amineAgent => amineAgent
    )
end


function ETL.Prescription.computeSedativeAgentsOtherVars(window::DataFrame)
    
    isofluraneStatus = missing

    isofluraneExpiratoryFractionMean = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_ISO_fe__ISO_in.ISO_fe",
        n->round(mean(n), digits = 2))

    # Suppression des artefacts hors range
    if !ismissing(isofluraneExpiratoryFractionMean) && isa(isofluraneExpiratoryFractionMean, Number)
        if isofluraneExpiratoryFractionMean >= 5
            isofluraneExpiratoryFractionMean = missing
        end
    end

    if !ismissing(isofluraneExpiratoryFractionMean) && isa(isofluraneExpiratoryFractionMean, Number)
        if isofluraneExpiratoryFractionMean < 0.5
          isofluraneStatus = "LOW"
        elseif 0.5 <= isofluraneExpiratoryFractionMean && isofluraneExpiratoryFractionMean < 1
            isofluraneStatus = "NORMAL"
        else
            isofluraneStatus = "HIGH"
        end
    end



    anacondaDebitMean = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Anaconda.Rglage_dbit",
        n->round(mean(n), digits = 2))


    return Dict(
        :isofluraneExpiratoryFractionMean => isofluraneExpiratoryFractionMean,
        :isofluraneStatus => isofluraneStatus,
        :anacondaDebitMean => anacondaDebitMean
    )



end