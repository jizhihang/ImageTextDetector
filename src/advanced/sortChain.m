function sortedChain = sortChain(chain, compFeat)
    % Function to sort the chains such that consecutive components in the
    % image are also consecutive in the chain array.
    % 
    % Input:
    %       chain: Input 1D array containing the chain members.
    %       compFeat: Cell of features of each component.
    %
    % Output:
    %       sortedChains: The final sorted chain array.

    nMembers = length(chain);
    Y = zeros(nMembers, 1);
    X = zeros(nMembers, 1);

    for idx=1:nMembers
        component = compFeat{chain(idx)};
        center = component.center;
        Y(idx, 1) = center(2);
        X(idx, 1) = center(1);
    end
    P = polyfit(X', Y', 1);
    m = -1/P(1);
    constArray = Y - m*X(:,1);

    [sorted, indices] = sort(constArray);
    
    sortedChain = chain(indices);
end
