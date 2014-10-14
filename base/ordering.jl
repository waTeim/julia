module Order

## notions of element ordering ##

export # not exported by Base
    Ordering, Forward, Reverse, Lexicographic,
    By, Lt, Perm,
    ReverseOrdering, ForwardOrdering, LexicographicOrdering,
    DirectOrdering,
    lt, ord, ordtype

abstract Ordering

immutable ForwardOrdering <: Ordering end
immutable ReverseOrdering{Fwd<:Ordering} <: Ordering
    fwd::Fwd
end

ReverseOrdering(rev::ReverseOrdering) = rev.fwd
ReverseOrdering{Fwd}(fwd::Fwd) = ReverseOrdering{Fwd}(fwd)

typealias DirectOrdering Union(ForwardOrdering,ReverseOrdering{ForwardOrdering})

const Forward = ForwardOrdering()
const Reverse = ReverseOrdering(Forward)

immutable LexicographicOrdering <: Ordering end
const Lexicographic = LexicographicOrdering()

immutable By <: Ordering
    by::Function
end

immutable Lt <: Ordering
    lt::Function
end

immutable Perm{O<:Ordering,V<:AbstractVector} <: Ordering
    order::O
    data::V
end
Perm{O<:Ordering,V<:AbstractVector}(o::O,v::V) = Perm{O,V}(o,v)

lt(o::ForwardOrdering,       a, b) = isless(a,b)
lt(o::ReverseOrdering,       a, b) = lt(o.fwd,b,a)
lt(o::By,                    a, b) = isless(o.by(a),o.by(b))
lt(o::Lt,                    a, b) = o.lt(a,b)
lt(o::LexicographicOrdering, a, b) = lexcmp(a,b) < 0

function lt(p::Perm, a::Int, b::Int)
    da = p.data[a]
    db = p.data[b]
    lt(p.order, da, db) | (!lt(p.order, db, da) & (a < b))
end
function lt(p::Perm{LexicographicOrdering}, a::Int, b::Int)
    c = lexcmp(p.data[a], p.data[b])
    c != 0 ? c < 0 : a < b
end

ordtype(o::ReverseOrdering, vs::AbstractArray) = ordtype(o.fwd, vs)
ordtype(o::Perm,            vs::AbstractArray) = ordtype(o.order, o.data)
# TODO: here, we really want the return type of o.by, without calling it
ordtype(o::By,              vs::AbstractArray) = try typeof(o.by(vs[1])) catch; Any end
ordtype(o::Ordering,        vs::AbstractArray) = eltype(vs)

function ord(lt::Function, by::Function, rev::Bool, order::Ordering=Forward)
    o = (lt===isless) & (by===identity) ? order  :
        (lt===isless) & (by!==identity) ? By(by) :
        (lt!==isless) & (by===identity) ? Lt(lt) :
                                          Lt((x,y)->lt(by(x),by(y)))
    rev ? ReverseOrdering(o) : o
end

end
