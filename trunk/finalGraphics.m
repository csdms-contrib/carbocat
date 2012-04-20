function graph = finalGraphics(glob, stats, graph, iteration)

% ScreenSize is a four-element vector: [left, bottom, width, height]:
scrsz = get(0,'ScreenSize'); % vector 
% position requires left bottom width height values. screensize vector
% is in this format 1=left 2=bottom 3=width 4=height
graph.f1 = figure('Visible','on','Position',[1 scrsz(4)/4 (scrsz(3)/3)*2 (scrsz(4)/3)*2]);
graph.f2 = figure('Visible','off','Position',[1 scrsz(2)+20 scrsz(3) scrsz(4)/1.2]);
graph.f3 = figure('Visible','off','Position',[10 10 scrsz(3)*0.9 scrsz(4)*0.9]);
graph.f4 = figure('Visible','off','Position',[10 10 scrsz(3)*0.9 scrsz(4)*0.9]);
graph.f5 = figure('Visible','off','Position',[5 5 scrsz(3)*0.9 scrsz(4)*0.9]);

plotFigure1(glob, stats, graph, iteration);
plotFigure2(glob, stats, graph, iteration);
plotFigure3(glob, stats, graph, iteration);
plotFigure4(glob, stats, graph, iteration);
plotFigure5(glob, stats, graph, iteration);

% ----------------------------------------------------------------------------------------

function plotFigure1(glob, stats, graph, iteration)
    % Activate figure created in initializeGUI m file
    % NB the load command loads the whole workspace. The colourmap is only one variable in
    % this workspace, called in the case of the CA3 facies oneCMap
    figure(graph.f1);
    load('colorMaps/colorMapCA7Facies','CA7FaciesCMap');
    set(graph.f1,'Colormap',CA7FaciesCMap);

    % Initial condition facies map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    subplot('Position',[0.05 0.075 0.2 0.32]);
    axis square;
    grid off;
    p = pcolor(double(glob.faciesProd(:,:,1)));

    for i=0:10
        patch(0,0,i); % use a dummy patch to force colour map to range 0-10
    end

    set(p,'LineStyle','none');
    xlabel('Horizontal x distance (km)')
    ylabel('Horizontal y distance (km)')
    title('Final facies map')

    % Final facies map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    subplot('Position',[0.3 0.075 0.2 0.32])
    axis square;
    grid off;

    oneMap = glob.faciesProd(:,:,iteration); % Copy the in-situ prod for this iteration
    for x=1:glob.xSize-1
        for y=1:glob.ySize-1 % Loop through all the map grid cells

            transFaciesList = glob.faciesTrans{y,x,iteration}; % Get the transported strata from x,y position
            if max(transFaciesList) > 0 && glob.faciesProdThick(y,x,iteration) > glob.faciesThicknessPlotCutoff % If some transported and below thickness threshold of in-situ, plot transported on the map     
                oneMap(y,x) = transFaciesList(length(transFaciesList)); % Plot the top transported facies in the pile for this cell for this iteration
            end
        end
    end
    p = pcolor(double(oneMap));

    for i=0:10
        patch(0,0,i); % use a dummy patch to force colour map to range 0-10
    end

    set(p,'LineStyle','none');
    xlabel('Horizontal x distance (km)')
    ylabel('Horizontal y distance (km)')
    title('Final facies map')

    % Facies count timeseries
    subplot('Position',[0.075 0.5 0.4 0.20]);
    %faciesCountSubset = glob.faciesCount(1:iteration,1:(glob.maxFacies+2)); % +2 to include facies change and blob count
    faciesCountSubset = glob.faciesCount(1:iteration,1:(glob.maxFacies));
    plot(faciesCountSubset);
    xlabel('Time (ky)');
    ylabel('Facies count');

    % Spatial entropy timeseries
    subplot('Position',[0.075 0.78 0.4 0.20]);
    spatialEntropySubset = stats.spatialEntropy(1:iteration);
    plot(spatialEntropySubset);
    xlabel('Time (ky)');
    ylabel('Spatial entropy');

    % Vertical succession at x=25 y=25
    subplot('Position',[0.57 0.075 0.13 0.8]);
    for i=0:10
        patch(0,0,i); % use a dummy patches to force colour map to range 0-10
    end

    plotOneStratColumn(glob, 25, 25, iteration, 2); % NB 2 is the flag to draw a single strat column

    ylabel('Thickness (m)');

    % frequency distribution plots
    subplot('Position',[0.80 0.075 0.18 0.8]);
    %plot(stats.thicknessBins, stats.cumThicknessFreq, '-ob', stats.thicknessBins, stats.expCumThicknessFreq, '--or');
    plot(stats.thickness, stats.cumThickness, '-ob', stats.thickness, stats.expCumThickness, '--or');
    xlabel('Lithofacies thickness (m)');
    ylabel('Relative Cumulative Frequency');

end

% ---------------------------------------------------------------------------------------

function plotFigure2(glob, stats, graph, iteration)
% CHRONOSTRAT AND CROSS SECTION PLOT

    % Activate the second results figure created in initializeGUI m file
    % plot includes cross section and chronostrat plotted on the same x axis
    figure(graph.f2);
    load('colorMaps/colorMapCA7Facies','CA7FaciesCMap');
    set(graph.f2,'Colormap',CA7FaciesCMap);
    %set(graph.f2,'CDataMapping','direct');

    xPos = 25; % So cross section and chronostrat will be along the y axis half-way across map grid
    crossSectionPlot = subplot('Position',[0.05 0.55 0.8 0.40]);
    plotCrossSection(xPos, crossSectionPlot, glob, stats, graph, iteration);
    chronoPlot = subplot('Position',[0.05 0.075 0.8 0.40]);
    plotChronostratSection(xPos, chronoPlot, glob, stats, graph, iteration);
    SLPlot = subplot('Position',[0.85 0.075 0.12 0.40]);
    plotEustaticCurve(SLPlot,glob, iteration);
end

% ----------------------------------------------------------------------------------------
    
function plotFigure3(glob, stats, graph, iteration)
% FACIES MAPS PLOT

    figure(graph.f3);
    load('colorMaps/colorMapCA7Facies','CA7FaciesCMap');
    set(graph.f3,'Colormap',CA7FaciesCMap);

    yPos = 0.10;
    xPos = 0.1;
    
    for i =1: glob.mapCount
        
        age = uint16(glob.mapAge(i));
        oneMap = glob.faciesProd(:,:,age); % Copy the in-situ prod for this iteration
        
        for x=1:glob.xSize-1
            for y=1:glob.ySize-1 % Loop through all the map grid cells

                transFaciesList = glob.faciesTrans{y,x,age}; % Get the transported strata from x,y position
                if max(transFaciesList) > 0 && glob.faciesProdThick(y,x,age) < glob.faciesThicknessPlotCutoff % If some transported and below thickness threshold of in-situ, plot transported on the map     
                    oneMap(y,x) = transFaciesList(length(transFaciesList)); % Plot the top transported facies in the pile for this cell for this iteration
                end
            end
        end

        % position [left, bottom, width, height] all in range 0.0 to 1.0.
        subplot('Position',[xPos yPos 0.15 0.25])
        %p = pcolor(double(glob.faciesProd(:,:,i)));
        p = pcolor(double(oneMap));

        for j=0:10
            patch(0,0,j); % use a dummy patch to force colour map to range 0-10
        end

        xlabel('Distance (km)')
        ylabel('Distance (km)')
        labelStr = sprintf('Time %4.3f My',double(age)*glob.deltaT);
        title(labelStr);
        set(p,'LineStyle','none');

        xPos = xPos + 0.22;

        if i==4
           xPos = 0.10;
           yPos = 0.50;
        end
    end
end

% ----------------------------------------------------------------------------------------

function plotFigure4(glob, stats, graph, iteration)
% 3D SLICE PLOT of the stratigraphy as a chronostrat plot

    % Activate the second results figure created in initializeGUI m file
    % plot includes cross section and chronostrat plotted on the same x axis
    figure(graph.f4);
    load('colorMaps/colorMapCA7Facies','CA7FaciesCMap')
    set(graph.f4,'Colormap',CA7FaciesCMap);

    plotFacies = double(glob.faciesProd); % Make a copy of the facies matrix to plot ...
    plotFacies(:,:,iteration:glob.maxIts) = []; % Chop off all the empty cells in the matrix beyond the final iteration just calculated
    yslice = 50; xslice = [10,40, 50]; zslice = [1,iteration/2];

    plotFacies(1,1,1) = 10; % Add a dummy value to force colour map range

    p = slice(plotFacies, xslice, yslice, zslice);

    set(p,'LineStyle','none');
    xlabel('Distance (km)');
    ylabel('Distance (km)');
    zlabel('Model iteration');
end

% ----------------------------------------------------------------------------------------
    
function plotFigure5(glob, stats, graph, iteration)
% 3D PLOT of the stratigraphy as thickness colour coded by facies

    figure(graph.f5);
    load('colorMaps/colorMapCA7Facies','CA7FaciesCMap');
    set(graph.f5,'Colormap',CA7FaciesCMap);

    drawCrossSectionDipOrientation(1);
    drawCrossSectionDipOrientation(50);
    drawCrossSectionStrikeOrientation(1);
    drawCrossSectionStrikeOrientation(50);

    k = iteration;

    for x=1:glob.xSize-1
        for y=1:glob.ySize-1 % Loop through all the map grid cells

            yco = [y,y,y+1,y+1];
            xco = [x,x+1,x+1,x];
            zco = [glob.strata(y,x,k) glob.strata(y,x+1,k) glob.strata(y+1,x+1,k) glob.strata(y+1,x,k)];

            transFaciesList = glob.faciesTrans{y,x,k}; % Get the transported strata from x,y position
            if max(transFaciesList) > 0 && glob.faciesProdThick(y,x,k) < glob.faciesThicknessPlotCutoff % If some transported and thin or no in-situ
                fCode = transFaciesList(length(transFaciesList)); % Plot the top transported facies
            else % Plot the thickness of strata deposited by in-situ production
                fCode = glob.faciesProd(y,x,k); % Note this is zero for no depositon, 7 for subaerial hiatus
            end

            if fCode > 0
                faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
            else
                faciesCol = [ 1 1 1 ]; % Set patch to white
            end

            %patch(xco, yco, zco, faciesCol, 'EdgeColor','none');
            patch(xco, yco, zco, faciesCol);
        end
    end

    cellFacies(1,1,2) = 0; 
    cellFacies(1,1,1) = 10; % Use 2 dummy cells to force colour map to range 0-10

    %set(p,'LineStyle','none');
    xlabel('X Distance (km)');
    ylabel('Y Distance (km)');
    zlabel('Elevation (m)');

    view([-225 45]);

end

% *************************************** Functions called from code above

function plotCrossSection(x, crossSectionPlot, glob, stats, graph, iteration)

    subplot(crossSectionPlot);
    
    % First delete the previous plot with a single large white patch
    minDepth = max(max(glob.strata(:,:,1))); % Find the highest (so shallowest) values in the strata array
    minDepth = minDepth * 1.1; % Add 10% to the minimum depth
    maxDepth = min(min(glob.strata(:,:,1))); % Find the lowest (ie deepest) values in strata array
    maxDepth = maxDepth * 1.1; % Add 10% to the maximum depth
    patch([0 glob.xSize glob.xSize 0], [minDepth minDepth maxDepth maxDepth], [1 1 1], 'EdgeColor','none');
   
    % Now reuse maxdepth to draw a light grey solid colour basement at the bottom of the
    % section
    for y = 1:glob.ySize-1
        xco = [y,y,y+1,y+1]; 
        zco = [maxDepth, glob.strata(y,x,1), glob.strata(y,x,1), maxDepth];
        patch(xco, zco, [0.7 0.7 0.7],'EdgeColor','none');
    end

    for y = 1:glob.ySize-1
        plotOneStratColumn(glob, x, y, iteration, 1);
    end

    % Loop through iterations and draw timelines
    for i=1:glob.timeLineCount;

        k = glob.timeLineAge(i);

        if k <= iteration
            for y = 1:glob.ySize-1
                % draw a marker line across the top and down/up the side of
                % a particular grid cell
                xco = [y,y+1,y+1];
                yco = [glob.strata(y,x,k), glob.strata(y,x,k), glob.strata(y+1,x,k)];
                line(xco, yco, 'LineWidth',2, 'color', 'black');
            end
        end
    end

    % Draw the final sea-level
    xco = [1 glob.ySize];
    yco = [glob.SL(iteration) glob.SL(iteration)];
    line(xco,yco, 'LineWidth',2, 'color', 'blue');

    ylabel('Elevation (m)');

end

function plotOneStratColumn(glob, x, y, iteration, plotType)
    
    for k = 1:iteration-1 % needs to be -1 here because k+1 in array access below
        
        if plotType == 1 % Cross section plot
            xco = [y,y,y+1,y+1]; % xco is a vector containing x-axis coords for the corner points of % each strat section grid cell.
        end
                
        % First plot the thickness of strata deposited by in-situ production
        fCode = glob.faciesProd(y,x,k+1); % Note this is zero for no depositon, 7 for subaerial hiatus
        if fCode > 0 && fCode < 4 % Assuming three in-situ producing facies
            if plotType ~= 1 % So if a single-column plot
                xco = [0,0,0.5,0.5]; % For in situ facies draw half the width of transported facies
            end
            % zco is the equivalent y-axis vector
            zco = [glob.strata(y,x,k), glob.strata(y,x,k)+glob.faciesProdThick(y,x,k+1), glob.strata(y,x,k)+glob.faciesProdThick(y,x,k+1), glob.strata(y,x,k)];
            faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
            patch(xco, zco, faciesCol,'EdgeColor','none');
        end;
        
        % Then plot any surfaces, but only if the single column plot type
        if plotType ~= 1
            if fCode == 0
                line([1.1,1.25], [glob.strata(y,x,k), glob.strata(y,x,k)], 'Color',[0,0,1]);
            end
            
            if fCode == 7
                line([1.25,1.5], [glob.strata(y,x,k), glob.strata(y,x,k)], 'Color',[1,0,0]);
            end
        end

        % Next plot the thickness of transported strata
        numOfTransFacies = length(glob.faciesTrans{y,x,k+1});
        zcoInc = glob.strata(y,x,k) + glob.faciesProdThick(y,x,k+1); % The top of the in-situ layer k+1
        oneThick = 0;
        for m=1:numOfTransFacies
            fCode = glob.faciesTrans{y,x,k+1}(m);
            if fCode > 0
                if plotType ~= 1 % So if a single-column plot
                    xco = [0,0,1,1]; % For transported facies draw twice the width of in situ facies
                end
                
                oneThick = glob.faciesTransThick{y,x,k+1}(m);
                zco = [zcoInc, zcoInc + oneThick, zcoInc + oneThick, zcoInc];
                faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                patch(xco, zco, faciesCol,'EdgeColor','none');

                zcoInc = zcoInc + oneThick;
            end
        end
    end    
end

function plotChronostratSection(x, chronoPlot, glob, stats, graph, iteration)
   
    subplot(chronoPlot);
    
    % chronostrat section
    chronoSectMatrix(1:glob.ySize, 1:iteration)= glob.faciesProd(1:glob.ySize, x, 1:iteration);
    chronoSectMatrixTimeVert = chronoSectMatrix';

    for i=0:10
        patch(0,0,i); % use a dummy patch to force colour map to range 0-10
    end

    for k=1:iteration-1

        for y = 1:glob.ySize-1
            % xco is a vector containing x-axis coords for the corner points of
            % each strat section grid cell. Yco is the equivalent y-axis vector
            xco = [y,y,y+1,y+1];

            faciesList = glob.faciesTrans{y,x,k+1};
            if max(faciesList) > 0
                cellHeight = glob.deltaT / (length(faciesList) + 1);
            else
                cellHeight = glob.deltaT;
            end
            cellBase = k*glob.deltaT;

            % Draw the insitu production facies first
            tco = [cellBase, cellBase+cellHeight, cellBase+cellHeight, cellBase];
            fCode = glob.faciesProd(y,x,k+1);
            if (fCode > 0 && glob.faciesProdThick(y,x,k+1) > glob.faciesThicknessPlotCutoff) || fCode == 7
                faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                patch(xco, tco, faciesCol,'EdgeColor','none');
            end

            % Now draw the transported facies, however many there are...
            cellBase = cellBase+cellHeight; % to account for in-situ facies cell
            for fLoop = 1:length(faciesList)

                tco = [cellBase, cellBase+cellHeight, cellBase+cellHeight, cellBase];
                fCode = faciesList(fLoop);
                if fCode > 0
                    faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                    patch(xco, tco, faciesCol,'EdgeColor','none');
                end

                cellBase = cellBase + cellHeight;
            end
        end
    end

    % Force four ticks on the y axis
    set(chronoPlot,'YTick',[0 (glob.deltaT * iteration * 0.25) (glob.deltaT * iteration * 0.5) (glob.deltaT * iteration * 0.75) (glob.deltaT * iteration)]);
    xlabel('Horizontal distance (km)');
    ylabel('Elapsed model time (My)');
end

function plotEustaticCurve(SLPlot, glob, iteration)
    
    subplot(SLPlot);
    
    % Sealevel curve

    % Force four ticks on the y axis and plot the y axis on the right hand side of the plot
    set(SLPlot,'YAxisLocation','right');
    set(SLPlot,'YTick',[0 (glob.deltaT * iteration * 0.25) (glob.deltaT * iteration * 0.5) (glob.deltaT * iteration * 0.75) (glob.deltaT * iteration)]);

    for k=1:iteration-1
        % now plot the sea-level curve line for the same time interval
        lineColor = [0.0 0.2 1.0];
        x = [double(glob.ySize)+glob.SL(k) double(glob.ySize)+glob.SL(k+1)];
        y = [double(k)*glob.deltaT double(k+1)*glob.deltaT];
        line(x,y, 'color', lineColor);
    end

    xlabel('Eustatic Sealevel (m)');
    
end


function drawCrossSectionDipOrientation(x)
    
    % Draw a light grey solid colour basement at the bottom of the section
    maxDepth = min(min(glob.strata(:,:,1))); % Find the lowest values in strata array
    maxDepth = maxDepth * 1.1; % Add 10% to the maximum depth
    xco = [x,x,x,x];
    for y = 1:glob.ySize-1
        yco = [y,y,y+1,y+1];
        zco = [maxDepth, glob.strata(y,x,1), glob.strata(y,x,1), maxDepth];
        patch(xco, yco, zco, [0.7 0.7 0.7],'EdgeColor','none');
    end

    for k = 1:iteration-1 % needs to be -1 here because k+1 in array access below
        for y = 1:glob.ySize-1

            yco = [y,y,y+1,y+1]; % yco is a vector containing y-axis coords for the corner points of % each strat section grid cell.

            % First plot the thickness of strata deposited by in-situ production
            fCode = glob.faciesProd(y,x,k+1); % Note this is zero for no depositon, 7 for subaerial hiatus
            if fCode > 0
                % zco is the equivalent y-axis vector
                zco = [glob.strata(y,x,k), glob.strata(y,x,k)+glob.faciesProdThick(y,x,k+1), glob.strata(y,x,k)+glob.faciesProdThick(y,x,k+1), glob.strata(y,x,k)];
                faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                patch(xco, yco, zco, faciesCol,'EdgeColor','none');
            end;
            
            numOfTransFacies = length(glob.faciesTrans{y,x,k+1});
            zcoInc = glob.strata(y,x,k) + glob.faciesProdThick(y,x,k+1); % The top of the in-situ layer k+1
            oneThick = 0;
            for m=1:numOfTransFacies
                fCode = glob.faciesTrans{y,x,k+1}(m);
                if fCode > 0
                    oneThick = glob.faciesTransThick{y,x,k+1}(m);
                    zco = [zcoInc, zcoInc + oneThick, zcoInc + oneThick, zcoInc];
                    faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                    patch(xco, yco, zco, faciesCol,'EdgeColor','none');
                    
                    zcoInc = zcoInc + oneThick;
                end
            end
        end
    end
    
    
end

function drawCrossSectionStrikeOrientation(y)
    
    % Draw a light grey solid colour basement at the bottom of the section
    maxDepth = min(min(glob.strata(:,:,1))); % Find the lowest values in strata array
    maxDepth = maxDepth * 1.1; % Add 10% to the maximum depth
    yco = [y,y,y,y];
    for x = 1:glob.xSize-1
        xco = [x,x,x+1,x+1];
        zco = [maxDepth, glob.strata(y,x,1), glob.strata(y,x,1), maxDepth];
        patch(xco, yco, zco, [0.7 0.7 0.7],'EdgeColor','none');
    end

    for k = 1:iteration-1 % needs to be -1 here because k+1 in array access below
        for x = 1:glob.xSize-1

            xco = [x,x,x+1,x+1]; % yco is a vector containing y-axis coords for the corner points of % each strat section grid cell.
            
            % First plot the thickness of strata deposited by in-situ production
            fCode = glob.faciesProd(y,x,k+1); % Note this is zero for no depositon, 7 for subaerial hiatus
            if fCode > 0
                % zco is the equivalent y-axis vector
                zco = [glob.strata(y,x,k), glob.strata(y,x,k)+glob.faciesProdThick(y,x,k+1), glob.strata(y,x,k)+glob.faciesProdThick(y,x,k+1), glob.strata(y,x,k)];
                faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                patch(xco, yco, zco, faciesCol,'EdgeColor','none');
            end;
            
            numOfTransFacies = length(glob.faciesTrans{y,x,k+1});
            zcoInc = glob.strata(y,x,k) + glob.faciesProdThick(y,x,k+1); % The top of the in-situ layer k+1
            oneThick = 0;
            for m=1:numOfTransFacies
                fCode = glob.faciesTrans{y,x,k+1}(m);
                if fCode > 0
                    oneThick = glob.faciesTransThick{y,x,k+1}(m);
                    zco = [zcoInc, zcoInc + oneThick, zcoInc + oneThick, zcoInc];
                    faciesCol = [glob.faciesColours(fCode,2) glob.faciesColours(fCode,3) glob.faciesColours(fCode,4)];
                    patch(xco, yco, zco, faciesCol,'EdgeColor','none');
                    
                    zcoInc = zcoInc + oneThick;
                end
            end
        end
    end
end

end % Of the whole function finalGraphics

