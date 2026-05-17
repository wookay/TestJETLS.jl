module CodeActions # TestJETLS

# from JETLS/test/test_code_action.jl

using JETLS: JETLS
using .JETLS: LSP, JS, CodeAction, Command
using .LSP.URIs2

module lowering_module
end

function get_lowering_diagnostics(
        text::AbstractString;
        code::Union{AbstractString,Nothing} = nothing,
        context_module::Module = lowering_module,
        world::UInt = Base.get_world_counter(),
        kwargs...
    )
    filename = abspath(pkgdir(JETLS), "test", "test_code_action.jl")
    server = JETLS.Server()
    uri = filepath2uri(filename)
    fi = JETLS.cache_file_info!(server, uri, 1, text)
    st0_top = JETLS.build_syntax_tree(fi)
    diagnostics = LSP.Diagnostic[]
    candidates = JETLS.UndefGlobalCandidate[]
    JETLS.iterate_toplevel_tree(st0_top) do st0::JS.SyntaxTree
        JETLS.per_stmt_diagnostics!(diagnostics, candidates, uri, fi,
            st0, context_module, world, #=analyzer=#nothing, JETLS.LSPostProcessor();
            kwargs...)
    end
    # Mirror the cross-file phase. `skip_context_check=true` because the test server
    # has no populated `analysis_manager` — we want this single file to count as
    # part of its own unit anyway.
    per_file = JETLS.PerFileDiagnosticsResult(diagnostics, candidates)
    JETLS.cross_file_diagnostics!(diagnostics, JETLS.DefUsedNamesCache(),
        server, uri, fi, st0_top, per_file; skip_context_check=true)
    if code !== nothing
        filter!(d -> d.code == code, diagnostics)
    end
    return diagnostics, uri
end

function get_unused_var_code_actions(marked_text::AbstractString; kwargs...)
    text, positions = JETLS.get_text_and_positions(marked_text)
    diagnostics, uri = get_lowering_diagnostics(text; kwargs...)
    code_actions = Union{CodeAction,Command}[]
    JETLS.unused_variable_code_actions!(code_actions, uri, diagnostics; kwargs...)
    return code_actions, uri, positions
end

end # module TestJETLS.CodeActions
