function stats = recordThicknessStatistics(glob, stats, iteration)

    % These two arrays specify the coordinates of the points on the model
    % grid to be analysed for thickness distribution
    xco = 25;
    yco = 30;
    totalCols = numel(xco);
    if numel(xco) ~= numel(yco) fprintf('Different column coords in x and y arrays, recordThicknessStatistics\n'); return; end
    colCount = 1; % is used as array index so must start from 1
    deposCount = 0;
    hiatusCount = 0;
    
    % Dimension thickness array according to grid size, allowing for up to 5 lithologies
    % per cell 
    thickness = zeros(1, (iteration * 5));
    facies = zeros(1, (iteration * 5));
    j = 0; % Counts the lithofacies units

    % Loop throughthe columns specified in xco & yco
    while colCount-1 < totalCols % NB -1 to account for colCount increment at end of loop
        
        % First calculate the stratigraphic completeness
        for j = 1:iteration
            if glob.faciesProd(yco,xco,j) > 0 && glob.faciesProd(yco,xco,j) < 7
                deposCount = deposCount + 1;
            else
                hiatusCount = hiatusCount + 1;
            end
        end
        
        prevFacies = glob.faciesProd(yco,xco,2); % Because it 2 is the first accumulated thickness
        j = 1; % Make sure we start with a new thickness value for each grid cell
        i = 2;
        m = 1;

        while i <= iteration

            % Find the next non-hiatus facies in this column, so skip over any zeros present
%             while i < iteration && (glob.faciesProd(yco,xco,i) == 0 || glob.faciesProd(yco,xco,i) == 7)
%                 i = i + 1;
%             end

%             nextFacies = glob.faciesProd(yco(colCount),xco(colCount),i+1);
%             if nextFacies ~= prevFacies || sum(glob.faciesTrans{yco(colCount),xco(colCount),i}) > 0
%                     m = m + 1;
%             end

            
            oneThickness = glob.faciesProdThick(yco,xco,i);
            % if thickness > 0.0001 (to avoid rounding errors being included) and not a
            % hiatus, record the thickness and facies (the latter not actually used apart
            % from for debugging
            if oneThickness > 0.00001 && prevFacies > 0 && prevFacies < 7 
                thickness(m) = thickness(m) + oneThickness;
                facies(m) = prevFacies;
            end
            
            nextFacies = glob.faciesProd(yco,xco,i+1);
            if (nextFacies ~= prevFacies && nextFacies > 0 && nextFacies < 7) || sum(glob.faciesTrans{yco,xco,i}) > 0
                    m = m + 1;
            end

            %fprintf('%d (%d %d) Prev %d next %d Trans %d\n', i, m, facies(m), prevFacies, nextFacies, glob.faciesTrans{yco,xco,i});
            
            prevFacies = nextFacies;
            i = i + 1;
        end

        % Now record the thicknesses of the transported facies
        % NB Since each transported unit is an event unit we assume that each unit is a
        % seperate identifiable lithofacies unit
        m = m + 1; % Going to record thicknesses in the same array so increment to avoid any overwrite
        
        i = 2;
        k = 1;
        
        while i <= iteration
            if sum(glob.faciesTrans{yco,xco,i}) > 0 % Some transported strata in list cell i
                numOfTransFacies = length(glob.faciesTrans{yco,xco,i});
                for k=1:numOfTransFacies
                    thickness(m) = thickness(m) + glob.faciesTransThick{yco,xco,i}(k);
                    facies(m) = glob.faciesTrans{yco,xco,i}(k); 
                    m = m + 1;
                end
            end
            i = i + 1;
        end

%         thickness
%         facies

% This is a draft of alternative code to work out thickenss of merged units
% NB This code HAS NOT BEEN TESTED AT ALL, JUST WRITTEN AS IS
%        prevFacies = 0;
%         while i <= iteration
%             if sum(glob.faciesTrans{yco(colCount),xco(colCount),i}) > 0 % Some transported strata in list cell i
%                 numOfTransFacies = length(glob.faciesTrans{y,x,i});
%                 for k=1:numOfTransFacies
%                     if glob.faciesTrans{yco(colCount),xco(colCount),i}(k) == prevFacies
%                         thickness(m) = thickness(m) + glob.faciesTransThick{yco(colCount),xco(colCount),i}(k);
%                     else
%                         prevFacies = glob.faciesTrans{yco(colCount),xco(colCount),i}(k);
%                         m = m + 1;
%                     end
%                 end
%             end
%         end
        
         colCount = colCount + 1;
   
    end

    stats.stratCompleteness = deposCount / (deposCount + hiatusCount);
    fprintf('Total depositional layers %d Total hiatii %d Stratigraphic completeness %5.4f\n', deposCount, hiatusCount, stats.stratCompleteness);
    colCount = colCount - 1; % Correct for final increment
    
    % Strip zero thicknesses, calculate the thickness frequencies and the
    % cumulative frequencies
    thickness = nonzeros(thickness);
    meanThick = mean(thickness);
    maxThick = max(thickness);
    fprintf('For %d columns and %d lithofacies units, Min thickness %5.4f m Mean Thickness %5.4f m Max thickness %5.4f\n', colCount, j, min(thickness), meanThick, maxThick);
    
    stats.thickness = sort(thickness, 'ascend'); % Sort ascending ready to calculate cumulative thicknesses
    stats.cumThickness = cumsum(stats.thickness); % Calculate cumulative thicknesses
    maxCumThick = max(stats.cumThickness);
    n = length(stats.cumThickness);
    for j = 1:n;
        stats.cumThickness(j,1) = stats.cumThickness(j,1) / maxCumThick;
    end
    
    % Calculate the theoretical cumulative exponential model for comparison
    stats.expCumThickness = zeros(n,1); % Reset length to make sure same as stats.cumThicknessFreq
    expParam = 1/meanThick;
    for j = 1:n;
        stats.expCumThickness(j,1) = 1 - exp(-expParam * stats.thickness(j,1)); % j,1 to make sure just 1 colum of data, same as thickness matrices
    end
    
    % Compare the two cumulative distributions using Kolmogorov-Smirnoff
    % Note that the original thickness data are the x axis data for both
    % the "observed" CarboCAT distribution and the exponential model
    [stats.D,stats.Dx,stats.p] = ks_test_pmb(stats.cumThickness, stats.thickness, stats.expCumThickness, stats.thickness);

    fprintf('Max difference %5.4f found at x=%d gives p=%6.5f\n', stats.D, stats.Dx, stats.p);

    if stats.p>0.10 
        fprintf('p>0.10 Exponential\n');
    else if stats.p >0.01
        fprintf('0.10>p>0.01 Indeterminate\n');
    else 
        fprintf('p<=0.01 Not exponential\n');
        end
    end

    stats.minThickness = min(thickness);
    stats.meanThickness = mean(thickness);
    stats.maxThickness = max(thickness);

    % Output the results ...
%     outputThick(:,1) = stats.thickness;
%     outputThick(:,2) = stats.cumThickness;
%     outputThick(:,3) = stats.expCumThickness;
%     thicknessFName = sprintf('modelOutput\\thicknessDistrib_%s.dat', glob.modelName);
%     save(thicknessFName,'outputThick','-ASCII');
end


