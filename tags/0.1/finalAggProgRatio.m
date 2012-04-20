function stats = finalAggProgRatio(glob, stats, iteration)

% Note - this now operates on faciesProd only so is not calculating the ratio for
% transported strata

stats.transitionTotal = 0;
stats.aggCount = 0;
stats.progCount = 0;
    
for t = 2:iteration
    for y = 1:glob.ySize
        for x=1:glob.xSize
            
            thickness = glob.strata(y,x,t) - glob.strata(y,x,t-1);
            startFacies = glob.faciesProd(y,x,t);
            
            if startFacies ~= 0 && thickness > 0.001

                % Starting with the next iteration, loop and count timesteps until the
                % next non-hiatus facies with thickness >= 0.001 is found
                i = t + 1;
                thickness = glob.strata(y,x,i) - glob.strata(y,x,i-1);
                while i < iteration && glob.faciesProd(y,x,i) == 0 && thickness < 0.001
                    i = i + 1;
                    thickness = glob.strata(y,x,i) - glob.strata(y,x,i-1);
                end

                % Loop might have ended becuase i=iteration so make sure facies>0 and
                % thickness > threshold and the count as either prog or agg
                if glob.faciesProd(y,x,i) > 0 && thickness >= 0.001
                    % If its the same facies, that must represent aggradation
                    % otherwise a different facies overlying must represent progradation
                    if glob.faciesProd(y,x,i) == startFacies
                        stats.aggCount = stats.aggCount + 1;
                        %fprintf('%d %d %d facies %d to %d aggradation total is %d\n', x,y, i, startFacies, glob.faciesProd(y,x,i), stats.aggCount);
                    else
                        stats.progCount = stats.progCount + 1;
                        %fprintf('%d %d %d facies %d to %d progradation total is %d\n', x,y, i, startFacies, glob.faciesProd(y,x,i), stats.progCount);
                    end

                    stats.transitionTotal = stats.transitionTotal + 1;
                end
            end
        end
    end
end

stats.PARatio = stats.progCount/stats.aggCount;

fprintf('%d transitions exluding hiatii. %d aggradation, %d progradational, prog/agg ratio %5.4f\n', stats.transitionTotal, stats.aggCount, stats.progCount, stats.PARatio);
    