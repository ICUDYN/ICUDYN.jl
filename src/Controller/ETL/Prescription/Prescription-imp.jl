function ETL.Prescription.computePrescriptionBaseVars(window::DataFrame)
    
    dict = Dict{Symbol,Any}()
    prefiltered = window |>
        n -> filter(x -> startswith(x.attributeDictionaryPropName,"PtMedication_"),n) |>
        n -> filter(x -> isa(x.terseForm, Number), n)

    println(prefiltered.terseForm)


    #TODO Bapt : regex "accent insensitive" pour les molécules ?
    #ou on ajoute les version avec et sans accent dans la regex ?
    molecules = Dict(

        #
        # Amine agents
        #
        :norepinephrine => r"PtMedication_Norepinephrine",
        :epinephrine => r"PtMedication_epinephrine",
        # Dobutamine is present in the data in unit gamma (i.e. micro gram) per kg per min
        :dobutamine => (
            regex =  r"dobutamine", 
            attributeDictionaryPropNameForDrip = r"PtMedication_dripAdmIntervention.formularyAdditiveWtDoseRate"
            ),
    
        #
        # Sedative agents    
        #
        :midazolam => (regex = r"midazolam", category = "sedative"),
        :sufentanyl => (regex = r"sufenta", category = "sedative"),
        :propofol => (regex = r"propofol", category = "sedative"),
        :clonidine => (regex = r"clonidine", category = "sedative"),
        
        #
        # Blocking agents, Induction agents
        #
        :cisatracurium => r"cisatracurium",
        :atracurium => r"atracurium",
        :rocuronium => r"rocuronium",
        :etomidate => r"etomidate|hypnomidate",
        :celocurine => r"celocurine",
        
        #
        # Anticoagulant
        #
        :heparine => r"eparine",
        :enoxaparine => r"enoxaparine|lovenox",
        :innohep => r"innohep|tinzaparine",
        :fraxiparine => r"fraxiparine|nadroparine",
        :fragmine => r"fragmine|dalteparine",
        :calciparine => r"calciparine",
        :naco => r"naco|apixaban|eliquis|pradaxa|dabigatran|xarelto|rivaroxaban",
        :coumadine => r"coumadine|warfarine|previscan|fluindione|sintrom|acenocoumarole",
        
        # 
        # Antiplatelet
        #
        :aspirine1 => r"aspirine|aspegic|kardegic|ticlid|ticlopidine", # PROBLEM
        :aspirine2 => r"efient|prasugrel|plavix|clopidogrel|brilique|ticagrélor", # PROBLEM
        
        #
        # Insuline
        #
        :insuline => r"insuline",
        
        #
        # Antibiotics
        #
        :cefepime => r"cefepime|Axepim",
        :amikacine => r"amikacine|amiklin",
        :cefotaxime => r"cefotaxime|claforan",
        :ceftazidime => r"ceftazidime|fortum",
        :imipenem => r"imipenem|tienam",
        :meropenem => r"meropenem|meronem",
        :vancomycine => r"vancomycine",
        :linezolide => r"linezolide|zyvoxid",
        :colimycine => r"colimycine|colistine",
        :piperacilline => r"piperacilline",
        :tazocilline => r"tazocilline|tazobactam", # PROBLEM
        :amoxicilline => r"amoxicilline|clamoxyl",
        :dalacine => r"dalacine|clindamycine",
        :ceftriaxone => r"ceftriaxone|rocephine",
        :metronidazole => r"metronidazole|flagyl",
        :sulfamethoxazole => r"sulfamethoxazole|bactrim|cotrimoxazole",
        :oxacilline => r"oxacilline|bristopen",
        :gentamicine => r"gentamicine|gentalline",
        
        #
        # Antifungal
        #
        :caspofungine => r"caspofungine|cancidas",
        :voriconazole => r"voriconazole|vfend",
        :echinocandine => r"echinocandine|mycamine|mycafungin",
        :ambisome => r"ambisome|amphotericine",
        :fluconazole => r"fluconazole|triflucan",
        
        #
        # Anti-hypertensive_agent
        #
        :urapidil => r"urapidil|eupressyl",
        :nicardipine => r"nicardipine|loxen",
        :labetalol => r"labetalol|trandate",
        :risordan => r"risordan|trinitrine",
        
        #
        # Diuretic_agent
        #
        :furosemide => r"furosemide|frusemide|lasilix",
        
        #
        # Steroids
        #
        :steroids => r"prednisolone|prednisone|solumedrol|solupred|hydrocortisone",
        :hydrocortisone => r"hydrocortisone|HSHC",
        
        #
        # Temperature_mgt_agent
        #
        :paracetamol => r"paracetamol|dafalgan|dafalgan|efferalgan|perfalgan",
        
        #
        # Analgesic
        #
        :morphine => r"morphine",
        :nefopam => r"nefopam|acupan",
        
        #
        # Arrhythmia
        #
        :cordarone => r"cordarone|tildiem|diltiazen|amiodarone"
    )

    for (k,v) in molecules
        attributeDictionaryPropNameForDrip = "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate"
        attributeDictionaryPropNameForDiscrete = "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose"
        _regex=""

        if isa(v, NamedTuple)
            _regex=v.regex
            if haskey(v,:attributeDictionaryPropNameForDrip)
                if !ismissing(v.attributeDictionaryPropNameForDrip)
                    attributeDictionaryPropNameForDrip = v.attributeDictionaryPropNameForDrip
                end
            end

            if haskey(v,:attributeDictionaryPropNameForDiscrete)
                if !ismissing(v.attributeDictionaryPropNameForDiscrete)
                    attributeDictionaryPropNameForDiscrete = v.attributeDictionaryPropNameForDiscrete
                end
            end
        else
            _regex = v
        end

        
        moleculeDripMean = prefiltered |>
            n -> filter(x -> x.attributeDictionaryPropName == attributeDictionaryPropNameForDrip, n) |>
            n -> filter(x -> !isnothing(match(_regex, lowercase(x.interventionLongLabel))),n) |>
            n -> if isempty(n.terseForm) return missing else n.terseForm end |>
            # n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
            n -> mean(n) |>
            n -> round(n, digits = 2)

        moleculeDiscreteMean = prefiltered |>
            n -> filter(x -> x.attributeDictionaryPropName == attributeDictionaryPropNameForDiscrete, n) |>
            n -> filter(x -> !isnothing(match(_regex, lowercase(x.interventionLongLabel))),n) |>
            n -> if isempty(n.terseForm) return missing else n.terseForm end |>
            # n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
            n -> mean(n) |>
            n -> round(n, digits = 2)

        
        moleculeDripSymbol = Symbol(String(k)*"Drip")
        moleculeDiscreteSymbol = Symbol(String(k)*"Discrete")

        if isa(v, NamedTuple)
            if haskey(v,:category)
                if isa(moleculeDripMean,Number)
                    if moleculeDripMean > 0 
                        dict[Symbol(v.category)] = true
                    end
                end
                if isa(moleculeDiscreteMean,Number)
                    if moleculeDiscreteMean > 0 
                        dict[Symbol(v.category)] = true
                    end
                end
            end
        end

        if !(ismissing(moleculeDripMean) && ismissing(moleculeDiscreteMean))
            dict[moleculeDripSymbol] =  moleculeDripMean
            dict[moleculeDiscreteSymbol] = moleculeDiscreteMean
        end
    end

    #TODO Bapt : est-ce qu'on enregistre le "missing discrete" de la molécule lorsqu'on a uniquement le drip ?
    #Et vice-versa ? Dans l'état on enregistre les 2 lorsque qu'au moins un des 2 est présent, le manquant est mis à "missing"
    
    return dict
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