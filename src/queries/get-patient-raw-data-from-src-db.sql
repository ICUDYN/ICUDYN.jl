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
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('ptDemographic_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('ptDemographic_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	
	   ('ptDemographic_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('ptDemographic_' + res.interventionPropName) AS interventionPropName, 
	   ('ptDemographic_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('ptDemographic_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('ptDemographic_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('ptDemographic_' + res.attributePropName) AS attributePropName, 	      
	   ('ptDemographic_' + res.materialPropName) AS materialPropName
	   
FROM DAR.ptDemographic res
WHERE  res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.interventionLongDisplayLabel AS verboseForm, -- OVERRIDE
	   ('PtIntake_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtIntake_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtIntake_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtIntake_' + res.interventionPropName) AS interventionPropName, 
	   ('PtIntake_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtIntake_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtIntake_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtIntake_' + res.attributePropName) AS attributePropName, 	   
	   ('PtIntake_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtIntake res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('PtIntervention_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtIntervention_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtIntervention_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtIntervention_' + res.interventionPropName) AS interventionPropName, 
	   ('PtIntervention_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtIntervention_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtIntervention_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtIntervention_' + res.attributePropName) AS attributePropName, 	   
	   ('PtIntervention_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtIntervention res
WHERE  res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('PtLabResult_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtLabResult_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	
	   ('PtLabResult_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtLabResult_' + res.interventionPropName) AS interventionPropName, 
	   ('PtLabResult_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtLabResult_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtLabResult_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtLabResult_' + res.attributePropName) AS attributePropName, 	      
	   ('PtLabResult_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtLabResult res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('PtMedication_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtMedication_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	
	   ('PtMedication_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtMedication_' + res.interventionPropName) AS interventionPropName, 
	   ('PtMedication_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtMedication_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtMedication_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtMedication_' + res.attributePropName) AS attributePropName, 	      
	   ('PtMedication_' + res.materialPropName) AS materialPropName	
	   
FROM DAR.PtMedication res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('PtProcedure_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtProcedure_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtProcedure_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtProcedure_' + res.interventionPropName) AS interventionPropName, 
	   ('PtProcedure_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtProcedure_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtProcedure_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtProcedure_' + res.attributePropName) AS attributePropName, 	   
	   ('PtProcedure_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtProcedure res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.startTime, -- OVERRIDE
	   res.storeTime,
	   res.terseForm,
	   res.verboseForm,
	   ('PtProcedureOrder_' + res.orderLongLabel) AS interventionLongLabel,
	   ('PtProcedureOrder_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	
	   ('PtProcedureOrder_' + res.orderShortLabel) AS interventionShortLabel, 	    
	   ('PtProcedureOrder_' + res.orderPropName) AS interventionPropName, 
	   ('PtProcedureOrder_' + res.orderLongDisplayLabel) AS interventionBaseLongLabel, -- OVERRIDE
	   ('PtProcedureOrder_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtProcedureOrder_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtProcedureOrder_' + res.attributePropName) AS attributePropName, 	      
	   ('PtProcedureOrder_' + res.materialPropName) AS materialPropName	  
	   
FROM DAR.PtProcedureOrder res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   CAST(res.score AS varchar) AS terseForm, -- OVERRIDE
	   CAST(res.score AS varchar) AS verboseForm, -- OVERRIDE
	   ('PtScore_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtScore_' + res.dictionaryPropName) AS attributeDictionaryPropName, -- OVERRIDE
	   ('PtScore_' + res.interventionShortLabel) AS interventionShortLabel,
	   ('PtScore_' + res.interventionPropName) AS interventionPropName, 
	   ('PtScore_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtScore_' + res.interventionType) AS attributeLongLabel, -- OVERRIDE
	   ('PtScore_' + res.dictionaryLabel) AS attributeShortLabel, -- OVERRIDE
	   ('PtScore_' + res.dictionaryPropName) AS attributePropName, -- OVERRIDE	   
	   ('PtScore_' + res.dictionaryPropName) AS materialPropName -- OVERRIDE
	   
FROM DAR.PtScore res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.line, -- OVERRIDE
	   res.verboseForm,
	   ('PtSiteCare_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtSiteCare_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtSiteCare_' + res.interventionShortLabel) AS interventionShortLabel,
	   ('PtSiteCare_' + res.interventionPropName) AS interventionPropName,
	   ('PtSiteCare_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel,
	   ('PtSiteCare_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtSiteCare_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtSiteCare_' + res.attributePropName) AS attributePropName, 	   
	   ('PtSiteCare_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtSiteCare res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   CAST(res.hourTotal AS varchar) AS terseForm, -- OVERRIDE
	   CAST(res.cumTotal AS varchar) AS verboseForm, -- OVERRIDE	
	   ('PtTotalBalance_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtTotalBalance_' + res.interventionLongLabel) AS attributeDictionaryPropName, -- OVERRIDE
	   ('PtTotalBalance_' + res.interventionLongLabel) AS interventionShortLabel,
	   ('PtTotalBalance_' + res.interventionLongLabel) AS interventionPropName, 
	   ('PtTotalBalance_' + res.interventionLongLabel) AS interventionBaseLongLabel, 
	   ('PtTotalBalance_' + res.interventionLongLabel) AS attributeLongLabel, -- OVERRIDE
	   ('PtTotalBalance_' + res.interventionLongLabel) AS attributeShortLabel, -- OVERRIDE
	   ('PtTotalBalance_' + res.interventionLongLabel) AS attributePropName, -- OVERRIDE	   
	   ('PtTotalBalance_' + res.interventionLongLabel) AS materialPropName -- OVERRIDE	 
	   
FROM DAR.PtTotalBalance res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
SELECT res.encounterId,
       res.chartTime,
	   res.storeTime,
	   res.allergyShortLabel AS terseForm, -- OVERRIDE
	   res.valueString AS verboseForm, -- OVERRIDE
	   ('PtAllergy_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('PtAllergy_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtAllergy_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('PtAllergy_' + res.interventionPropName) AS interventionPropName, 
	   ('PtAllergy_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('PtAllergy_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtAllergy_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtAllergy_' + res.termPropName) AS attributePropName, 	   
	   ('PtAllergy_' + res.allergyPropName) AS materialPropName
	   
FROM DAR.PtAllergy  res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
-- NOTE: we use the table PtBedStay twice so that we have inTime and outTime separate
SELECT res.encounterId,
       res.inTime AS chartTime, -- OVERRIDE
	   res.inTime AS storeTime, -- OVERRIDE
	   'bedId_' + convert(varchar, res.bedId) AS terseForm, -- OVERRIDE
	   'clinicalUnitId_' + convert(varchar,res.clinicalUnitId) AS verboseForm, -- OVERRIDE
	   ('PtBedStay_inTime') AS interventionLongLabel,
	   ('PtBedStay_inTime') AS attributeDictionaryPropName,  
	   ('PtBedStay_inTime') AS interventionShortLabel,
	   ('PtBedStay_inTime') AS interventionPropName, 
	   ('PtBedStay_inTime') AS interventionBaseLongLabel, 
	   ('PtBedStay_inTime') AS attributeLongLabel, 
	   ('PtBedStay_inTime') AS attributeShortLabel, 
	   ('PtBedStay_inTime') AS attributePropName,
	   ('PtBedStay_inTime') AS materialPropName
	   
FROM DAR.PtBedStay res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
-- NOTE: we use the table PtBedStay twice so that we have inTime and outTime separate
SELECT res.encounterId,
       res.outTime AS chartTime, -- OVERRIDE
	   res.outTime AS storeTime, -- OVERRIDE
	   'bedId_' + convert(varchar, res.bedId) AS terseForm, -- OVERRIDE
	   'clinicalUnitId_' + convert(varchar,res.clinicalUnitId) AS verboseForm, -- OVERRIDE
	   ('PtBedStay_outTime') AS interventionLongLabel,
	   ('PtBedStay_outTime') AS attributeDictionaryPropName,  
	   ('PtBedStay_outTime') AS interventionShortLabel,
	   ('PtBedStay_outTime') AS interventionPropName, 
	   ('PtBedStay_outTime') AS interventionBaseLongLabel, 
	   ('PtBedStay_outTime') AS attributeLongLabel, 
	   ('PtBedStay_outTime') AS attributeShortLabel, 
	   ('PtBedStay_outTime') AS attributePropName,
	   ('PtBedStay_outTime') AS materialPropName
	   
FROM DAR.PtBedStay res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
-- NOTE: we use the table PtCensus many times to get the values from the different columns
SELECT res.encounterId,
       res.inTime AS chartTime, -- OVERRIDE
	   res.inTime AS storeTime, -- OVERRIDE
	   res.dischargeDisposition AS terseForm,
	   res.dischargeDisposition AS verboseForm,
	   ('PtCensus_dischargeDisposition') AS interventionLongLabel,
	   ('PtCensus_dischargeDisposition') AS attributeDictionaryPropName,  
	   ('PtCensus_dischargeDisposition') AS interventionShortLabel,
	   ('PtCensus_dischargeDisposition') AS interventionPropName, 
	   ('PtCensus_dischargeDisposition') AS interventionBaseLongLabel, 
	   ('PtCensus_dischargeDisposition') AS attributeLongLabel, 
	   ('PtCensus_dischargeDisposition') AS attributeShortLabel, 
	   ('PtCensus_dischargeDisposition') AS attributePropName,
	   ('PtCensus_dischargeDisposition') AS materialPropName
	   
FROM DAR.PtCensus res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
-- NOTE: we use the table PtCensus many times to get the values from the different columns
SELECT res.encounterId,
       res.outTime AS chartTime, -- OVERRIDE
	   res.outTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.isDeceased) AS terseForm,
	   convert(varchar,res.isDeceased) AS verboseForm,
	   ('PtCensus_isDeceased') AS interventionLongLabel,
	   ('PtCensus_isDeceased') AS attributeDictionaryPropName,  
	   ('PtCensus_isDeceased') AS interventionShortLabel,
	   ('PtCensus_isDeceased') AS interventionPropName, 
	   ('PtCensus_isDeceased') AS interventionBaseLongLabel, 
	   ('PtCensus_isDeceased') AS attributeLongLabel, 
	   ('PtCensus_isDeceased') AS attributeShortLabel, 
	   ('PtCensus_isDeceased') AS attributePropName,
	   ('PtCensus_isDeceased') AS materialPropName
	   
FROM DAR.PtCensus res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
-- NOTE: we use the table PtCensus many times to get the values from the different columns
SELECT res.encounterId,
       res.outTime AS chartTime, -- OVERRIDE
	   res.outTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.isDischarged) AS terseForm,
	   convert(varchar,res.isDischarged) AS verboseForm,
	   ('PtCensus_isDischarged') AS interventionLongLabel,
	   ('PtCensus_isDischarged') AS attributeDictionaryPropName,  
	   ('PtCensus_isDischarged') AS interventionShortLabel,
	   ('PtCensus_isDischarged') AS interventionPropName, 
	   ('PtCensus_isDischarged') AS interventionBaseLongLabel, 
	   ('PtCensus_isDischarged') AS attributeLongLabel, 
	   ('PtCensus_isDischarged') AS attributeShortLabel, 
	   ('PtCensus_isDischarged') AS attributePropName,
	   ('PtCensus_isDischarged') AS materialPropName
	   
FROM DAR.PtCensus res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
-- NOTE: we use the table PtCensus many times to get the values from the different columns
SELECT res.encounterId,
       res.outTime AS chartTime, -- OVERRIDE
	   res.outTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.isTransferred) AS terseForm,
	   convert(varchar,res.isTransferred) AS verboseForm,
	   ('PtCensus_isTransferred') AS interventionLongLabel,
	   ('PtCensus_isTransferred') AS attributeDictionaryPropName,  
	   ('PtCensus_isTransferred') AS interventionShortLabel,
	   ('PtCensus_isTransferred') AS interventionPropName, 
	   ('PtCensus_isTransferred') AS interventionBaseLongLabel, 
	   ('PtCensus_isTransferred') AS attributeLongLabel, 
	   ('PtCensus_isTransferred') AS attributeShortLabel, 
	   ('PtCensus_isTransferred') AS attributePropName,
	   ('PtCensus_isTransferred') AS materialPropName
	   
FROM DAR.PtCensus res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.chartTime AS chartTime,
	   res.storeTime AS storeTime,
	   res.terseForm AS terseForm,
	   res.verboseForm AS verboseForm,
	   ('ptDemographicHistorical_' + res.interventionLongLabel) AS interventionLongLabel,
	   ('ptDemographicHistorical_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('ptDemographicHistorical_' + res.interventionShortLabel) AS interventionShortLabel, 	    
	   ('ptDemographicHistorical_' + res.interventionPropName) AS interventionPropName, 
	   ('ptDemographicHistorical_' + res.interventionBaseLongLabel) AS interventionBaseLongLabel, 
	   ('ptDemographicHistorical_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('ptDemographicHistorical_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('ptDemographicHistorical_' + res.attributePropName) AS attributePropName, 	   
	   ('ptDemographicHistorical_' + res.materialPropName) AS materialPropName
	   
FROM DAR.ptDemographicHistorical res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.startDate AS chartTime, -- OVERRIDE
	   res.startDate AS storeTime, -- OVERRIDE
	   res.code AS terseForm, -- OVERRIDE
	   res.code AS verboseForm, -- OVERRIDE
	   ('PtDiagnosis_code') AS interventionLongLabel,
	   ('PtDiagnosis_code') AS attributeDictionaryPropName,  
	   ('PtDiagnosis_code') AS interventionShortLabel,
	   ('PtDiagnosis_code') AS interventionPropName, 
	   ('PtDiagnosis_code') AS interventionBaseLongLabel, 
	   ('PtDiagnosis_code') AS attributeLongLabel, 
	   ('PtDiagnosis_code') AS attributeShortLabel, 
	   ('PtDiagnosis_code') AS attributePropName,
	   ('PtDiagnosis_code') AS materialPropName
	   
FROM DAR.PtDiagnosis res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.startDate AS chartTime, -- OVERRIDE
	   res.startDate AS storeTime, -- OVERRIDE
	   res.codeLabel AS terseForm, -- OVERRIDE
	   res.codeLabel AS verboseForm, -- OVERRIDE
	   ('PtDiagnosis_codeLabel') AS interventionLongLabel,
	   ('PtDiagnosis_codeLabel') AS attributeDictionaryPropName,  
	   ('PtDiagnosis_codeLabel') AS interventionShortLabel,
	   ('PtDiagnosis_codeLabel') AS interventionPropName, 
	   ('PtDiagnosis_codeLabel') AS interventionBaseLongLabel, 
	   ('PtDiagnosis_codeLabel') AS attributeLongLabel, 
	   ('PtDiagnosis_codeLabel') AS attributeShortLabel, 
	   ('PtDiagnosis_codeLabel') AS attributePropName,
	   ('PtDiagnosis_codeLabel') AS materialPropName
	   
FROM DAR.PtDiagnosis res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.startDate AS chartTime, -- OVERRIDE
	   res.startDate AS storeTime, -- OVERRIDE
	   res.codingSystem AS terseForm, -- OVERRIDE
	   res.codingSystem AS verboseForm, -- OVERRIDE
	   ('PtDiagnosis_codingSystem') AS interventionLongLabel,
	   ('PtDiagnosis_codingSystem') AS attributeDictionaryPropName,  
	   ('PtDiagnosis_codingSystem') AS interventionShortLabel,
	   ('PtDiagnosis_codingSystem') AS interventionPropName, 
	   ('PtDiagnosis_codingSystem') AS interventionBaseLongLabel, 
	   ('PtDiagnosis_codingSystem') AS attributeLongLabel, 
	   ('PtDiagnosis_codingSystem') AS attributeShortLabel, 
	   ('PtDiagnosis_codingSystem') AS attributePropName,
	   ('PtDiagnosis_codingSystem') AS materialPropName
	   
FROM DAR.PtDiagnosis res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.creationTime AS chartTime,
	   res.creationTime AS storeTime,
	   res.terseForm AS terseForm,
	   res.verboseForm AS verboseForm,
	   ('PtDiagnosticOrder_' + res.orderLongDisplayLabel) AS interventionLongLabel, -- OVERRIDE
	   ('PtDiagnosticOrder_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtDiagnosticOrder_' + res.dictionaryLabel) AS interventionShortLabel, -- OVERRIDE	    
	   ('PtDiagnosticOrder_' + res.termPropName) AS interventionPropName, -- OVERRIDE
	   ('PtDiagnosticOrder_' + res.termLongLabel) AS interventionBaseLongLabel, -- OVERRIDE
	   ('PtDiagnosticOrder_' + res.termShortLabel) AS attributeLongLabel,  -- OVERRIDE
	   ('PtDiagnosticOrder_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtDiagnosticOrder_' + res.attributePropName) AS attributePropName, 	   
	   ('PtDiagnosticOrder_' + res.termPropName) AS materialPropName -- OVERRIDE
	   
FROM DAR.PtDiagnosticOrder res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.creationTime AS chartTime,
	   res.creationTime AS storeTime,
	   res.terseForm AS terseForm,
	   res.verboseForm AS verboseForm,
	   ('PtDietaryOrder_' + res.orderLongDisplayLabel) AS interventionLongLabel, -- OVERRIDE
	   ('PtDietaryOrder_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtDietaryOrder_' + res.dictionaryLabel) AS interventionShortLabel, -- OVERRIDE	    
	   ('PtDietaryOrder_' + res.termPropName) AS interventionPropName, -- OVERRIDE
	   ('PtDietaryOrder_' + res.termLongLabel) AS interventionBaseLongLabel, -- OVERRIDE
	   ('PtDietaryOrder_' + res.termShortLabel) AS attributeLongLabel,  -- OVERRIDE
	   ('PtDietaryOrder_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtDietaryOrder_' + res.attributePropName) AS attributePropName, 	   
	   ('PtDietaryOrder_' + res.termPropName) AS materialPropName -- OVERRIDE
	   
FROM DAR.PtDietaryOrder res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
SELECT res.encounterId,
       res.creationTime AS chartTime,
	   res.creationTime AS storeTime,
	   res.terseForm AS terseForm,
	   res.verboseForm AS verboseForm,
	   ('PtOrder_' + res.orderLongDisplayLabel) AS interventionLongLabel, -- OVERRIDE
	   ('PtOrder_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtOrder_' + res.dictionaryLabel) AS interventionShortLabel, -- OVERRIDE	    
	   ('PtOrder_' + res.termPropName) AS interventionPropName, -- OVERRIDE
	   ('PtOrder_' + res.termLongLabel) AS interventionBaseLongLabel, -- OVERRIDE
	   ('PtOrder_' + res.termShortLabel) AS attributeLongLabel,  -- OVERRIDE
	   ('PtOrder_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtOrder_' + res.attributePropName) AS attributePropName, 	   
	   ('PtOrder_' + res.termPropName) AS materialPropName -- OVERRIDE
	   
FROM DAR.PtOrder res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.creationTime AS chartTime,
	   res.creationTime AS storeTime,
	   res.terseForm AS terseForm,
	   res.verboseForm AS verboseForm,
	   ('PtRespiratoryOrder_' + res.orderLongDisplayLabel) AS interventionLongLabel, -- OVERRIDE
	   ('PtRespiratoryOrder_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtRespiratoryOrder_' + res.dictionaryLabel) AS interventionShortLabel, -- OVERRIDE	    
	   ('PtRespiratoryOrder_' + res.termPropName) AS interventionPropName, -- OVERRIDE
	   ('PtRespiratoryOrder_' + res.termLongLabel) AS interventionBaseLongLabel, -- OVERRIDE
	   ('PtRespiratoryOrder_' + res.termShortLabel) AS attributeLongLabel,  -- OVERRIDE
	   ('PtRespiratoryOrder_' + res.attributeShortLabel) AS attributeShortLabel, 
	   ('PtRespiratoryOrder_' + res.attributePropName) AS attributePropName, 	   
	   ('PtRespiratoryOrder_' + res.termPropName) AS materialPropName -- OVERRIDE
	   
FROM DAR.PtRespiratoryOrder res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
SELECT res.encounterId,
       res.startTime AS chartTime, -- OVERRIDE
	   res.startTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.startTime) AS terseForm, -- OVERRIDE
	   convert(varchar,res.startTime) AS verboseForm, -- OVERRIDE
	   ('PtSite_startTime') AS interventionLongLabel,
	   ('PtSite_startTime') AS attributeDictionaryPropName,  -- OVERRIDE
	   ('PtSite_startTime') AS interventionShortLabel, 	    
	   ('PtSite_startTime') AS interventionPropName, 
	   ('PtSite_startTime') AS interventionBaseLongLabel, 
	   ('PtSite_startTime') AS attributeLongLabel, -- OVERRIDE
	   ('PtSite_startTime') AS attributeShortLabel, -- OVERRIDE
	   ('PtSite_startTime') AS attributePropName, -- OVERRIDE
	   ('PtSite_startTime') AS materialPropName -- OVERRIDE
	   
FROM DAR.PtSite res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.endTime AS chartTime, -- OVERRIDE
	   res.endTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.endTime) AS terseForm, -- OVERRIDE
	   convert(varchar,res.endTime) AS verboseForm, -- OVERRIDE
	   ('PtSite_endTime') AS interventionLongLabel,
	   ('PtSite_endTime') AS attributeDictionaryPropName,  -- OVERRIDE
	   ('PtSite_endTime') AS interventionShortLabel, 	    
	   ('PtSite_endTime') AS interventionPropName, 
	   ('PtSite_endTime') AS interventionBaseLongLabel, 
	   ('PtSite_endTime') AS attributeLongLabel, -- OVERRIDE
	   ('PtSite_endTime') AS attributeShortLabel, -- OVERRIDE
	   ('PtSite_endTime') AS attributePropName, -- OVERRIDE
	   ('PtSite_endTime') AS materialPropName -- OVERRIDE
	   
FROM DAR.PtSite res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.startTime AS chartTime, -- OVERRIDE
	   res.startTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.startTime) AS terseForm, -- OVERRIDE
	   convert(varchar,res.startTime) AS verboseForm, -- OVERRIDE
	   ('PtVentilation_startTime') AS interventionLongLabel,
	   ('PtVentilation_startTime') AS attributeDictionaryPropName,  
	   ('PtVentilation_startTime') AS interventionShortLabel,
	   ('PtVentilation_startTime') AS interventionPropName, 
	   ('PtVentilation_startTime') AS interventionBaseLongLabel, 
	   ('PtVentilation_startTime') AS attributeLongLabel, 
	   ('PtVentilation_startTime') AS attributeShortLabel, 
	   ('PtVentilation_startTime') AS attributePropName,
	   ('PtVentilation_startTime') AS materialPropName
	   
FROM DAR.PtVentilation res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.endTime AS chartTime, -- OVERRIDE
	   res.endTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.endTime) AS terseForm, -- OVERRIDE
	   convert(varchar,res.endTime) AS verboseForm, -- OVERRIDE
	   ('PtVentilation_endTime') AS interventionLongLabel,
	   ('PtVentilation_endTime') AS attributeDictionaryPropName,  
	   ('PtVentilation_endTime') AS interventionShortLabel,
	   ('PtVentilation_endTime') AS interventionPropName, 
	   ('PtVentilation_endTime') AS interventionBaseLongLabel, 
	   ('PtVentilation_endTime') AS attributeLongLabel, 
	   ('PtVentilation_endTime') AS attributeShortLabel, 
	   ('PtVentilation_endTime') AS attributePropName,
	   ('PtVentilation_endTime') AS materialPropName
	   
FROM DAR.PtVentilation res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
SELECT res.encounterId,
       res.startTime AS chartTime, -- OVERRIDE	   
	   res.creationTime AS storeTime, -- OVERRIDE	   
		res.terseForm,
	   res.verboseForm,
	   ('PtIntakeOrder_frequency_' + res.frequency) AS interventionLongLabel, -- NULL termLongLabel, baseUOM
	   ('PtIntakeOrder_' + res.attributeDictionaryPropName) AS attributeDictionaryPropName, 	   
	   ('PtIntakeOrder_' + res.attributeShortLabel) AS interventionShortLabel, 	    
	   ('PtIntakeOrder_' + res.action) AS interventionPropName, 
	   ('PtIntakeOrder_duration_' + convert(varchar,res.duration)) AS interventionBaseLongLabel, -- NULL termPropName
	   ('PtIntakeOrder_' + res.attributeLongLabel) AS attributeLongLabel, 
	   ('PtIntakeOrder_endTime_' + convert(varchar,res.endTime,121)) AS attributeShortLabel, 
	   ('PtIntakeOrder_' + res.attributePropName) AS attributePropName, 	   
	   ('PtIntakeOrder_' + res.materialPropName) AS materialPropName
	   
FROM DAR.PtIntakeOrder res
WHERE res.endTime IS NOT NULL  
AND res.attributePropName != 'PtIntakeOrder_professionalDomain'
AND res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.inTime AS chartTime, -- OVERRIDE
	   res.inTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.inTime) AS terseForm, -- OVERRIDE
	   convert(varchar,res.inTime) AS verboseForm, -- OVERRIDE
	   ('V_Census_inTime') AS interventionLongLabel,
	   ('V_Census_inTime') AS attributeDictionaryPropName,  
	   ('V_Census_inTime') AS interventionShortLabel,
	   ('V_Census_inTime') AS interventionPropName, 
	   ('V_Census_inTime') AS interventionBaseLongLabel, 
	   ('V_Census_inTime') AS attributeLongLabel, 
	   ('V_Census_inTime') AS attributeShortLabel, 
	   ('V_Census_inTime') AS attributePropName,
	   ('V_Census_inTime') AS materialPropName
	   
FROM dbo.V_Census res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION 
SELECT res.encounterId,
       res.outTime AS chartTime, -- OVERRIDE
	   res.outTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.outTime,121) AS terseForm, -- OVERRIDE
	   convert(varchar,res.outTime,121) AS verboseForm, -- OVERRIDE
	   ('V_Census_outTime') AS interventionLongLabel,
	   ('V_Census_outTime') AS attributeDictionaryPropName,  
	   ('V_Census_outTime') AS interventionShortLabel,
	   ('V_Census_outTime') AS interventionPropName, 
	   ('V_Census_outTime') AS interventionBaseLongLabel, 
	   ('V_Census_outTime') AS attributeLongLabel, 
	   ('V_Census_outTime') AS attributeShortLabel, 
	   ('V_Census_outTime') AS attributePropName,
	   ('V_Census_outTime') AS materialPropName
	   
FROM dbo.V_Census res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.outTime AS chartTime, -- OVERRIDE
	   res.outTime AS storeTime, -- OVERRIDE
	   res.dischargeDisposition AS terseForm, -- OVERRIDE
	   res.dischargeDisposition AS verboseForm, -- OVERRIDE
	   ('V_Census_dischargeDisposition') AS interventionLongLabel,
	   ('V_Census_dischargeDisposition') AS attributeDictionaryPropName,  
	   ('V_Census_dischargeDisposition') AS interventionShortLabel,
	   ('V_Census_dischargeDisposition') AS interventionPropName, 
	   ('V_Census_dischargeDisposition') AS interventionBaseLongLabel, 
	   ('V_Census_dischargeDisposition') AS attributeLongLabel, 
	   ('V_Census_dischargeDisposition') AS attributeShortLabel, 
	   ('V_Census_dischargeDisposition') AS attributePropName,
	   ('V_Census_dischargeDisposition') AS materialPropName
	   
FROM dbo.V_Census res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
UNION
SELECT res.encounterId,
       res.inTime AS chartTime, -- OVERRIDE
	   res.inTime AS storeTime, -- OVERRIDE
	   convert(varchar,res.dateOfBirth,121) AS terseForm, -- OVERRIDE
	   convert(varchar,res.dateOfBirth,121) AS verboseForm, -- OVERRIDE
	   ('V_Census_dateOfBirth') AS interventionLongLabel,
	   ('V_Census_dateOfBirth') AS attributeDictionaryPropName,  
	   ('V_Census_dateOfBirth') AS interventionShortLabel,
	   ('V_Census_dateOfBirth') AS interventionPropName, 
	   ('V_Census_dateOfBirth') AS interventionBaseLongLabel, 
	   ('V_Census_dateOfBirth') AS attributeLongLabel, 
	   ('V_Census_dateOfBirth') AS attributeShortLabel, 
	   ('V_Census_dateOfBirth') AS attributePropName,
	   ('V_Census_dateOfBirth') AS materialPropName
	   
FROM dbo.V_Census res
WHERE res.encounterid IN (
COMMA_SEPARATED_IDS 
)
ORDER BY interventionPropName, chartTime;