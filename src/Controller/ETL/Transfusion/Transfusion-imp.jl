function ETL.Transfusion.computeTransfusionParam(window::DataFrame, inverventionShortLabel::String)

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
        :terseForm => ByRow(!passmissing(isMissing))) |>
        n -> n.terseForm |>
        n -> if isempty(n) return missing else sum(n) end

    return[var1,var2]
end


"""
computeBloodCellsUnits(window::DataFrame)

Computes the blood cells units
"""

function ETL.Transfusion.computeBloodCellsUnits(window::DataFrame)
    return ETL.Transfusion.computeTransfusionParam(window,"PtIntake_Culot GR")
end

"""
computePlatelets(window::DataFrame)

Computes the platelets
"""
function ETL.Transfusion.computePlatelets(window::DataFrame)
    return ETL.Transfusion.computeTransfusionParam(window,"PtIntake_Plaquettes")
end

"""
computePlasma(window::DataFrame)

Computes the plasma
"""
function ETL.Transfusion.computePlasma(window::DataFrame)
    return ETL.Transfusion.computeTransfusionParam(window,"PtIntake_PFC")
end