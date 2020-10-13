@testset "Test Stay.convertDataFrameToTimeArray(df::Dataframe)" begin

   # With DateTime
   chartTime = [DateTime("2019-09-01T23:00:00"),
                DateTime("2019-09-01T23:05:00")]
   heartRate = [68,120]

   df_test = DataFrame(chartTime = chartTime, heartRate = heartRate)
   Controller.Stay.convertDataFrameToTimeArray(df_test)

   # With ZonedDateTime
   time1 = TimeZones.ZonedDateTime(DateTime("2019-10-27T07:00:01"),
                                   TimeZones.TimeZone("Europe/Paris"))
   time2 = TimeZones.ZonedDateTime(DateTime("2019-10-27T06:57:00"),
                                   TimeZones.TimeZone("Europe/Paris"))
   chartTime = [time1, time2]
   heartRate = [68, 120]

   df = DataFrame(chartTime = chartTime, heartRate = heartRate)
   Controller.Stay.convertDataFrameToTimeArray(df)

end

@testset "Test Stay.convertTimeArrayToDataFrame(df::Dataframe)" begin


   # With ZonedDateTime
   time1 = TimeZones.ZonedDateTime(DateTime("2019-10-27T07:00:01"),
                                   TimeZones.TimeZone("Europe/Paris"))
   time2 = TimeZones.ZonedDateTime(DateTime("2019-10-27T06:57:00"),
                                   TimeZones.TimeZone("Europe/Paris"))
   chartTime = [time1, time2]
   heartRate = [68, 120]

   df = DataFrame(chartTime = chartTime, heartRate = heartRate)
   ta = Controller.Stay.convertDataFrameToTimeArray(df)

   df_bis = Controller.Stay.convertTimeArrayToDataFrame(ta)

end

@testset "Test Stay.getCutIndexesOfWindows Stay.splitDataFrameInWindows" begin

   time1 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:00"),
                                   TimeZones.TimeZone("Europe/Paris"))
   time2 = TimeZones.ZonedDateTime(DateTime("2019-10-28T05:57:01"),
                                   TimeZones.TimeZone("Europe/Paris"))
   time3 = TimeZones.ZonedDateTime(DateTime("2019-10-28T07:00:00"),
                                   TimeZones.TimeZone("Europe/Paris"))

   chartTime = [time2, time1, time3]
   heartRate = [68, 120, 90]

   df = DataFrame(chartTime = chartTime, heartRate = heartRate)

   Controller.Stay.getCutIndexesOfWindows(df,4,"hour")
   Controller.Stay.splitDataFrameInWindows(df,4,"hour")

end
