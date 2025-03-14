module RangeTrees

# Existing similar package: https://github.com/BioJulia/IntervalTrees.jl. Not maintained, outdated.
# Might be useful: https://github.com/JuliaMath/IntervalSets.jl

export RangeNode

using AbstractTrees

#=
    Definition and constructors.
=#

# TODO [docs]

mutable struct RangeNode{T} <: AbstractNode{T}
    interval::UnitRange # Should keep `low` and `high` instead?
    left::Union{RangeNode, Nothing}
    right::Union{RangeNode, Nothing}
    parent::Union{RangeNode, Nothing}
    max::Int
    data::T # [optional] Extra data to store in the node.
end

function RangeNode(interval::UnitRange, parent::Union{RangeNode, Nothing}, data::T) where T
    new_node = RangeNode(
        interval,
        nothing,
        nothing,
        parent,
        interval.stop,
        data
    )
    insert!(parent, new_node)

    return new_node
end
RangeNode(interval::UnitRange, parent::RangeNode) = RangeNode(interval, parent, nothing)

function RangeNode(interval::UnitRange, data::T) where T
    return RangeNode(
        interval,
        nothing,
        nothing,
        nothing,
        interval.stop,
        data
    )
end
RangeNode(interval::UnitRange) = RangeNode(interval, nothing)

#=
    Getters and setters.
=#

AbstractTrees.children(node::RangeNode) = [node.left, node.right]

AbstractTrees.nodevalue(node::RangeNode) = node.interval

AbstractTrees.ParentLinks(::RangeNode) = AbstractTrees.StoredParents()
AbstractTrees.parent(node::RangeNode) = node.parent

nodedata(node::RangeNode) = node.data

#=
    Tree manipulation: insertion, deletion?, search
=#

include("methods.jl")

end # module RangeTrees
