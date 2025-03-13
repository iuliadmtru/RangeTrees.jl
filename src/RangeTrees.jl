module RangeTrees

# Existing similar package: https://github.com/BioJulia/IntervalTrees.jl. Not maintained, outdated.
# Might be useful: https://github.com/JuliaMath/IntervalSets.jl

export RangeNode

using AbstractTrees

#=
    Definition and constructors.
=#

mutable struct RangeNode{T} <: AbstractNode{T}
    interval::UnitRange # Should keep `low` and `high` instead?
    left::Union{RangeNode, Nothing}
    right::Union{RangeNode, Nothing}
    parent::Union{RangeNode, Nothing}
    max::Int
    data::T # Extra data. In our case, the corresponding `GreenNode`.
end

function RangeNode(interval::UnitRange, parent::RangeNode, data::T) where T
    return RangeNode(
        interval,
        nothing,
        nothing,
        parent,
        interval.stop,
        data
    )
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
    Tree manipulation.
=#

function Base.insert!(root::Union{RangeNode, Nothing}, interval::UnitRange, data::T) where T
    if isnothing(root)
        @info "Here"
        return RangeNode(interval, data)
    end

    left = root.left
    right = root.right
    if interval.start < root.interval.start
        if isnothing(left)
            root.left = RangeNode(interval, root, data)
        elseif left.interval.start == interval.start && left.interval.stop == interval.stop
            @info "Interval $interval already exists."
            return root
        else
            insert!(root.left, interval, data)
        end
    else
        if isnothing(right)
            root.right = RangeNode(interval, root, data)
        elseif right.interval.start == interval.start && right.interval.stop == interval.stop
            @info "Interval $interval already exists."
            return root
        else
            insert!(root.right, interval, data)
        end
    end

    if root.max < interval.stop
        root.max = interval.stop
    end

    return root
end

end # module RangeTrees
