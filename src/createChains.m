function [chains] = createChains(grouping, angles)
    % Create chain of components based on a certain set of rules. 
    % Input:
    %       groups: an NXN binary matrix. where groups(i,j) = 1 if the
    %               components i and j are compatible.
    %       angles: an NXN matrix, where angles{i,j} is the angle of each
    %               pair of components which form a group.
    % Output:
    %       chains: A cell of component numbers, where each cell contains
    %               the number of the components which form a chain.
    
    angleThreshold = pi/12;
    % We now need to create chain of letters based on the angle of the
    % component pair.
    
    % At this stage, we have the pairs of components which are similar and
    % the "angle" of each component pair.
    
    % Initially we have o.4*numel(groups)
    groups = triu(grouping);    
    % Each group is a chain initially
    [x, y] = find(groups == 1);
    points_matrix = [x, y];
    nsplits = ones(1, length(x));
    chains = mat2cell(points_matrix, nsplits, 2);
    
    % Iteratively combine components till the old_chains is same as chains.
    while true
        new_chains = {};
        % Compare each chain with every other chain to see if we can form a
        % new chain.
        new_chain_idx = 1;
        for idx=1:1:size(chains, 1)
            chain = chains{idx};
            angle = angles(chain(1,end), chain(1,end-1));
            last_new_idx = new_chain_idx;
            for iidx =idx:1:size(chains,1)
                current_chain = chains{iidx};
                % The last component of the first chain and the first
                % component of the second chain match. 
                if chain(1, end) == current_chain(1,1)
                    % Now check for angles.
                    current_angle = angles(current_chain(1,1), ...
                                           current_chain(1,2));
                    if abs(angle - current_angle) < angleThreshold
                        new_chains{new_chain_idx, 1} = [chain(1, 1:end-1) ...
                                                     current_chain];
                        new_chain_idx = new_chain_idx + 1;
                    end
                end                    
            end
            if last_new_idx == new_chain_idx;
                new_chains{new_chain_idx, 1} = chain;
                new_chain_idx = new_chain_idx + 1;
            end
        end
        % Chains don't change anymore. Stop.
        if isequal(chains, new_chains)
            break;
        end
        % Chains have changed. Discard the old chain and store the new
        % chain.
        chains = new_chains;
    end
end