# from JETLS/test/utils/test_jl_syntax_macros.jl
module test_jl_syntax_macros

using Test
using JETLS: JETLS, JL, JS

include(normpath(@__DIR__, "jsjl-utils.jl"))
module lowering_module
end

function jlexpand(mod::Module, code::AbstractString)
    st0 = jlparse(code; rule=:statement)
    world = Base.get_world_counter()
    _, st1 = JL.expand_forms_1(mod, st0, true, world)
    return st1
end
jlexpand(code::AbstractString) = jlexpand(lowering_module, code)

function jlresolve(mod::Module, code::AbstractString)
    st0 = jlparse(code; rule=:statement)
    world = Base.get_world_counter()
    return JETLS.jl_lower_for_scope_resolution(mod, st0, world;
        recover_from_macro_errors=false, convert_closures=true)
end
jlresolve(code::AbstractString) = jlresolve(lowering_module, code)

module test_lowering_module
    using Test
end
test_macro_expand(code::AbstractString) = jlexpand(test_lowering_module, code)
test_macro_lower(code::AbstractString) = jlresolve(test_lowering_module, code)


@testset "Test.@test" begin
    @testset "macro expansion" begin
        # Bare expression: returned unchanged.
        let st1 = test_macro_expand("@test x == 1")
            @test JS.kind(st1) === JS.K"call"
            @test strip(JS.sourcetext(st1)) == "x == 1"
        end

        # Keyword arguments keep only the RHS so the `K"="` node doesn't reach
        # later lowering passes, but identifiers in the RHS still flow through
        # to scope resolution.
        for kw in ("broken=true", "skip=cond", "context=ctx", "atol=0.1")
            let st1 = test_macro_expand("@test x $kw")
                @test JS.kind(st1) === JS.K"block"
                @test all(c -> JS.kind(c) !== JS.K"=", JS.children(st1))
            end
        end
    end
end

end # module test_jl_syntax_macros
