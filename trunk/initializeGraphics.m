function initializeGraphics(glob, graph, iteration)

cla % Clear all existing plots in the window
figure(graph.main);

% Initial Facies map
% position [left, bottom, width, height] all in range 0.0 to 1.0.
faciesMapPlot = subplot('Position',[0.05 0.2 0.25 0.5]);
cla
reset(faciesMapPlot);

testX = [1:50];
testY = [1:50];
p=pcolor(testY, testX, double(glob.faciesProd(:,:,iteration)));
set(p,'LineStyle','none');
view([0 90]);
xlabel('X Distance (km)');
ylabel('Y Distance (km)');

% Initial bathymetry map
% position [left, bottom, width, height] all in range 0.0 to 1.0.
wdMapPlot = subplot('Position',[0.4 0.2 0.25 0.5]);
cla
reset(wdMapPlot);

p=surface(double(-glob.wd(:,:,1)));
set(p,'LineStyle',':');
view([-85 25]);
grid on;
xlabel('X Distance (km)');
ylabel('Y Distance (km)');

% initialise production depth curve plot
depthProdPlot = subplot('Position',[0.8 0.2 0.15 0.6]);
cla
reset(depthProdPlot);

set(depthProdPlot, 'YDir', 'reverse');
ylabel('Water depth (m)');
xlabel('Production rates');
minMax = max(glob.prodRate/glob.deltaT);
axis([-(minMax*0.05) minMax*1.05 0 100]);
grid on;
depth=0:100;

for j=1:glob.maxProdFacies
    prodDepth = (glob.prodRate(j)/glob.deltaT) * tanh((glob.surfaceLight(j) * exp(-glob.extinctionCoeff(j) * depth))/ glob.saturatingLight(j));
    lineCol = [glob.faciesColours(j,2) glob.faciesColours(j,3) glob.faciesColours(j,4)];
    line(prodDepth, depth, 'color', lineCol, 'LineWidth',2);
end

