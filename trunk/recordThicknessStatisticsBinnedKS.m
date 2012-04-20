function stats = recordThicknessStatistics(glob, stats, iteration)

    % These two arrays specify the coordinates of the points on the model
    % grid to be analysed for thickness distribution
    %xco = [10,10,10,10,15,25,30,35,40,40,40,40]
    %yco = [10,20,30,40,15,25,30,35,10,20,30,40];
    xco = [25];
    yco = [25];
    totalCols = numel(xco);
    if numel(xco) ~= numel(yco) fprintf('Different column coords in x and y arrays, recordThicknessStatistics\n'); return; end
    %Xstart = 23;
    %YStart = 23;
    %XStop = 27;
    %YStop = 27;
    colCount = 1; % is used as array index so must start from 1

    % Dimension thickness array according to grid size, add one to iteration just in case, and fill with zeros
    %thickness = zeros(1, (iteration+1)* ( ((XStop - XStart)+1) * ((YStop - YStart)+1) ) );
    thickness = zeros(1, (iteration + 1) * (totalCols + 1));
    j = 0; % Counts the lithofacies units

    %for x=XStart:XStop
    %    for y = YStart:YStop
    while colCount-1 < totalCols % To account for colCount increment at end of loop
        
            %prevFacies = glob.faciesProd(y,x,1);
            prevFacies = glob.faciesProd(yco(colCount),xco(colCount),1);
            j = j + 1; % Make sure we start with a new thickness value for each grid cell
            i = 2;

            while i <= iteration

                % Find the next non-zero facies in this column, so skip over any zeros present
                %while i < iteration && glob.faciesProd(y,x,i) == 0
                while i < iteration && glob.faciesProd(yco(colCount),xco(colCount),i) == 0
                    i = i + 1;
                end

                %nextFacies = glob.faciesProd(y,x,i);
                nextFacies = glob.faciesProd(yco(colCount),xco(colCount),i);
                
                if nextFacies ~= prevFacies
                        j = j + 1;
                end

                %oneThickness = glob.strata(y,x,i) - glob.strata(y,x,i-1);
                oneThickness = glob.strata(yco(colCount),xco(colCount),i) -  glob.strata(yco(colCount),xco(colCount),i-1);
               

                % thickness > 0.0001 (to avoid rounding errors being included)
                if oneThickness > 0.00001
                    % Then increment the thickness sum for this unit
                    thickness(j) = thickness(j) + oneThickness;
                    
                    %if x==30 && y==25
                        %fprintf('thickness %7.6f added to layer %d total of %7.6f\n', oneThickness, j, thickness(j));
                    %end
                end

                prevFacies = nextFacies;
                i = i + 1;
            end
            
            colCount = colCount + 1;
        %end
    end

    colCount = colCount - 1; % Correct for final increment
    
    % Strip zero thicknesses, calculate the thickness frequencies and the
    % cumulative frequencies
    thickness = nonzeros(thickness);
    meanThick = mean(thickness);
    maxThick = max(thickness);
    
    thickness = sort(thickness, 'ascend');
    %stats.thicknessBins = 0:0.1:round(maxThick+1);
    fprintf('For %d columns and %d lithofacies units, Min thickness %3.2f m Mean Thickness %4.3f m Max thickness %3.2f\n', colCount, j, min(thickness), meanThick, maxThick);
    
    %thicknessFreq =histc(thickness, stats.thicknessBins);
    %stats.cumThicknessFreq = cumsum(thicknessFreq);
    stats.cumThicknessFreq = cumsum(thickness);
    %maxFreq = max(stats.cumThicknessFreq);
    %stats.cumThicknessFreq = stats.cumThicknessFreq / maxFreq;
    %length(stats.cumThicknessFreq);
    maxFreq = max(stats.cumThickness);
    stats.cumThicknessFreq = stats.cumThickness / maxThick;
    length(stats.cumThickness);

    % Calculate the theoretical cumulative exponential model for comparison
    %n = length(stats.cumThicknessFreq);
    %stats.expCumThicknessFreq = zeros(n,1); % Reset length to make sure same as stats.cumThicknessFreq
    n = length(stats.cumThickness);
    stats.expCumThickness = zeros(n,1); % Reset length to make sure
    %same as stats.cumThicknessFreq
    expParam = 1/meanThick;
    j=1:n;
    %stats.expCumThicknessFreq(j,1) = 1 - exp(-expParam * stats.thicknessBins(j)); % j,1 to make sure just 1 colum of data, same as thickness matrices
    stats.expCumThickness(j,1) = 1 - exp(-expParam * stats.thickness(j)); % j,1 to make sure just 1 colum of data, same as thickness matrices
    
    % Compare the two cumulative distributions using Kolmogorov-Smirnoff
    [stats.D,stats.Dx,stats.p] = ks_test_pmb(stats.cumThicknessFreq, stats.thicknessBins, stats.expCumThicknessFreq, stats.thicknessBins);

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
    
    fName = sprintf('modelOutput\\modelStats_%s.txt', glob.modelName);
    pValsOutput = fopen(fName,'at');
    fprintf(pValsOutput,'%d %d %5.4f %5.4f %5.4f %5.4f %d %5.4f ', glob.subRate / glob.deltaT, glob.prodRate / glob.deltaT, stats.minThickness, stats.meanThickness, stats.maxThickness, stats.D, stats.Dx, stats.p);
    %fprintf(pValsOutput,'%d %d %d %5.4f\n', stats.transitionTotal, stats.aggCount, stats.progCount, stats.aggCount / stats.progCount);
    fclose(pValsOutput);

    % Output the results ...
    outputThick(:,1) = stats.cumThicknessFreq;
    outputThick(:,2) = stats.expCumThicknessFreq;
    %thicknessFName = sprintf('modelOutput\\thicknessDistributions_%s.dat', glob.modelName);
    thicknessFName = sprintf('modelOutput\\thicknessDistributions.dat');
    save(thicknessFName,'outputThick','-ASCII');
end


