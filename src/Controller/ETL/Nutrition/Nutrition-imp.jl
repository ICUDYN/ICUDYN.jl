function ETL.Nutrition.computeFeedingTypeVolumeAndCalories(window::DataFrame)

    # ################## #
    # Parenteral feeding #
    # ################## #
    @info "HERE"
    parenteralVolPerikabiven = window |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.verboseForm, "Perikabiven"),
            n) |>
        n -> filter(
            x -> checkIfContainsNonStrict(x.attributeDictionaryPropName, ".intakeVolume"),
            n) |>
        n -> n[:,:terseForm] |>
        n -> if isempty(n) return missing else n end |>
        n -> string.(n) |>
        n -> replace.(n,"," => ".") |>
        n -> parse.(Float64,n) |>
        sum |>
        n -> round(n;digits = 2)


end
