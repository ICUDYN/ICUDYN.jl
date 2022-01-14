function ETL.FluidBalance.computeVolInOut(window::DataFrame)
    # "PtTotalBalance_Total apports (24h)"
    # "PtTotalBalance_Total pertes (24h)"
end


function ETL.FluidBalance.computePerfusion(window::DataFrame)
    # "PtTotalBalance_Perfusion IV, 24h"
end


function ETL.FluidBalance.computeVolAndTypeVascularFilling(window::DataFrame)
    # "PtIntake_colloidsInt.intakeVolume"
end


function ETL.FluidBalance.computeMedecine(window::DataFrame)
    # "PtTotalBalance_Médicaments, PSE et analgésie, 24h"
end


function ETL.FluidBalance.computeEnteralFeeding(window::DataFrame)
    # "PtTotalBalance_Apports entéraux, 24h"
end


function ETL.FluidBalance.computeParentalFeeding(window::DataFrame)
    # "PtIntake_tpnInt.intakeVolume"
end
