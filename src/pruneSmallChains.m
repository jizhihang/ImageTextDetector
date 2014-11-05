function chains = pruneSmallChains(chains, chainInfo)
    % Function to remove small chains if they are contained in a larger
    % chain.
    % Input:
    %       chains: A cell array containing chain components.
    %       chainInfo: Bounding box information for the chain
    %               It is N x 4 where N is the number of chains
    %               Format: [minRow, maxRow, minCol, maxCol]
    %
    % Output:
    %       chains: A cell array containing non overlapping chains.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters to be adjusted for pruning
    offsetThreshold = 10; % Allowed discrepency for comparing bounding boxes

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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

            % Additional geometry constraints to prune overlapping chains
            % Prune the smaller chain if one of them is inside the other

            % cidx is contained in idx row-wise
            if(chainInfo(idx, 1) < chainInfo(cidx, 1) && chainInfo(idx, 2) > chainInfo(cidx, 2) ...
                && abs(chainInfo(idx, 3) - chainInfo(cidx, 3)) < offsetThreshold ... 
                && abs(chainInfo(idx, 4) - chainInfo(cidx, 4)) < offsetThreshold)
                chains{cidx} = [];
            end
            % idx is contained in idx row-wise
            if(chainInfo(idx, 1) > chainInfo(cidx, 1) && chainInfo(idx, 2) < chainInfo(cidx, 2) ...
                && abs(chainInfo(idx, 3) - chainInfo(cidx, 3)) < offsetThreshold ... 
                && abs(chainInfo(idx, 4) - chainInfo(cidx, 4)) < offsetThreshold)
                chains{idx} = [];
                break;
            end

            % cidx is contained in idx column-wise
            if(chainInfo(idx, 3) < chainInfo(cidx, 3) && chainInfo(idx, 4) > chainInfo(cidx, 4) ...
                && abs(chainInfo(idx, 1) - chainInfo(cidx, 1)) < offsetThreshold ... 
                && abs(chainInfo(idx, 2) - chainInfo(cidx, 2)) < offsetThreshold)
                chains{cidx} = [];
            end
            % idx is contained in idx column-wise
            if(chainInfo(idx, 3) > chainInfo(cidx, 3) && chainInfo(idx, 4) < chainInfo(cidx, 4) ...
                && abs(chainInfo(idx, 1) - chainInfo(cidx, 1)) < offsetThreshold ... 
                && abs(chainInfo(idx, 2) - chainInfo(cidx, 2)) < offsetThreshold)
                chains{idx} = [];
                break;
            end

            % Addding the uniqueness constaint to components
            % Each component can belong onto only one chain
            % Conflicts are resolved by eliminating smaller chains agaisnt the longest number of component chain
            % Very restrictive and can lead to missed detections - lets see the performance and ignore/consider
            % this section accordingly 
            if(length(intersect(chains{cidx}, chains{idx})) > 0)
                % idx chain is longer and hence the priority
                if(length(chains{idx}) > length(chains{cidx}))
                    chains{cidx} = [];
                else
                % cidx chain is longer and hence the priority
                    chains{idx} = [];
                    break;
                end
            end

            %fprintf('%d %d %d %d \n %d %d %d %d \n\n\n', chainInfo(idx, :), chainInfo(cidx , :)); 
        end
    end

    % Finally, remove those empty chains.
    chains = chains(~cellfun('isempty',chains));
    length(chains)
end
