@testset "Test ICUDYNUtil.timeDiffInGivenUnit" begin
   time1 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:00"),
                                   TimeZones.TimeZone("Europe/Paris"))
   time2 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:01.90"),
                                   TimeZones.TimeZone("Europe/Paris"))

  ICUDYNUtil.timeDiffInGivenUnit(time1,time2,"mill")
  ICUDYNUtil.timeDiffInGivenUnit(time1,time2,"sec")
end


@testset "Test ICUDYNUtil.timeDiffInGivenUnit" begin
  df = DataFrame(a = [21,22,23,24], b = [11,12,13,14])
  ICUDYNUtil.cutAt(df,
                   [3])
  ICUDYNUtil.cutAt(df,
                  [4])
  ICUDYNUtil.cutAt(df,
                   [1])

end
