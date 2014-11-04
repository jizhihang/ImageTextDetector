function chains = pruneSmallChains(chains)
    % Function to remove small chains if they are contained in a larger
    % chain.
    % Input:
    %       chains: A cell array containing chain components.
    % Output:
    %       chains: A cell array containing non overlapping chains.
    
    for idx=1:size(chains, 1)
        % The chains which were removed will be empty.
        if isempty(chains{idx})
            continue;
        end
        chain = chains{idx};
        for cidx=idx+1:size(chains,1)
            current_chain = chains{cidx};
            union_chain = union(chain, current_chain);
            % If the union is equal to the chain, then get rid of the
            % current chain.
            if isequal(union_chain, chain)
                chains{cidx} = [];
            end
            % If the chain is a subset of current_chain, then we need to
            % get rid of this member and continue.
            if isequal(union_chain, current_chain)
                chains{idx} = [];
                break;
            end
        end
    end
    % Finally, remove those empty chains.
    chains = chains(~cellfun('isempty',chains));
end