function ETL.Transfusion._computeTransfusionParam(window::DataFrame, inverventionShortLabel::String)

    #TODO Bapt : vérifier si c'est bien ça qu'on veut faire. En regardant le fichier excel 
    #je ne suis pas sur que le code R fasse la bonne chose ?
    var1 = window |>
        n -> subset(n,
        :attributeDictionaryPropName => ByRow(==("PtIntake_bloodProductInt.N_de_lot")),
        :interventionShortLabel => ByRow(contains(inverventionShortLabel)))|>
        n -> if isempty(n) return missing else nrow(n) end


    var2 = window |>
        n -> subset(n,
        :attributeDictionaryPropName => ByRow(==("PtIntake_bloodProductInt.intakeVolume")),
        :interventionShortLabel => ByRow(contains(inverventionShortLabel)),
        :terseForm => ByRow(!isMissing)) |>
        n -> n.terseForm |>
        n -> ICUDYNUtil.convertToFloatIfPossible.(n)
        n -> if isempty(n) return missing else sum(n) end

    return[var1,var2]
end


"""
computeBloodCellsUnits(window::DataFrame)

Computes the blood cells units
"""

function ETL.Transfusion.computeBloodCellsUnits(window::DataFrame)
    result = ETL.Transfusion._computeTransfusionParam(window,"PtIntake_Culot GR")
    return Dict(
        :redBloodCellsUnits => result[1],
        :redBloodCellsVolume => result[2]
        )
end

"""
computePlatelets(window::DataFrame)

Computes the platelets
"""
function ETL.Transfusion.computePlatelets(window::DataFrame)
    result =  ETL.Transfusion._computeTransfusionParam(window,"PtIntake_Plaquettes")
    return Dict(
        :plateletsUnits => result[1],
        :plateletsVolume => result[2]
    )
end

"""
computePlasma(window::DataFrame)

Computes the plasma
"""
function ETL.Transfusion.computePlasma(window::DataFrame)
    result =  ETL.Transfusion._computeTransfusionParam(window,"PtIntake_PFC")
    return Dict(
        :plasmaUnits => result[1],
        :plasmaVolume => result[2]
    )
end