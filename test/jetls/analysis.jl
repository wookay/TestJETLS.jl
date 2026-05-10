# from JETLS/test/analysis/test_TypeAnnotation.jl
module test_jetls_analysis_TypeAnnotation

using Test
using TestJETLS.Analysis: type_annotate, range_of
using JETLS: JETLS
using .JETLS: JS
using .JS: @K_str
using .JETLS: TypeAnnotation as TA
using Core: Const

# Querying just the function name's byte range at the def site used to
# return `Union{typeof(f), Type{typeof(f)}}` because the method's
# argtypes svec lowers to a `core.Typeof(f)` call sharing that range.
# `tmerge_at_range` filters this scaffolding so the user-visible value
# (`Const(f)`) survives intact.
@testset "method-def function name surfaces the value, not Union with Type{T}" begin
    mod = Module()
    @eval mod myfunc(x::Int) = x + 1
    let code = """
        function myfunc(x::Int)
            x + 5
        end
        """
        fi, ctx = type_annotate(code, mod)
        @test fi isa JETLS.FileInfo
        @test ctx isa TA.InferredTreeContext
        rng = range_of(code, "myfunc")
        surface_kind = TA.surface_kind_at_range(ctx, rng)
        @test surface_kind == K"Identifier"
        typ1 = TA.tmerge_at_range(ctx::TA.InferredTreeContext, rng::UnitRange{<:Integer})
        @test typ1 === Const(mod.myfunc)
        typ2 = JETLS.get_type_for_range(ctx, rng)
        @test typ2 === Const(mod.myfunc)
    end
end

end # module test_jetls_analysis_TypeAnnotation
