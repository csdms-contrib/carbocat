function glob = initializeGUI(glob, stats, graph)

    iteration = 0;
    dummyMap = zeros(glob.ySize, glob.xSize);
    
    %  Create and then hide the GUI window as it is being constructed.
    
    % ScreenSize is a four-element vector: [left, bottom, width, height]:
    scrsz = get(0,'ScreenSize'); % vector 
    % position requires left bottom width height values. screensize vector
    % is in this format 1=left 2=bottom 3=width 4=height
    graph.main = figure('Visible','off','Position',[1 scrsz(4)/3 scrsz(3)/1.5 scrsz(4)/1.5]);
    
    % Make main the current figure for plotting, gui elements etc
    figure(graph.main);
    
    % Load and apply the 3 facies colourmap from the params folder
    %load('colorMaps/colorMapCA3Facies','colorMapCA3Facies');
    load('colorMaps/colorMapCA3Facies','CA3FaciesCMap');
    set(graph.main,'Colormap',CA3FaciesCMap);
    
    % Initial condition facies map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    temp = subplot('Position',[0.05 0.2 0.25 0.5]);
    axis square;
    dummymap = zeros(50,50);
    pcolor(double(dummyMap));
    
    % Initial condition bathymetry map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    temp = subplot('Position',[0.35 0.2 0.25 0.5]);
    axis square;
    dummymap = zeros(50,50);
    surface(double(dummyMap));
    
    % Production profiles
    subplot('Position',[0.7 0.2 0.25 0.6]);
    axis ij;
    plot(1:10, 1:10);

   %  Construct the components.
   hInit = uicontrol('Style','pushbutton','String','Initialize',...
          'Position',[20,20,70,25],...
          'Callback',{@initButton_Callback});
   hRun = uicontrol('Style','pushbutton','String','Run CA model',...
          'Position',[100,20,100,25],...
          'Callback',{@runButton_Callback});
   hReset = uicontrol('Style','pushbutton','String','Close  output windows',...
          'Position',[220,20,150,25],...
          'Callback',{@resetButton_Callback});
   hSaveCMaps = uicontrol('Style','pushbutton','String','Save colourmaps',...
          'Position',[400,20,150,25],...
          'Callback',{@saveColorMapsButton_Callback});
   
   hParamsFnameLabel = uicontrol('style','text','string','Parameters filename:','Position',[600,45,120,15]);
   hParamsFname = uicontrol('Style','edit','String','params\example.txt','Position',[600 20 190 25]);
   
   % Assign the GUI a name to appear in the window title.
   set(graph.main,'Name','CarboCAT')
   % Move the GUI to the center of the screen.
   movegui(graph.main,'center')
   % Make the GUI visible.
   set(graph.main,'Visible','on');

   function initButton_Callback(source,eventdata) 
   %
      clear;
      glob.paramsFName = get(hParamsFname,'String');
      
      glob = initializeOneModelParams(glob, glob.paramsFName);
      glob = initializeArrays(glob);
      initializeGraphics(glob, graph, 1);
   end
 
   function runButton_Callback(source, eventdata) 
   %
      [glob,graph] = runCAmodelGUI(glob, stats, graph);
      glob.initFlag = 0;
   end
 
   function resetButton_Callback(source, eventdata) 
   %
      close(graph.f1);
      close(graph.f2);
      close(graph.f3);
      close(graph.f4);
      close(graph.f5);
   end

   function saveColorMapsButton_Callback(source, eventdata) 
   % Save the two different CA facies colour maps in case they have been changed
      CA3FaciesCMap = get(graph.main,'Colormap'); 
      save('colorMaps\colorMapCA3Facies','CA3FaciesCMap');
      CA7FaciesCMap = get(graph.f1,'Colormap'); 
      save('colorMaps\colorMapCA7Facies','CA7FaciesCMap');
   end

   function loadButton_Callback(source,eventdata) 
   
   end 

   function saveButton_Callback(source,eventdata) 
      
   end 

 
end 