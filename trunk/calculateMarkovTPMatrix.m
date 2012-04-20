function stats = calculateMarkovTPMatrix(glob, stats, iteration, x, y)
    
    % Find the maximum facies code used in the facies succession - this is the
    % size for both dimensions of the TP matrix which can now be defined
    nFacies = glob.maxFacies + 1; % Add one because Facies 0 hiatus here will be Facies 8 to avoid array subscript issues
    m1 = 0; % number of transitions, not really needed but never mind
    m2 = 0;
    TFMatrix = zeros(nFacies, nFacies);
    TPMatrix = zeros(nFacies, nFacies);
    colWithHiatus = zeros(iteration*10,1); % Assume up to 10 transport facies per cell - should be much more than needed
    colNoHiatus = zeros(iteration*10,1);
    
    j = 1;
    k = 1;
    % First construct the succession from the produced and transported strata at x y
    for p = 1:iteration-1 % needs to be -1 here because k+1 in array access below
           
        fCode = glob.faciesProd(y,x,p); % Note this is zero for no depositon, 7 for subaerial hiatus
        if fCode > 0
            colNoHiatus(j) = fCode;
            colWithHiatus(k) = fCode;
            j = j + 1;
            k = k + 1;
        else
            colWithHiatus(k) = 8; % reset hiatus from 0 to 8 to avoid array subscript problems in TF & TP matrices
            k = k + 1;
        end;
        
        if sum(glob.faciesTrans{y,x,p}) > 0
            numOfTransFacies = length(glob.faciesTrans{y,x,p});
            for q=1:numOfTransFacies
                fCode = glob.faciesTrans{y,x,p}(q);
                if fCode > 0
                    colNoHiatus(j) = fCode;
                    colWithHiatus(k) = fCode;
                    j = j + 1;
                    k = k + 1;
                end
            end
        end
    end
    
    n1 = j;
    n2 = k;

    % Now loop through the elements in the succession and for each different facies from-to transition,
    % increment the appropriate cell in the matrix
    for j = 1 : n2
        fromFacies = colWithHiatus(j); % Get from and to from the strat column constructed above
        toFacies = colWithHiatus(j+1);
        % mark transitions between different facies
        if fromFacies > 0 && toFacies > 0 && fromFacies ~= toFacies % Make sure facies codes are not zero because zero values would record an error
            TFMatrix(fromFacies, toFacies) = TFMatrix(fromFacies, toFacies) + 1; % increment the appropriate value in the tp matrix
            m1 = m1 + 1;
        end
    end

    %Now calculate the transition probability matrix from the transition frequency
    %matrix
    rowSums=sum(TFMatrix,2); % Calculates the sum of each row in TF matrix and stores as vector rowSums
    for k=1:nFacies
        for j=1:nFacies
            if rowSums(k) > 0 % if rowsum > 0 divide TF value by row sum to get transition probability
                TPMatrix(k,j)=TFMatrix(k,j) / rowSums(k);
            else
                TPMatrix(k,j) = 0;
            end
        end
    end
    
    rowMaxs = max(TPMatrix,[],2);
    rowMins = min(TPMatrix,[],2);
    rowDiffs = rowMaxs - rowMins;
    markovOrderMetricWithHiatus = mean(rowDiffs);
        
    % Output the results ...
%     colWithHiatus(1:100)
%     TFMatrix
%     TPMatrix
    
    TFMatrix = zeros(nFacies, nFacies);
    TPMatrix = zeros(nFacies, nFacies);
    
    % Now loop through the elements in the succession and for each different facies from-to transition,
    % increment the appropriate cell in the matrix
    for j = 1 : n1
        fromFacies = colNoHiatus(j); % Get from and to from the strat column constructed above
        toFacies = colNoHiatus(j+1);
        % mark transitions between different facies
        if fromFacies > 0 && toFacies > 0 && fromFacies ~= toFacies % Make sure facies codes are not zero because zero values would record an error
            TFMatrix(fromFacies, toFacies) = TFMatrix(fromFacies, toFacies) + 1; % increment the appropriate value in the tp matrix
            m2 = m2 + 1;
        end
    end

    %Now calculate the transition probability matrix from the transition frequency
    %matrix
    rowSums=sum(TFMatrix,2); % Calculates the sum of each row in TF matrix and stores as vector rowSums
    for k=1:nFacies
        for j=1:nFacies
            if rowSums(k) > 0 % if rowsum > 0 divide TF value by row sum to get transition probability
                TPMatrix(k,j)=TFMatrix(k,j) / rowSums(k);
            else
                TPMatrix(k,j) = 0;
            end
        end
    end
    
    rowMaxs = max(TPMatrix,[],2);
    rowMins = min(TPMatrix,[],2);
    rowDiffs = rowMaxs - rowMins;
    markovOrderMetricNoHiatuses = mean(rowDiffs);
    
    fprintf('Markov properties: with hiatii %d transitions m=%5.4f without %d transitions m=%5.4f\n', ...
        m1, markovOrderMetricWithHiatus, m2, markovOrderMetricNoHiatuses);
        
    % Output the results ...
%     colNoHiatus(1:100)
%     TFMatrix
%     TPMatrix
    
%     markovFName = sprintf('modelOutput\\markovTPMatrix_%s.dat', glob.modelName);
%     save( markovFName,'TFMatrix','-ASCII');
end


