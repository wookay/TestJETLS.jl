module test_jetls_code_actions

# from JETLS/test/test_code_action.jl

using Test
using JETLS: LSP
using TestJETLS.CodeActions: get_unused_var_code_actions

@testset "unused variable code actions" begin
    # Unused positional argument: rename action
    let (code_actions, uri, pos) = get_unused_var_code_actions("""
        function f(x, y)
            return x
        end
        """)
        @test length(code_actions) == 1
        action = only(code_actions)
        @test action isa LSP.CodeAction
        @test action.title == "Prefix with '_' to indicate intentionally unused"
        @test action.kind == "quickfix"
        @test action.diagnostics isa Vector{LSP.Diagnostic}
        @test action.isPreferred
        @test action.disabled === nothing
        @test action.edit isa LSP.WorkspaceEdit
        edit = only(action.edit.changes[uri])
        @test edit.newText == "_"
        @test action.command === nothing
        @test action.data === nothing
        @test uri isa LSP.URIs2.URI
        @test pos isa Vector{LSP.Position}
    end
end

end # module test_jetls_code_actions
