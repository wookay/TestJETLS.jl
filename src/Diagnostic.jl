module Diagnostic # JETLS

using JETLS: JETLS, JS, LSP, filepath2uri

module lowering_module
end

function get_lowering_diagnostics(
        text::AbstractString;
        code::Union{AbstractString,Nothing} = nothing,
        context_module::Module=lowering_module,
        world::UInt = Base.get_world_counter(),
        kwargs...
    )
    filename = abspath(pkgdir(JETLS), "test", "test_lowering_diagnostic.jl")
    server = JETLS.Server()
    uri = filepath2uri(filename)
    fi = JETLS.cache_file_info!(server, uri, 1, text)
    st0_top = JETLS.build_syntax_tree(fi)
    @assert JS.kind(st0_top) === JS.K"toplevel"
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
    return diagnostics
end

end # module JETLS.Diagnostic
