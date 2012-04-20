function [glob] = calculateFaciesCA(glob, iteration, order)
% Calculate the facies cellular automata according to neighbour rules in
% glob.CARules and modify production rate modifier for each cell according
% to number of neighbours

    % To avoid bias, facies must be dealt with in different order
    % each time, hence orderArray
    % But note, with variable iteration rate across the grid, this might become
    % unecessary since variable it rate will sufficient variability to avoid
    % bias
    orderArray = [1,2,3; 2,3,1; 3,1,2];

    j = iteration - 1;
    k = iteration;
    % Neighbours contains a count of neighbours for each facies at each grid
    % point and is populated by the countAllNeighbours function
    neighbours = zeros(glob.ySize, glob.xSize, glob.maxFacies);
    neighbours = countAllNeighbours(glob, j, neighbours);
    glob.faciesProdAdjust = zeros(glob.ySize, glob.xSize);

    for y = 1 : glob.ySize;
       for x= 1 : glob.xSize;
           
           % only do anything here if the latest stratal surface is below sea-level, i.e.
           % water depth > 0.001
           if glob.wd(y,x,iteration) > 0.001

               % Get the facies currently present at y x for previous iteration
                oneFacies = glob.faciesProd(y,x,j);
               
                if oneFacies == 7 % So a subaerial hiatus, now reflooded because from above wd > 0
                    glob.faciesProd(y,x,k) = findPreHiatusFacies(glob, x,y,iteration);

                % For cells already containing producing facies
                elseif (oneFacies > 0 && oneFacies <= glob.maxProdFacies)

                        % Check if neighbours is less than min for survival CARules(i,2) or 
                        % greater than max for survival CARules(i,3), or if water depth is greater than production cutoff and if so kiil
                        % that facies
                        if (neighbours(y,x,oneFacies) < glob.CARules(oneFacies,2) || neighbours(y,x,oneFacies) > glob.CARules(oneFacies,3) || glob.wd(y,x,iteration) >= glob.prodRateWDCutOff(oneFacies)) 
                            glob.faciesProd(y,x,k) = 0;
                        else % Otherwise if right number of neighbours facies persists
                            glob.faciesProd(y,x,k) = oneFacies;
                        end

                else % Otherwise cell must be empty or contain transported product so see if it can be colonised with a producing facies
                     % Note that we do not want iteration count to apply to empty cells,
                     % hence this else

                    for m = 1:glob.maxProdFacies % Loop through all the facies

                        % Select a facies number from the order array. Remember this makes
                        % sure that facies occurrence in adjacent cells is checked in a
                        % different order each time step
                        p = orderArray(order, m);

                        % Check if number of neighbours is within range to trigger new
                        % facies cell, and only allow new cell if the water depth is less
                        % the production cut off depth
                        if (neighbours(y,x,p) >= glob.CARules(p,4)) && (neighbours(y,x,p) <= glob.CARules(p,5) && glob.wd(y,x,iteration) < glob.prodRateWDCutOff(p))
                            glob.faciesProd(y,x,k) = p; % new facies cell triggered at y,x
                            
                        end
                    end
                end

                % Finally, calculate the production adjustment factor for the current facies distribution
                % Production adjustment is calculated based on
                % the number of neighbours for this cell, which has already been 
                % calculated at the start of this function. 
                % Note calculation of prod adjust needs to be done regardless of
                % iteration count at y x because surrounding cells may have
                % iterated and their count changed

                oneFacies = glob.faciesProd(y,x,k);

                if oneFacies > 0 && oneFacies <= glob.maxProdFacies
                    if (neighbours(y,x,oneFacies) < glob.prodScaleMin(oneFacies)) % So fewer than minimum neighbours
                        glob.faciesProdAdjust(y,x) = 0.0;
                    elseif (neighbours(y,x,oneFacies) <= glob.prodScaleOptimum(oneFacies)) % More than min, fewer than optimum
                        glob.faciesProdAdjust(y,x) = (neighbours(y,x,oneFacies)-glob.prodScaleMin(oneFacies)+1)/glob.prodScaleLowerRange(oneFacies);
                        
                    elseif (neighbours(y,x,oneFacies) <= glob.prodScaleMax(oneFacies)) % More than optimum, fewer than max
                        glob.faciesProdAdjust(y,x) = (glob.prodScaleMax(oneFacies) + 1 - neighbours(y,x,oneFacies))/glob.prodScaleUpperRange(oneFacies);
                        
                    else % More than maximum number of neighbours
                        glob.faciesProdAdjust(y,x) = 0.0; 
                    end
                end
           else
                glob.faciesProd(y,x,k) = 7; % Set to above sea-level facies because must be at or above sea-level
           end
       end
    end
end

function count = countSameFaciesNeighbours(glob, xco, yco, j, oneFacies)

    radius = glob.CARules(oneFacies,1);
    count = 0;

    for l = -radius : radius;  
        for m = -radius : radius;

            % Need separate variables for x and y from loop about because x and
            % y might change when wrapped on boundaries so cannot be used as
            % loop indices
            y = yco + l;
            x = xco + m;

            if (y < 1) y = glob.ySize; end
            if (y > glob.ySize) y = 1; end
            if (x < 1) x = glob.xSize; end
            if (x > glob.xSize) x = 1; end

            % If the neighbouring facies is the trigger facies add one to count
            if (glob.faciesProd(y,x,j) == glob.CARules(oneFacies,6))
                count = count + 1;
            end
        end
    end
end

function [neighbours] = countAllNeighbours(glob, j, neighbours)
% Function to count the number of cells within radius containing facies 1
% to maxFacies across the whole grid and store results in neihgbours matrix

    radius = 2; % glob.CARules(oneFacies,1); % needs to be fixed because same loop for all facies

    for yco = 1 : glob.ySize;
       for xco = 1 : glob.xSize;

            for l = -radius : radius;  
                for m = -radius : radius;

                    % Need seperate variables for x and y from loop about because x and
                    % y might change when wrapped on boundaries so cannot be used as
                    % loop indices
                    y = yco + l;
                    x = xco + m;

                    % Wrapping boundary condition on the grid margins
                    if (y < 1) y = glob.ySize; end
                    if (y > glob.ySize) y = 1; end
                    if (x < 1) x = glob.xSize; end
                    if (x > glob.xSize) x = 1; end

                    oneFacies = glob.faciesProd(y,x,j);

                    % Count producing facies as neighbours but do not include the center cell -
                    % neighbours count should not include itself
                    if oneFacies > 0 && oneFacies <= glob.maxProdFacies && not (l == 0 && m == 0)
                        neighbours(yco,xco,oneFacies) = neighbours(yco,xco,oneFacies) + 1;
                    end
                end
            end
       end
    end
end

function [preHiatusFacies] = findPreHiatusFacies(glob, x,y,iteration)

    k = iteration - 1;

    while k > 0 && glob.faciesProd(y,x,k) == 7
       k = k - 1;
    end

    preHiatusFacies = glob.faciesProd(y,x,k);
end
