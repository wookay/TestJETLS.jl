# from JETLS/test/utils/test_jl_syntax_macros.jl
module test_jetls_test_macro_expand

using Test
using JETLS: JS
using TestJETLS.Utils: test_macro_expand

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

end # module test_jetls_test_macro_expand
