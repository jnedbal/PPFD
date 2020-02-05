function PPFD
% This function processes tables of PPFD data measured on the illuminated
% orbital shaker.
%
% It requires the UnivarScatter function from the Mathworks file exchange:
% https://uk.mathworks.com/matlabcentral/fileexchange/54243-univarscatter
% Written by Manuel Lera Ramírez
% 
% The function produces graphs that are saved as PNG and PDF files.


% Jakub Nedbal, King's College London, 2020
% File Created: 20. Jan, 2020
%
% The file is distributed under the BSD License
% Copyright 2020 Jakub Nedbal
%
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Global variable used in plotting the data
global graphPar

% Populate the cell with the parameters of the plot.
% Each dataset gets one line in the cell.
% The columns have the following meaning:
%   1. scatter plot marker shape
%   2. linear regression line style
%   3. Color of the dataset
%   4. Legend label for each dataset
graphPar = {'o', ':', [0, 0.4470, 0.7410], 'medium'; ...
            'x', '-.', [0.8500, 0.3250, 0.0980], 'low'};% ...
            %'s', [0.9290, 0.6940, 0.1250], 'high'};


% Get rid of any old figures
close all

% Form the figures with axes used throughout
hf = gobjects(2, 2);
for i = 1 : size(hf, 1)
    hf(1, i) = figure('Units', 'pixels', 'Position', [0 0 750, 750]);
    hf(2, i) = axes('Units', 'pixels');
end


% Load the PPFD measurement data
% The sheet name in the table is critical to parsing the XLSX file.
table.air = readtable('PPFD.xlsx', 'Sheet', 'air');
table.water = readtable('PPFD.xlsx', 'Sheet', 'water');

% Create X axis labels for the graphs
Xaxis = {'Trickle', '6', '5', '4', '3', '2', '1', char(9899)};
% Combine data from colums into a table
table.air.Ydata = horzcat(table.air.Trickle, ...
                          table.air.x6, ...
                          table.air.x5, ...
                          table.air.x4, ...
                          table.air.x3, ...
                          table.air.x2, ...
                          table.air.x1, ...
                          table.air.x_);
% Combine data from colums into a table
table.water.Ydata = horzcat(table.water.Trickle, ...
                            table.water.x6, ...
                            table.water.x5, ...
                            table.water.x4, ...
                            table.water.x3, ...
                            table.water.x2, ...
                            table.water.x1, ...
                            table.water.x_);

% Plot the results
% This populates the graphs with the data and labels them accordingly
% Plot data from Air
makePlot(Xaxis, ...             % X Tick labels
         table.air.Ydata, ...   % PPFD measurements
         'Air', ...             % Medium named in graph title
         hf(:, 1))              % Handles to appropriate figure and axes

% Plot data from Water
makePlot(Xaxis, ...             % X Tick labels
         table.water.Ydata, ... % PPFD measurements
         'Water', ...           % Medium named in graph title
         hf(:, 2))              % Handles to appropriate figures and axes



function makePlot(day, density, medium, hfig)
% This function plots the data from the growth curve cell counting
% experiments
%   day:        X Tick labels
%   density:    PPFD measurements
%   medium:     Medium named in graph title
%   hfig:       Handles to appropriate figures and axes

% global variable with graph parameters
global graphPar

% Switch to the appropriate figure
figure(hfig(1))
% Switch to the appropriate axes
axes(hfig(2))
% Plot the univariate scatter plots of the cell count results
UnivarScatter(density, ...                              % Data
              'Label', day, ...                         % X Tick labels
              'MarkerFaceColor', 'none', ...            % No Marker fill
              'MarkerEdgeColor', graphPar{1, 3}, ...% Marker line color
              'PointStyle', graphPar{1, 1}, ...     % Marker shape
              'PointSize', 12);                         % Marker size

% Provide X axis label
xlabel('Power Setting')
% Provide Y axis label
ylabel(['PPFFR [' char(956) 'mol' char(183) 'm^{-2}' char(183) 's^{-1}]'])
% Title the graph, naming hte species
ht = title(sprintf('Photosynthetic Photon Flux Density in %s', medium));
% Ensure the axes have consistant size
set(gca, 'Position', [100, 100, 600, 600])
% Change axes to square - the axes with the univariate scatter plots in
% logarithmic scale seem to misbehave and be buggy. Position parameter does
% not really change the position the way it should. using this command
% helps making a square-ish graph, though not a perfect square.
axis square
% Keep drawing over the existing data
hold on



%% Create a legend
% Get the handles of all scatter plots with the marker shape of the current
% one. Handles of axes children:
hs = get(gca, 'Children');
% Get rid of the SEM blocks
delete(findobj(gca, 'type', 'rectangle', 'FaceColor', [0.95, 0.95, 0.95]))
% Create a fake block to make a legend entry
% Get handles of the remaining rectangles
hr = findobj(gca, 'type', 'rectangle');
% Plot faux marker behind the legend, so it is not visible
hr = plot(8, 50, ...
          'Marker', 's', ...
          'MarkerSize', 15, ...
          'MarkerFaceColor', get(hr(1), 'FaceColor'), ...
          'MarkerEdgeColor', get(hr(1), 'EdgeColor'), ...
          'Color', 'none');
% Store only the first identified scatter plot, the rest are the same
hleg = [hs(1 : 2); hr];
    
% Store the legend entries
sleg = {'Measured PPFD', ...
        'Average PPFD', ...
        'StdDev PPFD'};

% Increase the size of the letters in the graph
set(gca, 'FontSize', 16)

% Get rid of boxes to declutter

for i = 1 : size(density, 2)
    % Calculate the average
    avg = mean(density(:, i));
    % Calculate the standard deviation
    stdev = std(density(:, i));
    % Round to relevant number of significant digits
    nrDigs = 10 ^ floor(log10(stdev / 2));
    % Round the average
    avg = nrDigs * round(avg / nrDigs);
    % Round the standard deviation
    stdev = nrDigs * round(stdev / nrDigs);
    
    text(i + 0.4, avg, sprintf('%g %s %g', avg, char(177), stdev), ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
         'FontSize', 14)

end
% Create the legend in the lower right corner of the graph
legend(hleg(:), sleg(:), 'Location', 'SouthEast')


% Create a filename from the species to save the figure
fname = sprintf('%s.png', regexprep(medium, ' ', ''));
% Store the figure as a PNG file
saveas(gcf, fname, 'png')

% Get rid of the title
delete(ht)
% Adjust figure parameters for good PDF export
set(gcf, 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'PaperPositionMode', 'Auto', ...
         'PaperUnits', 'centimeters', ...
         'PaperSize', [pos(3), pos(4)])
% Store the figure as a PDF file
print(gcf, regexprep(fname, 'png', 'pdf'), '-dpdf', '-r0')

