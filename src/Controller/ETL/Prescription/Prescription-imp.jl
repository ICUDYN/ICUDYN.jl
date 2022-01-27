function ETL.Prescription.computePrescriptionBaseVars(window::DataFrame)
    
    dict = Dict{Symbol,Any}()
    prefiltered = window |>
        n -> filter(x -> startswith(x.attributeDictionaryPropName,"PtMedication_"),n) |>
        n -> filter(x -> !isMissing(x.terseForm), n) |>
        n -> transform!(
            n,
            :interventionLongLabel => ByRow(
                x -> rmAccentsAndLowercaseAndStrip(x) => :interventionLongLabel)
            )



    println(prefiltered)


    #TODO Bapt : regex "accent insensitive" pour les molécules ?
    #ou on ajoute les version avec et sans accent dans la regex ?
    molecules = Dict(

        #
        # Amine agents
        #
        :norepinephrine => r"PtMedication_Norepinephrine"i,
        :epinephrine => r"PtMedication_epinephrine"i,
        # Dobutamine is present in the data in unit gamma (i.e. micro gram) per kg per min
        :dobutamine => (
            regex =  r"dobutamine"i, 
            attributeDictionaryPropNameForDrip = r"PtMedication_dripAdmIntervention.formularyAdditiveWtDoseRate"i
            ),
    
        #
        # Sedative agents    
        #
        :midazolam => (regex = r"midazolam"i, category = "sedative"),
        :sufentanyl => (regex = r"sufenta"i, category = "sedative"),
        :propofol => (regex = r"propofol"i, category = "sedative"),
        :clonidine => (regex = r"clonidine"i, category = "sedative"),
        
        #
        # Blocking agents, Induction agents
        #
        :cisatracurium => r"cisatracurium"i,
        :atracurium => r"atracurium"i,
        :rocuronium => r"rocuronium"i,
        :etomidate => r"etomidate|hypnomidate"i,
        :celocurine => r"celocurine"i,
        
        #
        # Anticoagulant
        #
        :heparine => r"eparine"i,
        :enoxaparine => r"enoxaparine|lovenox"i,
        :innohep => r"innohep|tinzaparine"i,
        :fraxiparine => r"fraxiparine|nadroparine"i,
        :fragmine => r"fragmine|dalteparine"i,
        :calciparine => r"calciparine"i,
        :naco => r"naco|apixaban|eliquis|pradaxa|dabigatran|xarelto|rivaroxaban"i,
        :coumadine => r"coumadine|warfarine|previscan|fluindione|sintrom|acenocoumarole"i,
        
        # 
        # Antiplatelet
        #
        :aspirine1 => r"aspirine|aspegic|kardegic|ticlid|ticlopidine"i, # PROBLEM
        :aspirine2 => r"efient|prasugrel|plavix|clopidogrel|brilique|ticagrélor"i, # PROBLEM
        
        #
        # Insuline
        #
        :insuline => r"insuline"i,
        
        #
        # Antibiotics
        #
        :cefepime => r"cefepime|Axepim"i,
        :amikacine => r"amikacine|amiklin"i,
        :cefotaxime => r"cefotaxime|claforan"i,
        :ceftazidime => r"ceftazidime|fortum"i,
        :imipenem => r"imipenem|tienam"i,
        :meropenem => r"meropenem|meronem"i,
        :vancomycine => r"vancomycine"i,
        :linezolide => r"linezolide|zyvoxid"i,
        :colimycine => r"colimycine|colistine"i,
        :piperacilline => r"piperacilline"i,
        :tazocilline => r"tazocilline|tazobactam"i, # PROBLEM
        :amoxicilline => r"amoxicilline|clamoxyl"i,
        :dalacine => r"dalacine|clindamycine"i,
        :ceftriaxone => r"ceftriaxone|rocephine"i,
        :metronidazole => r"metronidazole|flagyl"i,
        :sulfamethoxazole => r"sulfamethoxazole|bactrim|cotrimoxazole"i,
        :oxacilline => r"oxacilline|bristopen"i,
        :gentamicine => r"gentamicine|gentalline"i,
        
        #
        # Antifungal
        #
        :caspofungine => r"caspofungine|cancidas"i,
        :voriconazole => r"voriconazole|vfend"i,
        :echinocandine => r"echinocandine|mycamine|mycafungin"i,
        :ambisome => r"ambisome|amphotericine"i,
        :fluconazole => r"fluconazole|triflucan"i,
        
        #
        # Anti-hypertensive_agent
        #
        :urapidil => r"urapidil|eupressyl"i,
        :nicardipine => r"nicardipine|loxen"i,
        :labetalol => r"labetalol|trandate"i,
        :risordan => r"risordan|trinitrine"i,
        
        #
        # Diuretic_agent
        #
        :furosemide => r"furosemide|frusemide|lasilix"i,
        
        #
        # Steroids
        #
        :steroids => r"prednisolone|prednisone|solumedrol|solupred|hydrocortisone"i,
        :hydrocortisone => r"hydrocortisone|HSHC"i,
        
        #
        # Temperature_mgt_agent
        #
        :paracetamol => r"paracetamol|dafalgan|dafalgan|efferalgan|perfalgan"i,
        
        #
        # Analgesic
        #
        :morphine => r"morphine"i,
        :nefopam => r"nefopam|acupan"i,
        
        #
        # Arrhythmia
        #
        :cordarone => r"cordarone|tildiem|diltiazen|amiodarone"i
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
            n -> filter(x -> !isnothing(match(_regex, x.interventionLongLabel)),n) |>
            n -> if isempty(n.terseForm) return missing else n.terseForm end |>
            n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
            n -> filter(x -> x > 0,n) |>
            n -> mean(n) |>
            n -> round(n, digits = 2)

        moleculeDiscreteMean = prefiltered |>
            n -> filter(x -> x.attributeDictionaryPropName == attributeDictionaryPropNameForDiscrete, n) |>
            n -> filter(x -> !isnothing(match(_regex, x.interventionLongLabel)),n) |>
            n -> if isempty(n.terseForm) return missing else n.terseForm end |>
            n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
            n -> filter(x -> x > 0,n) |>
            n -> mean(n) |>
            n -> round(n, digits = 2)

        
        moleculeDripSymbol = Symbol("$(k)Drip")
        moleculeDiscreteSymbol = Symbol("$(k)Discrete")

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