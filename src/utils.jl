@def_singleton unspecified::Unspecified
default_to(value, _) = value
default_to(::Unspecified, default) = default

"""
    FoldsInit(op)

Like `Transducers.DefaultInit`, but only for Folds.jl. This is used instead
of `DefaultInit` so that we can call `reduce_empty` manually. This should
probably be merged to Transducers.jl (or stop using `reduce_empty`).
"""
FoldsInit
struct FoldsInitOf{OP} <: SpecificInitialValue{OP} end
@def_singleton FoldsInit = InitOf{FoldsInitOf}()

function bottom_foldable(itr)
    _xf, foldable = extract_transducer(itr)
    return foldable
end

without_basesize(; basesize = nothing, kw...) = kw

struct ConvertTo{T} end
@inline (::ConvertTo{T})(x) where {T} = convert(T, x)
ConvertTo(::Type{T}) where {T} = ConvertTo{T}()
# ConvertTo(::T) where {T} = ConvertTo{T}()

"""
    de_snoc(butlast..., last) -> (butlast, last)
"""
@inline function de_snoc(x, xs...)
    butlast, last = de_snoc(xs...)
    return (x, butlast...), last
end
@inline de_snoc(x) = (), x

parallel_executor(xs; kwargs...) = executor_for(xs, PreferParallel(; kwargs...))

# TODO: something like these should be in the interface
get_basesize(ex) = get(ex.kwargs, :basesize, nothing)
set_basesize(ex, basesize) = @set ex.kwargs = (; ex.kwargs..., basesize = basesize)

# https://github.com/JuliaLang/julia/pull/33533
if VERSION < v"1.4"
    const PartitionableArray = Vector
else
    const PartitionableArray = AbstractArray
end

_isunordered(x) = false
_isunordered(x::AbstractFloat) = isnan(x)
_isunordered(x::Missing) = true

if !isdefined(Base, :isunordered)
    const isunordered = _isunordered
end

# Vendoering Julia 1.7's definition of `isgreater`:
isgreater(x, y) = isunordered(x) || isunordered(y) ? isless(x, y) : isless(y, x)

@noinline some_bool() = _non_existing_variable_::Bool
@noinline unreachable() = error("unreachable")

function some_item(itr)
    for x in itr
        some_bool() && return x
    end
    unreachable()
end

# The result of this function must not leak outside the public function boundary.
@inline infer_eltype(::T) where {T} = infer_eltype(T)
@inline infer_eltype(::Type{T}) where {T} = Core.Compiler.return_type(some_item, Tuple{T})
