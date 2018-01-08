function game_of_life
close all; clc;
% calling main function
profile off;
profile clear;
profile on;
star_game_of_life();
profile viewer;
end

function star_game_of_life()
figure_color = [0.9 0.9 0.9]; 
panel_color = [0.98 0.98 0.98];
text_color = [0.95 0.95 0.95];
colormap_colors = [0.8 0.8 0.8; 0.2 1 0.4; 0.2 0.4 1]; % colors used as colormap in cells plotting
scrsize = get(groot, 'ScreenSize');
living_cells_plot_data = []; % vectore to store number of living cells
map = []; % matrix representing map of game

t = timer(...                   % timer for refreshing data every 0.1s (or the value from slider)
  'Tag', 'timer', ...
  'StartFcn', @init_timer, ...  % after the timer init, function init_timer is called
  'TimerFcn', @run_game, ...    % every period, function run_game is called
  'Period', 0.1, ...            
  'TasksToExecute', Inf, ...    % timer runs to infinity
  'ExecutionMode', 'fixedRate');

f = figure(...                  % main game figure
  'MenuBar', 'none', ...
  'Name', 'Game of Life', ...
  'Resize', 'off', ...
  'CloseRequestFcn', @exit, ... $ on exit, function exit is called
  'Position', [(scrsize(3) - scrsize(4) - 140) / 2 50 scrsize(4) + 140 scrsize(4) - 80], ...
  'NumberTitle', 'off', ...
  'Color', figure_color);

living_cells_axe = axes(...       % axe to show plot of living cells
  'Parent', f, ...
  'Tag', 'living_cells_axe', ...
  'Parent', f, ...
  'Units', 'Normalized', ...
  'Position', [0.79 0.5 0.19 0.1], ...
  'XTick', [], 'YTick', [], ...
  'GridLineStyle', '-');

living_cells_plot = plot(living_cells_axe, 0, 'Tag', 'living_cells_axe'); % plotting living cells data to given axe
title('Living cells');
xlabel('generation');
ylabel('livign cells');

map = load('Acorn.mat');
map = map.map;
[r, c] = size(map);

main_axes = axes(...
  'Parent', f, ...
  'Units', 'Normalized', ...
  'Position', [0 0.1 0.8 0.85], ...
  'XTick', [], 'YTick', [], ...
  'XLim', [1 c + 1], 'YLim', [1 r + 1], ...
  'GridLineStyle', '-');
show_map(map);

load_template_popup_panel = uipanel(...
  'Units', 'Normalized', ...
  'Position', [0.79 0.79 0.19 0.065], ...
  'Title', 'Load Template', 'BackgroundColor', panel_color, ...
  'Tag', 'load_template_popup_panel');

load_template_popup = uicontrol(...
  'Parent', load_template_popup_panel, ...
  'Units', 'Normalized', ...
  'Position', [0.1 0.25 0.8 0.5], ...
  'Style', 'popup', ...
  'String', {'Acorn', 'Gosper_Glider_Gun', 'Rabbits', 'Random'}, ...
  'Callback', @load_template_popup_callback);

traces_checkbox = uicontrol(...
  'Value', 1, ...
  'Units', 'Normalized', ...
  'Position', [0.79 0.15 0.19 0.025], ...
  'Style', 'checkbox', ...
  'String', 'Show traces', ...
  'Tag', 'choiceOfVisibility', ...
  'BackgroundColor', panel_color, ...
  'TooltipString', 'click to show traces', ...
  'Tag', 'traces_checkbox');

speed_slider_panel = uipanel(...
  'Units', 'Normalized', ...
  'Position', [0.79 0.37 0.19 0.07], ...
  'Title', 'Speed', 'BackgroundColor', panel_color, ...
  'Tag', 'speed_slider_panel');

speed_slider = uicontrol(...
  'Parent', speed_slider_panel, ...
  'Style', 'slider', ...
  'Units', 'Normalized', ...
  'Position', [0.05 0.25 0.9 0.5], ...
  'Min', 0.05, ...
  'Max', 0.55, ...
  'Value', 0.55 - t.Period, ...
  'Callback', @speed_slider_callback);

living_cells_panel = uipanel(...
  'Units', 'Normalized', ...
  'Position', [0.79 0.65 0.09 0.09], ...
  'Title', 'Living Cells', 'BackgroundColor', panel_color, ...
  'Tag', 'living_cells_panel');

generation_panel = uipanel(...
  'Units', 'Normalized', ...
  'Position', [0.89 0.65 0.09 0.09], ...
  'Title', 'Generation', 'BackgroundColor', panel_color, ...
  'Tag', 'generation_panel');

living_cells_data = uicontrol(...
  'Parent', living_cells_panel, ...
  'Units', 'Normalized', ...
  'Position', [0.225 0.25 0.6 0.5], 'Style', 'text', ...
  'String', '', 'BackgroundColor', text_color, ...
  'FontSize', 12, ...
  'Tag', 'living_cells_data');

generation_data = uicontrol(...
  'Parent', generation_panel, ...
  'Units', 'Normalized', ...
  'Position', [0.225 0.25 0.6 0.5], 'Style', 'text', ...
  'String', '1', 'BackgroundColor', text_color, ...
  'FontSize', 12, ...
  'Tag', 'generation_data');

close_button = uicontrol(...
  'Parent', f, ...
  'Style', 'PushButton', ...
  'Units', 'Normalized', ...
  'Position', [0.92 0.1 0.06 0.03], ...
  'String', 'Close', ...
  'CallBack', @close_button_callback);

run_button = uicontrol(...
  'Parent', f, ...
  'Style', 'PushButton', ...
  'Units', 'Normalized', ...
  'Position', [0.79 0.1 0.06 0.03], ...
  'String', 'Run', ...
  'CallBack', @run_button_callback, ...
  'Tag', 'run_button');

step_button = uicontrol(...
  'Parent', f, ...
  'Style', 'PushButton', ...
  'Units', 'Normalized', ...
  'Position', [0.85 0.1 0.06 0.03], ...
  'String', 'Step', ...
  'CallBack', @step_button_callback);

function load_template_popup_callback(src, ~)
names = src.String;
name = strcat(names(src.Value), '.mat');
if strcmp(name{1}, 'Random.mat'); % if user choose Random
    new_map = zeros(150); 
    new_map(randperm(numel(new_map), 2000)) = 2; % generate new random map
else
    new_map = load(name{1}); % else load selected name of map
    new_map = new_map.map;
end
generation_data = findobj('Tag', 'generation_data'); 
generation_data.String = 0; % set value of generation to 0
living_cells_data = findobj('Tag', 'living_cells_data');
living_cells_data.String = ''; % set value of living cells to ''
living_cells_plot_data = []; % delete data about living cells

show_map(new_map);
map = new_map;
end

function step_button_callback(src, ~)
run_button = findobj('Tag', 'run_button');
if strcmp(run_button.String, 'Pause');
    run_button.String = 'Run';
end
stop(t); % stop timer
t.TasksToExecute = 1; % set number of tasks to execute by timer t to one
start(t); % execute one task (one step)
end

function run_button_callback (src, ~)
if strcmp(src.String, 'Run'); % if String from run_button is 'Run'
    src.String = 'Pause'; % change it to 'Pause'
    t.TasksToExecute = Inf; % run timer t to infinity
    start(t);
else
    src.String = 'Run'; % else change it ot 'Run'
    stop(t); % stop timer t
end
end

function close_button_callback (~, ~)
stop(t);
close(f);
end

function exit(~, ~)
answer = questdlg('Do you want to exit?', 'Game of Life', 'Yes', 'No', 'No'); % pta uzivatele
if strcmp(answer, 'Yes')
    delete(f);
    stop(t);
    delete(t);
end
end

function speed_slider_callback(src, ~)
% function speed_slider_calback 
stop(t); % stop timer t
x = src.Value; % get value of slider
value = round(x * 100) / 100; % round it to two decimals
t.Period = 0.61 - value; % reverse direction of slider and set timer's t period
start(t); % start timer t
end

function init_timer(~, ~)
% function run_game is called once at start of timer t
if isempty(map)
    map = load('Acorn.mat'); % load initial map
    show_map(map); % display it
end
end

function run_game(~, ~)
% function run_game is called every period of timer t
% functin run_game is calling function apply_rules to get new matrix
% new_map and then it shows it with function show_map
[new_map, living_cells] = apply_rules(map); % get new map and number of living cells
update_living_cell_plot(living_cells); 
map = new_map; % update main map data
show_map(new_map); % redraw matrix new_map
end

function update_living_cell_plot(living_cells)
% function update_living_cell_plot is used for re-plotting data in
% living_cell_axe
living_cells_plot_data = [living_cells_plot_data living_cells]; % append number of living cells to vector
h = findobj('Tag', 'living_cells_axe'); % find living_cell_axe
set(h, 'XData', 1:size(living_cells_plot_data, 2), 'YData', living_cells_plot_data); % update data
end

function show_map(map)
% function show_map is used for plotting matrix map using function pcolor
new_map = map(4:end - 3, 4:end - 3); % showing map cropped by 3 from all directions
[r, c] = size(new_map);
map_image = pcolor(main_axes, (1:c) + 0.5, (1:r) + 0.5, new_map);
set(map_image, 'LineWidth', 0.7);
set(map_image, 'EdgeColor', [0.7 0.7 0.7]);
colormap(colormap_colors); % setting colormap
axis equal
set(gca, 'XTick', [], 'YTick', [], 'XLim', [1 c + 1], 'YLim', [1 r + 1], 'GridLineStyle', '-');
end

function [new_map, living_cells] = apply_rules(map)
% function apply_rules generates new matrix new_map from matrix map by
% applying game of life rules
% this function also returns number of living cells in new_map
new_map = zeros(size(map)); % create new matrix with same size as the old one
living_cells = 0;
traces = findobj('Tag', 'traces_checkbox'); % find traces_checkbox to check if we want to show traces
traces = traces.Value;
for i = 2:size(map, 1) - 1                          % iterate from 2nd to the next to last row
    for j = 2:size(map, 2) - 1                      % iterate from 2nd to the next to last column
        alive = get_neighbors(map, i, j);           % get number of living cells around current element
        if map(i, j) == 2                           % if current element is living cell (2)
            if alive < 2
                if traces
                    new_map(i, j) = 1;              % new value is (1) which stands for trace
                else
                    new_map(i, j) = 0;              % new value is (0) which stands for dead cell
                end
            end
            if alive == 2 || alive == 3     
                new_map(i, j) = 2;                  % new value is (2) which stands for living cell
                living_cells = living_cells + 1;    % increase number of living cells
            end
            if alive > 3
                if traces
                    new_map(i, j) = 1;              % new value is (1) which stands for trace
                else
                    new_map(i, j) = 0;              % new value is (0) which stands for dead cell
                end
            end
        end
     
        if map(i, j) == 0                           % if current element is dead cell (0)
            if alive == 3
                new_map(i, j) = 2;                  % new value is (2) which stands for living cell
                living_cells = living_cells + 1;    % increase number of living cells
            end
        end
        if map(i, j) == 1                           % if current element is trace (1)
            if alive == 3
                new_map(i, j) = 2;                  % new value is (2) which stands for living cell
                living_cells = living_cells + 1;    % increase number of living cells
            else
                if traces
                    new_map(i, j) = 1;              % new value is (1) which stands for trace
                else
                    new_map(i, j) = 0;              % new value is (0) which stands for dead cell
                end
            end
        end
    end
end
living_cells_data = findobj('Tag', 'living_cells_data');% find data space with information of living cells
living_cells_data.String = living_cells;              % update value of living cells

generation_data = findobj('Tag', 'generation_data');% find data space with information of generation
generation = str2double(generation_data.String) + 1;% increase current generation
generation_data.String = generation;                % update value of generation
end

function alive = get_neighbors(map, i, j)
% function get_neighbors give us number of living cells around given
% indices i, j in matrix map
alive = 0;
if map(i - 1, j - 1) == 2
    alive = alive + 1;
end
if map(i - 1, j) == 2
    alive = alive + 1;
end
if map(i - 1, j + 1) == 2
    alive = alive + 1;
end
if map(i, j - 1) == 2
    alive = alive + 1;
end
if map(i, j + 1) == 2
    alive = alive + 1;
end
if map(i + 1, j - 1) == 2
    alive = alive + 1;
end
if map(i + 1, j) == 2
    alive = alive + 1;
end
if map(i + 1, j + 1) == 2
    alive = alive + 1;
end
end
end

