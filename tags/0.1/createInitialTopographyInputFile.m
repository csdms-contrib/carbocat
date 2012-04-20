function createInitialTopographyInputFile

    xSize = 50;
    ySize = 50;
    wd = zeros(ySize, xSize);

    % Set the initial water depth as flat surface with glob,initWD from the parameter file
    wd(:,:) = 2.0;

    % Set the initial water depth as a ramp surface deepening with increasing y
    %for y = 1:int16(ySize)
    %    wd(y,:) = y-5;
    %end
    
    g1 = surface(-wd); % NB water depths are positive but to plot as elevation convert to negative
    view([-85 25]);
    set(g1,'LineStyle','none');
    grid on;
    xlabel('X Distance (km)');
    ylabel('Y Distance (km)');
    
    save('params/initialTopographyFlat2m.txt', 'wd', '-ascii');
    
end
