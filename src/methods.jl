# TODO [efficiency]: Make RangeTrees self-balancing?
# TODO [docs]

using DataStructures

#=
    Insertion.
=#

function Base.insert!(root::Union{RangeNode, Nothing}, interval::UnitRange, data::T) where T
    if isnothing(root)
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

# TODO: Check why it inserts the same node twice.
function Base.insert!(root::Union{RangeNode, Nothing}, node::RangeNode)
    if isnothing(root)
        return node
    end

    left = root.left
    right = root.right
    interval = node.interval
    if interval.start < root.interval.start
        if isnothing(left)
            root.left = node
        elseif left.interval.start == interval.start && left.interval.stop == interval.stop
            # @info "Node already exists -- updating data. -- left" node
            root.left.data = node.data

            return root
        else
            insert!(root.left, node)
        end
    else
        if isnothing(right)
            root.right = node
        elseif right.interval.start == interval.start && right.interval.stop == interval.stop
            # @info "Node already exists -- updating data. -- right" node
            root.right.data = node.data

            return root
        else
            insert!(root.right, node)
        end
    end

    if root.max < interval.stop
        root.max = interval.stop
    end

    return root
end

#=
    Search.
=#

function Base.:(==)(node1::RangeNode, node2::RangeNode)
    if (isnothing(node1) || isnothing(node2))             ||
    (isnothing(node1.parent) && !isnothing(node2.parent)) ||
    (node1.interval != node2.interval)                    ||
    (node1.max != node2.max)                              ||
    (node1.data != node2.data)                            ||
    (treesize(node1) != treesize(node2))
        return false
    end

    st = Stack{Tuple{RangeNode, RangeNode}}()
    if !isnothing(node1.left)
        if isnothing(node2.left)
            # `node1.left` exists but `node2.left` doesn't.
            return false
        end
        # Both `node1.left` and `node2.left` exist.
        push!(st, zip(PostOrderDFS(node1.left), PostOrderDFS(node2.left))...)
    elseif !isnothing(node2.left)
        # `node2.left` exists but `node1.left` doesn't.
        return false
    end
    if !isnothing(node1.right)
        if isnothing(node2.right)
            # `node1.right` exists but `node2.right` doesn't.
            return false
        end
        # Both `node1.right` and `node2.right` exist.
        push!(st, zip(PostOrderDFS(node1.right), PostOrderDFS(node2.right))...)
    elseif !isnothing(node2.right)
        # `node2.right` exists but `node1.right` doesn't.
        return false
    end

    while !isempty(st)
        n1, n2 = pop!(st)

        if (isnothing(n1) || isnothing(n2))             ||
        (isnothing(n1.parent) && !isnothing(n2.parent)) ||
        (n1.interval != n2.interval)                    ||
        (n1.max != n2.max)                              ||
        (n1.data != n2.data)                            ||
        (treesize(n1) != treesize(n2))
            return false
        end
    end

    return true
end

# function findnode(root::Union{RangeNode, Nothing}, node::RangeNode)
#     if isnothing(root)
#         return nothing
#     end


# end
