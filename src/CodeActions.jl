module CodeActions # TestJETLS

using JETLS: JETLS
using .JETLS: LSP, JS, CodeAction, Command
using .LSP.URIs2

module lowering_module
end

function get_lowering_diagnostics(
        text::AbstractString, code::Union{AbstractString,Nothing} = nothing;
        mod::Module = lowering_module, kwargs...
    )
    filename = abspath(pkgdir(JETLS), "test", "test_code_action.jl")
    fi = JETLS.FileInfo(#=version=#0, text, filename)
    uri = filepath2uri(filename)
    st0_top = JETLS.build_syntax_tree(fi)
    diagnostics = LSP.Diagnostic[]
    JETLS.iterate_toplevel_tree(st0_top) do st0::JS.SyntaxTree
        JETLS.lowering_diagnostics!(diagnostics, uri, fi, mod, st0; kwargs...)
    end
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
