include("../../../runtests-prerequisite.jl")

@testset "Test ETL.Nutrition.computeFeedingTypeVolumeAndCalories" begin

    # Parenteral
    window = DataFrame(
        attributeDictionaryPropName = ["toto.intakeVolume","a","b","toto.intakeVolume"],
        verboseForm = ["Perikabiven","a","b","Perikabiven"],
        terseForm = ["10","","","10.5551"]
    )
    ETL.Nutrition.computeFeedingTypeVolumeAndCalories(window)

    # Enteral
    window = DataFrame(
        attributeDictionaryPropName = ["toto.intakeVolume","a","b","toto.intakeVolume"],
        verboseForm = ["megareal","a","b","megareal"],
        terseForm = ["10","","","10.5551"]
    )
    ETL.Nutrition.computeFeedingTypeVolumeAndCalories(window)

    # Natural
    window = DataFrame(
        attributeDictionaryPropName = ["PtDietaryOrder_","a","b","toto.bb"],
        verboseForm = ["a","a","b","a"],
        terseForm = ["10","","","10.5551"]
    )
    ETL.Nutrition.computeFeedingTypeVolumeAndCalories(window)

end
