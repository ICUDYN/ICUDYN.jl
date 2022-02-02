"""
Allowed types for refining values 
"""
RefiningFunctionAllowedValueType = Union{String,Number,Missing,DateTime}

IRefiningFunctionResult = Dict{Symbol,<:RefiningFunctionAllowedValueType}
RefiningFunctionResult = Dict{Symbol,RefiningFunctionAllowedValueType}

IRefinedWindowModuleResults = Dict{Symbol,<:RefiningFunctionAllowedValueType}
RefinedWindowModuleResults = Dict{Symbol,RefiningFunctionAllowedValueType}

RefinedWindow = Dict{Module, RefinedWindowModuleResults}
