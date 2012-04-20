function [glob] = calculateProduction(glob, iteration)

onefacies = uint8(0);
prod = 0.0;

% Calculate carbonate production for each point on the grid.
% NB could be optimized of prod was put into an xy map then used outside the loop to update all these other xy maps
for y=1:glob.ySize;
    for x=1:glob.xSize

        oneFacies =  glob.faciesProd(y,x,iteration);

        % Only need to calculate production for occupied cells i.e. 0 < facies < 7 
        % (7 is subaerial exposure)
        if oneFacies > 0 && oneFacies <= glob.maxProdFacies && glob.wd(y,x,iteration) > 0

            % Bosscher and Schlager production variation with water depth
            if (glob.wd(y,x,iteration) > 0.0)
                glob.prodDepthAdjust(y,x) = tanh((glob.surfaceLight(oneFacies) * exp(-glob.extinctionCoeff(oneFacies) * glob.wd(y,x,iteration)))/ glob.saturatingLight(oneFacies));
            else
                glob.prodDepthAdjust(y,x) = 0;
            end
            
            % Set production thickness to depth and neighbour-adjusted thickness for this
            % facies. Note that faciesProdAdjust is calculated in calculateFaciesCA
            prod = glob.prodRate(oneFacies) * glob.prodDepthAdjust(y,x) * glob.faciesProdAdjust(y,x); 

            if prod > glob.wd(y,x,iteration) % if production > accommodation set prod=accommodation to avoid build above SL
                prod = glob.wd(y,x,iteration);
            end

            % Decrease WD by amount of production
            glob.wd(y,x,iteration) = glob.wd(y,x,iteration) - prod;

            % Record the production as thickness in the strata array
            glob.strata(y,x,iteration) = glob.strata(y,x,iteration-1) + prod;
            glob.faciesProdThick(y,x,iteration) = prod;

        else % No deposition so record zero thickness
            glob.prodDepthAdjust(y,x) = 0;
            prod = 0;
            glob.strata(y,x,iteration) = glob.strata(y,x,iteration-1);
            glob.faciesProdThick(y,x,iteration) = 0.0;
        end

        if x==25 && y==25
            fprintf('SL %3.2f WD:%3.2f @25,25 Facies %d Prod %3.2f ', glob.SL(iteration), glob.wd(y,x,iteration), oneFacies, prod);
        end

    end
end

fprintf('Total accum. %3.2f ', sum(sum(glob.faciesProdThick(:,:,iteration))));

end




