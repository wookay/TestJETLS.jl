module test_jetls_completions

using Test
using TestJETLS.Completions: test_single_cv

@testset "sanity" begin
    snippets = [
        "let x = 1;                  │  end",
        "let; (y,(x,z)) = (2,(1,3))  │  end",
        "function f(x);              │  end",
        "function f(x...);           │  end",
        "function f(a::x) where x;   │  end",
        "let; global x;              │  end",
        "for x in 1:10;              │  end",
        "map([]) do x;               │  end",
        "(x ->                       │   1)",
    ]
    for code in snippets
        test_single_cv(code, ["x"])
        test_single_cv(code, String[]; unexpected = ["fafo"])
    end
end

end # module test_jetls_completions
