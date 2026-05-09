using Jive

skip = split("""
    jetls/jsjl-utils.jl
""")

runtests(@__DIR__; skip)
