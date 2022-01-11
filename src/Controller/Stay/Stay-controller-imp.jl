using ICUDYN.Controller.Stay, DataFrames, TimeSeries

function Stay.convertDataFrameToTimeArray(df::DataFrame)
    # TimeArray(df′, timestamp = :A)
    return TimeArray(df, timestamp = :chartTime)
end

function Stay.convertTimeArrayToDataFrame(ta::TimeArray)
    df = DataFrame(ta)
    DataFrames.rename!(df, (:timestamp => :chartTime))
    return df
end


function Stay.getCutIndexesOfWindows(df::DataFrame,
                                     windowSize::Integer,
                                     windowUnit::String
                                    ;alreadySorted::Bool = false)

   timestampCol = :chartTime

   # If dataframe is not already sorted
   if !alreadySorted
       df = sort(df,timestampCol)
   end

   windowLowerBound = df[1,timestampCol]
   cutIndexes = Int64[]

   increment = 0

   for row in eachrow(df)
       increment += 1
       timediff = ICUDYNUtil.timeDiffInGivenUnit(windowLowerBound,
                                                 row[timestampCol],
                                                 windowUnit)
       if (timediff > windowSize)
           push!(cutIndexes,increment)
       end
   end

   return cutIndexes

end

function Stay.splitDataFrameInWindows(df::DataFrame,
                                      windowSize::Integer,
                                      windowUnit::String)
    timestampCol = :chartTime
    df = sort(df,timestampCol)
    indexes = Stay.getCutIndexesOfWindows(df,
                                          windowSize,
                                          windowUnit
                                         ;alreadySorted = true)
    return ICUDYNUtil.cutAt(df,indexes)
end
