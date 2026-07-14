module HandleCodeLens # TestJETLS

using JETLS: JETLS
using .JETLS: CodeLens, ReferencesCodeLensData, Position
using .JETLS.URIs2

# from JETLS/test/test_code_lens.jl

function get_code_lenses_with_counts(code::AbstractString)
    server = JETLS.Server()
    uri = URI("file:///test.jl")
    fi = JETLS.FileInfo(#=version=#0, code, "test.jl")
    JETLS.store!(server.state.file_cache) do cache
        Base.PersistentDict(cache, uri => fi), nothing
    end
    code_lenses = CodeLens[]
    JETLS.references_code_lenses!(code_lenses, server.state, uri, fi)
    results = Tuple{CodeLens,Int}[]
    for lens in code_lenses
        data = lens.data::ReferencesCodeLensData
        pos = Position(; line = data.line, character = data.character)
        locations = JETLS.find_references(server, uri, fi, pos;
            include_declaration = false)
        count = locations isa Vector ? length(locations) : 0
        push!(results, (lens, count))
    end
    return results
end

end # module TestJETLS.HandleCodeLens
