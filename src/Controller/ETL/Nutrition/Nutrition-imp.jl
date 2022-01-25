function ETL.Nutrition.computeFeedingTypeVolumeAndCalories(window::DataFrame)

    # NOTE: We use two boolean variables 'parenteralFeeding' and 'enteralFeeding'
    #         instead of one variable (say 'nutritionType') because we may have several
    #         nutrition on the same window

    parenteralFeeding::Union{Bool,Missing} = missing
    parenteralVolume::Union{Float64,Missing} = missing
    parenteralCalories::Union{Float64,Missing} = missing
    enteralFeeding::Union{Bool,Missing} = missing
    enteralVolume::Union{Float64,Missing} = missing
    enteralCalories::Union{Float64,Missing} = missing

    # ################## #
    # Parenteral feeding #
    # ################## #
    parenteralVolPerikabiven = window |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.verboseForm, "Perikabiven"),
            n) |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.attributeDictionaryPropName, ".intakeVolume"),
            n) |>
        n -> n[:,:terseForm] |>
        n -> if isempty(n) return missing else n end |>
        n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
        sum |>
        n -> round(n;digits = 2)

    parenteralVolSmofkabivenOlimel = window |>
        n -> filter(
            x -> !(isnothing ∘ match)(r"(?:Smofkabiven|Olimel)"i,x.verboseForm),
            n) |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.attributeDictionaryPropName, ".intakeVolume"),
            n) |>
        n -> n[:,:terseForm] |>
        n -> if isempty(n) return missing else n end |>
        n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
        sum |>
        n -> round(n;digits = 2)

    # If any of the two parenteral volume is not missing and superior to zero
    if (any(.!ismissing.([parenteralVolPerikabiven,parenteralVolSmofkabivenOlimel]))
        && any([parenteralVolPerikabiven,parenteralVolSmofkabivenOlimel] .> 0))

        parenteralFeeding = true

        parenteralVolume = [parenteralVolPerikabiven, parenteralVolSmofkabivenOlimel] |>
            n-> collect(Missings.replace(n,0)) |>
            sum |> n -> round(n, digits = 2)

        parenteralCalories = [parenteralVolPerikabiven, parenteralVolSmofkabivenOlimel] |>
            n -> collect(Missings.replace(n,0)) |>
            n -> n .* [
                1440 / 1000, # 1440 calories per 1000ml for Perikabiven
                1100 / 1000, # 1100 calories per 1000ml for Smofkabiven/Olimel
                ] |>
            sum |> n -> round(n, digits = 2)
    end

    # ############### #
    # Enteral feeding #
    # ############### #
    enteralVolMegareal = window |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.verboseForm, "megareal"),
            n) |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.attributeDictionaryPropName, ".intakeVolume"),
            n) |>
        n -> n[:,:terseForm] |>
        n -> if isempty(n) return missing else n end |>
        n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
        sum |>
        n -> round(n;digits = 2)

    enteralVolSondalis = window |>
        n -> filter(
            x -> !(isnothing ∘ match)(r"sondalis"i,x.verboseForm),
            n) |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.attributeDictionaryPropName, ".intakeVolume"),
            n) |>
        n -> n[:,:terseForm] |>
        n -> if isempty(n) return missing else n end |>
        n -> ICUDYNUtil.convertToFloatIfPossible.(n) |>
        sum |>
        n -> round(n;digits = 2)

    # If any of the two enteral volume is not missing and superior to zero
    if (any(.!ismissing.([enteralVolMegareal,enteralVolSondalis]))
        && any([enteralVolMegareal,enteralVolSondalis] .> 0))

        enteralFeeding = true

        enteralVolume = [enteralVolMegareal, enteralVolSondalis] |>
            n -> collect(Missings.replace(n,0)) |>
            sum |> n -> round(n, digits = 2)

        enteralCalories = [enteralVolMegareal, enteralVolSondalis] |>
            n -> collect(Missings.replace(n,0)) |>
            n -> n .* [
                1500 / 1000, # 1500 calories per 1000ml for megareal
                1000 / 1000, # 1000 calories per 1000ml for Sondalis
                ] |>
            sum |> n -> round(n, digits = 2)
    end

    # ############### #
    # Natural feeding #
    # ############### #
    naturalFeeding = window |>
        n -> filter(
            x -> startswith(x.attributeDictionaryPropName, "PtDietaryOrder_"),
            n) |>
        n -> n[:,:terseForm] |>
        n -> if isempty(n) return missing else true end

    # ###################### #
    # Return the result dict #
    # ###################### #
    return Dict(
        :parenteralFeeding => parenteralFeeding,
        :parenteralVolume => parenteralVolume,
        :parenteralCalories => parenteralCalories,
        :enteralFeeding => enteralFeeding,
        :enteralVolume => enteralVolume,
        :enteralCalories => enteralCalories,
        :naturalFeeding => naturalFeeding
    )

end
