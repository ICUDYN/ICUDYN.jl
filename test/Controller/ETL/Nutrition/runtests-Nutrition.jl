include("../../../runtests-prerequisite.jl")

@testset "Test ETL.Nutrition.computeFeedingTypeVolumeAndCalories" begin
    window = DataFrame(
        attributeDictionaryPropName = ["toto.intakeVolume","a","b","toto.intakeVolume"],
        verboseForm = ["Perikabiven","a","b","Perikabiven"],
        terseForm = ["10","","","10.5551"]
    )
    @test ETL.Nutrition.computeFeedingTypeVolumeAndCalories(window) == 20.56
end
