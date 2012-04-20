function [glob stats] = finalMapStats(glob, stats, iteration)

    fprintf('Calculating final map stats ...');

    % Make sure spatial entropy calculation arrays are full of zeros
    stats.lateralTotalTransitions = zeros(glob.maxIts,1);
    stats.lateralDiffTransitions = zeros(glob.maxIts,1);
    stats.spatialEntropy = zeros(glob.maxIts,1);
    
    % Searched records which grid cells have already been counted
    searched = zeros(glob.ySize, glob.xSize, iteration);
    % Contains the area of the mapped blobs on each iteration. xSize * 20 is a generous
    % guess on maximum size required for the array based on max blobs per iteration
    blobArea = zeros(iteration,glob.xSize * (glob.ySize/2));

    for t = 1:iteration
        
        % glob.faciesCount element glob.maxFacies +2 is the blob count
        glob.faciesCount(t, glob.maxFacies+2) = 0;
        
        for y = 1:glob.ySize
            for x=1:glob.xSize

                % only want to count producing facies that have not already been counted
                if searched(y,x,t) == 0 && glob.faciesProd(y,x,t)> 0 && glob.faciesProd(y,x,t) <= glob.maxProdFacies
                    oneFacies = glob.faciesProd(y,x,t);
                    if glob.faciesCount(t, glob.maxFacies+2) < 10000
                        glob.faciesCount(t, glob.maxFacies+2) = glob.faciesCount(t, glob.maxFacies+2) + 1;
                        blobArea(t,glob.faciesCount(t, glob.maxFacies+2)) = blobArea(t,glob.faciesCount(t, glob.maxFacies+2)) + 1;
                        findNeighbours(y,x);
                    else
                        fprintf('Warning: Too many blobs, need to increase blobArea dimension\n');
                    end
                end

                % Look at four adjacent cells and record as transitions to a different
                % facies if appropriate, or just record as one of total transitions to
                % allow calculation of the spatial entropy
                if x > 1 && x < glob.xSize - 1 && y > 1 && y < glob.ySize - 1
                    
                    if glob.faciesProd(y,x,t) ~= glob.faciesProd(y,x+1,t)
                        stats.lateralDiffTransitions(t) = stats.lateralDiffTransitions(t) + 1;
                    end
                    
                    if glob.faciesProd(y,x,t) ~= glob.faciesProd(y,x-1,t)
                        stats.lateralDiffTransitions(t) = stats.lateralDiffTransitions(t) + 1;
                    end
                    
                    if glob.faciesProd(y,x,t) ~= glob.faciesProd(y-1,x,t)
                        stats.lateralDiffTransitions(t) = stats.lateralDiffTransitions(t) + 1;
                    end
                    
                    if glob.faciesProd(y,x,t) ~= glob.faciesProd(y+1,x,t)
                        stats.lateralDiffTransitions(t) = stats.lateralDiffTransitions(t) + 1;
                    end
                    
                    stats.lateralTotalTransitions(t) = stats.lateralTotalTransitions(t) + 4;
                end
            end
        end
        
        stats.spatialEntropy(t) = stats.lateralDiffTransitions(t) / stats.lateralTotalTransitions(t);
    end
    
    glob.blobMap = searched;
    
    function findNeighbours(y,x)

        for i=y-1:y+1
           for j=x-1:x+1

               % Wrapping boundary condition on the grid margins
                if (i < 1) i = glob.ySize; end
                if (i > glob.ySize) i = 1; end
                if (j < 1) j = glob.xSize; end
                if (j > glob.xSize) j = 1; end

                if searched(i,j,t) == 0 && glob.faciesProd(i,j,t) == oneFacies
                   %fprintf('Blob %d current area %d at %d %d\n', blobCount, blobArea(blobCount), i,j);
                   blobArea(t,glob.faciesCount(t, glob.maxFacies+2)) = blobArea(t,glob.faciesCount(t, glob.maxFacies+2)) + 1;
                   searched(i,j,t) = glob.faciesCount(t, glob.maxFacies+2);
                   findNeighbours(i,j);
                end
           end
        end
    end % End of function findNeighbours

    %for t=1:iteration
      %  for i=1:1000
      %      if blobArea(t,i) > 0
                %fprintf('%d Blob %d has area %d\n', t, i, blobArea(t,i));
       %     end
       % end
    %end
    
    fprintf('done\n');
    %fprintf('for iteration %d %d total transitions, %d changes, so spatial entropy is %5.4f\n', iteration, stats.lateralTotalTransitions(iteration), stats.lateralDiffTransitions(iteration), stats.spatialEntropy(iteration));
end