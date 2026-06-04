# from JETLS/test/analysis/test_TypeAnnotation.jl
module test_jetls_analysis_TypeAnnotation

using Test
using TestJETLS.Analysis: type_annotate, range_of
using JETLS: JETLS
using .JETLS: JS
using .JS: @K_str
using .JETLS: TypeAnnotation as TA
using .JETLS: get_type_for_range
using Core: Const

module myfunc_module
myfunc(x::Int) = x + 1
end

# from JETLS/test/HierarchicalTestSet.jl
struct HierarchicalTestSet <: Test.AbstractTestSet
    __hierarchical_testset_inner__::Test.DefaultTestSet
end
HierarchicalTestSet(desc::AbstractString; kws...) =
    HierarchicalTestSet(Test.DefaultTestSet(desc; kws...))
Test.record(ts::HierarchicalTestSet, t) = Test.record(ts.__hierarchical_testset_inner__, t)
Test.finish(ts::HierarchicalTestSet) = Test.finish(ts.__hierarchical_testset_inner__)

@testset HierarchicalTestSet "Surface-kind dispatch (get_type_for_range)" begin

        # Querying just the function name's byte range at the def site used to
        # return `Union{typeof(f), Type{typeof(f)}}` because the method's
        # argtypes svec lowers to a `core.Typeof(f)` call sharing that range.
        # `tmerge_at_range` filters this scaffolding so the user-visible value
        # (`Const(f)`) survives intact.
        @testset "method-def function name surfaces the value, not Union with Type{T}" begin
            let code = """
                function myfunc(x::Int)
                    x + 1
                end
                """
                _, ctx = type_annotate(code, myfunc_module)
                typ = get_type_for_range(ctx, range_of(code, "myfunc"))
                @test typ isa Core.Const
                @test typ.val === myfunc_module.myfunc
            end
        end
end

end # module test_jetls_analysis_TypeAnnotation
