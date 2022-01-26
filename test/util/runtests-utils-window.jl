include("../runtests-prerequisite.jl")

@testset "Test ICUDYNUtil.firstNonMissingValue" begin
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,34,56]
    )
    @test ICUDYNUtil.firstNonMissingValue(variable,refinedWindows) == 34    
end




@testset "Test ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows" begin
        
    # Value in first window
    date = DateTime("2022-01-10T00:00:00")
    refinedWindows = DataFrame(
        age = [30,missing,missing],
        startTime = DateTime.([
            "2022-01-01T00:00:00"
            "2022-01-02T00:00:00"
            "2022-01-03T00:00:00"
        ])

    )
    @test ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(:age, date, refinedWindows) == 30

    # No value
    date = DateTime("2022-01-01T00:00:00")
    refinedWindows = DataFrame(
        age = [missing,missing,missing],
        startTime = DateTime.([
            "2022-01-01T00:00:00"
            "2022-01-02T00:00:00"
            "2022-01-03T00:00:00"
        ])

    )
    @test ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(:age, date, refinedWindows) === missing

    # Value after
    date = DateTime("2022-01-01T00:00:00")
    refinedWindows = DataFrame(
        age = [missing,30,missing],
        startTime = DateTime.([
            "2022-01-01T00:00:00"
            "2022-01-02T00:00:00"
            "2022-01-03T00:00:00"
        ])

    )
    @test ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(:age, date, refinedWindows) === missing

    # Value after with dateReturn
    date = DateTime("2022-01-01T00:00:00")
    refinedWindows = DataFrame(
        age = [missing,30,missing],
        startTime = DateTime.([
            "2022-01-01T00:00:00"
            "2022-01-02T00:00:00"
            "2022-01-03T00:00:00"
        ])

    )
    @test ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(:age, date, refinedWindows; returnDate=true) === (missing,missing)

    # Value in first window with dateReturn
    date = DateTime("2022-01-10T00:00:00")
    refinedWindows = DataFrame(
        age = [30,missing,missing],
        startTime = DateTime.([
            "2022-01-01T00:00:00"
            "2022-01-02T00:00:00"
            "2022-01-03T00:00:00"
        ])

    )
    @test ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(:age, date, refinedWindows; returnDate=true) == (30, DateTime("2022-01-01T00:00:00"))

   
end
    

@testset "Test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows" begin
    
    # Value in second window
    date=DateTime("2022-01-02T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,34,56],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-20T00:00:00"
            "2022-01-30T00:00:00"
        ])
    )

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
        variable, date, refinedWindows) == 34 
    
    # Value in last window
    date=DateTime("2022-01-02T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,missing,56],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-20T00:00:00"
            "2022-01-30T00:00:00"
        ])
    )

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
        variable, date, refinedWindows) == 56

    # Date after windows
    date=DateTime("2022-02-02T00:00:00")

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
            variable, date, refinedWindows) === missing 


    #No value
    date=DateTime("2022-01-01T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,missing,missing],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-20T00:00:00"
            "2022-01-30T00:00:00"
        ])
    )

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
            variable, date, refinedWindows) === missing

    
    #No value with returnDate
    date=DateTime("2022-01-01T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,missing,missing],
        startTime = DateTime.([
            "2022-01-10T00:00:00" 
            "2022-01-20T00:00:00"
            "2022-01-30T00:00:00"
        ])
    )

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
            variable, date, refinedWindows; returnDate = true) === (missing, missing) 


    # Value in last window with returnDate
    date=DateTime("2022-01-02T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,missing,56],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-20T00:00:00"
            "2022-01-30T00:00:00"
        ])
    )

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
        variable, date, refinedWindows; returnDate = true) == (56, DateTime("2022-01-30T00:00:00"))

    # Date after windows with returnDate
    date=DateTime("2022-02-02T00:00:00")

    @test ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
            variable, date, refinedWindows; returnDate = true) === (missing,missing)

end






@testset "Test ICUDYNUtil.closestNonMissingValue" begin
    date=DateTime("2022-01-02T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [missing,34,56],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-20T00:00:00"
            "2022-01-30T00:00:00"
        ])
    )
    @test ICUDYNUtil.closestNonMissingValue(variable, date, refinedWindows) == 34    


    #value in past windows
    date=DateTime("2022-01-12T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [10,11,17,18],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-11T00:00:00"
            "2022-01-17T00:00:00"
            "2022-01-18T00:00:00"
        ])
    )
    @test ICUDYNUtil.closestNonMissingValue(variable, date, refinedWindows) == 11 


    #value in next windows
    date=DateTime("2022-01-15T00:00:00")
    variable = :age
    refinedWindows = DataFrame(
        age = [10,11,17,18],
        startTime = DateTime.([
            "2022-01-10T00:00:00"
            "2022-01-11T00:00:00"
            "2022-01-17T00:00:00"
            "2022-01-18T00:00:00"
        ])
    )
    @test ICUDYNUtil.closestNonMissingValue(variable, date, refinedWindows) == 17 


end
