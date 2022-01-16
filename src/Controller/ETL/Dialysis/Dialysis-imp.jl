function ETL.Dialysis.computeDialysisTypeAndDuration(window::DataFrame)

    result = Dict()

    started = missing
    type = missing
    durationPrescribed_hours = missing

    # ############################# #
    # For the intermittent dialysis #
    # ############################# #
    intermittent1stCase =
        window |> n -> ICUDYNUtil.getNonMissingValues(
            n,
            :attributeDictionaryPropName,
            "PtIntake_peritonealDiaInt.formularyAdditiveAmount",
            :interventionLongLabel) |>
        n -> filter(x -> contains(x,"Hémodialyse séquentielle"),n)

    intermittent2ndCase =
        window |> n -> ICUDYNUtil.getNonMissingValues(
            n,
            :interventionBaseLongLabel,
            "PtAssessment_Machine HD",
            :interventionLongLabel)

    # Get the duration
    if !isempty(intermittent1stCase) || !isempty(intermittent2ndCase)
        started = true
        type = "intermittent"
        if !isempty(intermittent1stCase)
            _regex = r"(\d)+h"
            durationPrescribed_hours =
                intermittent1stCase |>
                n -> filter(x -> !isnothing(match(_regex,x)),n) |>
                n -> if isempty(n) return missing else first(n) end  |>
                l -> match(_regex,l).captures |> first |> l -> parse(Int,l)
        end
    end

    # ########################### #
    # For the continuous dialysis #
    # ########################### #
    if ismissing(type)

        continous1stCase =
            window |>
            n -> filter(r -> r.interventionPropName == "PtIntakeOrder_Interrompre",n) |>
            n -> filter(r -> contains(r.attributeLongLabel,"CVVHF") ,n)

        continuous2ndCase =
            window |>
            n -> filter(r -> r.interventionBaseLongLabel == "PtAssessment_Machine HDF",n)

        if !isempty(continous1stCase) || !isempty(continuous2ndCase)
            started = true
            type = "continuous"

            # Get the duration
            endTime = continous1stCase |>
                n -> filter(r -> r.attributeLongLabel == "PtIntakeOrder_2.a. CVVHF.Interface Details.Effective Time",n) |>
                n -> n.terseForm |>
                n -> if isempty(n) missing else DateTime(first(n),"d/m/y HH:MM") end

            startTime = continous1stCase |>
                n -> filter(r -> r.attributeLongLabel == "PtIntakeOrder_2.a. CVVHF.Interface Details.Effective Time",n) |>
                n -> n.chartTime |> first

            if !ismissing(startTime) && !ismissing(endTime)
                durationPrescribed_hours = Hour(
                    round(Minute(endTime - startTime).value / 60)).value
            end

        end
    end



    return Dict(
        :started => started,
        :type => type,
        :durationPrescribed_hours => durationPrescribed_hours
    )

end

function ETL.Dialysis.computeDialysisMolecule(window::DataFrame)

    result = ICUDYNUtil.getVerboseFormFromWindow(
        window,
        "PtIntakeOrder_hemofiltrationOrd.formularyAdditiveUsageMat",
        missing)|>

    # Check that we have some rows (if not return missing)
    n -> if ismissing(n) return missing else n end |>

    # Clean the strings for ease of comparison
    n -> rmAccentsAndLowercaseAndStrip.(n) |> ICUDYNUtil.getMostFrequentValue |>
    n -> if contains(n, r"heparin|hnf") return "heparin"
         elseif contains(n, "citrate") return "citrate"
         elseif contains(n, r"lovenox|hbpm") return "lovenox"
         else error("Unknown dialysis molecule[$n]") end

    return result

end

function ETL.Dialysis.computeDialysisWaterLoss(window::DataFrame)

    ICUDYNUtil.getVerboseFormFromWindow(
        window,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        missing ) |>

    # Check that we have some rows (if not return missing)
    n -> if ismissing(n) return missing else n end |>

    # Transform ["200ml","100ml"] to [200,100]
    n -> map(x -> match(r"(\d*)",x).captures |> first |> n -> parse(Int,n),
             n) |>
    mean

end
