module test_jetls_code_lens

# from JETLS/test/test_code_lens.jl

using Test
using JETLS: LSP
using TestJETLS.HandleCodeLens: get_code_lenses_with_counts

@testset "function with multiple references" begin
    let code = """
        function foo(x)
            x + 1
        end
        a = foo(1)
        b = foo(2)
        c = foo(3)
        """
        results = get_code_lenses_with_counts(code)
        @test length(results) == 1
        lens, count = results[1]
        @test lens isa LSP.CodeLens
        @test count ≥ 3
    end
end

end # module test_jetls_code_lens
