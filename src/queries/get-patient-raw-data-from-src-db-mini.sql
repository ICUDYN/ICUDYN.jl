SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('PtAssessment_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtAssessment_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName,
	   ('PtAssessment_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtAssessment_' + res.interventionPropName) AS interventionPropName, 
	   ('PtAssessment_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtAssessment_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtAssessment_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtAssessment_' + res.attributePropName) AS attributePropName, 	    	   
	   ('PtAssessment_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtAssessment res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)

ORDER BY interventionPropName, chartTime;