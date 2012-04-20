function saveModelData(glob, stats, iteration)

%  / glob.deltaT

    fName = sprintf('modelOutput\\modelStats_%s.txt', glob.modelName);
    pValsOutput = fopen(fName,'w');
    fprintf(pValsOutput,'StratCompleteness PARatio MinThickness MeanThickness MaxThickness D     Dx  P\n');
    fprintf(pValsOutput,'%5.4f             %5.4f   %5.4f        %5.4f         %5.4f        %5.4f %d  %5.4f\n', stats.stratCompleteness, stats.PARatio, stats.minThickness, stats.meanThickness, stats.maxThickness, stats.D, stats.Dx, stats.p);
    for i = 1:iteration
        fprintf(pValsOutput,'\n%d ',i);
        for faciesNum =1:7
            fprintf(pValsOutput,'%d ', glob.faciesCount(i,faciesNum) );
        end
        fprintf(pValsOutput,'%d %d %5.4f ', stats.lateralDiffTransitions(i), stats.lateralTotalTransitions(i), stats.spatialEntropy(i));
    end
    fclose(pValsOutput);
      
    fName = sprintf('modelOutput\\modelStratColumn_%s.txt', glob.modelName);
    stratOutput = fopen(fName,'w');
    for i = 2:iteration
        fprintf(stratOutput,'%d %d %5.4f\n', i, glob.faciesProd(25,25,i), glob.strata(25,25,i) -  glob.strata(25,25,i-1) );
    end
    fclose(stratOutput);

