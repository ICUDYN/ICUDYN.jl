"""
Allowed types for refining values
"""
RefiningFunctionAllowedValueType = Union{
    String,
    Number,
    Missing,
    DateTime,
    Dict{Symbol,<:RefiningFunctionAllowedValueType}
}

IRefiningFunctionResult = Dict{Symbol,<:RefiningFunctionAllowedValueType}
RefiningFunctionResult = Dict{Symbol,RefiningFunctionAllowedValueType}

IRefinedWindowModuleResults = Dict{Symbol,<:RefiningFunctionAllowedValueType}
RefinedWindowModuleResults = Dict{Symbol,RefiningFunctionAllowedValueType}

RefinedWindow = Dict{Module, RefinedWindowModuleResults}

RefinedHistory = Union{DataFrame,Missing}
