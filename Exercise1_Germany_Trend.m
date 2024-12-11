%% Problem Set 7, Exercise 1
% Julius Schoelkopf, M.Sc. (November 2024) 

% Code for decomposing GDP, consumption, and investment time series into
% trend and cyclical component using the HP filter.

% Clean up and delete previous results 
clear; close all; clc;


addpath 'figures/'

%% Download Data from FRED 
% You need the Datafeed package to download the Data from FRED

fredfetch   = fred('https://fred.stlouisfed.org/');

fredfetch.DataReturnFormat = 'table';
fredfetch.DatetimeType = 'datetime';

startdate = '01/01/1996';
enddate = '03/01/2024';

GDP = fetch(fredfetch,'CLVMNACSCAB1GQDE',startdate,enddate); 
Consumption = fetch(fredfetch,'DEUPFCEQDSNAQ',startdate,enddate); 
Investment = fetch(fredfetch,'DEUGFCFQDSNAQ',startdate,enddate); 
close(fredfetch);

%% Extract time series of interest.
gdp = GDP.Data{1};         % GDP
cons = Consumption.Data{1}; % Consumption
invest = Investment.Data{1};  % Investment

y = table2array(gdp(:,2));  % GDP
c = table2array(cons(:,2)); % Consumption
i = table2array(invest(:,2)); % Investment

% We want to save the downloaded data
save macrodata.mat 

% Specify time variable.
t = (1996.0:0.25:2024)';

%% Figure 1: Time series of German GDP 
figure 
    plot(t, log(y), 'k', 'LineWidth', 2);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('$\log(GDP)$', 'Interpreter','latex',  'FontSize', 20)
    saveas(gcf,'figures/Figure1GermanGDP.png')

%% Question 1.2 & Figure 2: Linear trend for German GDP 
% Define trend variable 
x = (1:length(y))';
% Add a column of ones to x for the intercept
x_with_const = [ones(size(x, 1), 1), x];

% estimate linear trend for the whole sample: 
% log(GDP_t) = beta_0  + beta_1*t 
b = regress(log(y),x_with_const);
lin =  b(1) + b(2)*x ;

% Figure 2 
figure
    h = plot(t, [log(y) lin],'LineWidth',1.5);
    set(h(1),'color','b');
    set(h(2),'color','r')
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('$\log(GDP)$', 'Trend', 'Interpreter','latex',  'FontSize', 20)
    saveas(gcf,'figures/Figure2GermanGDPLinearTrend.png')

%% Figure 3: Estimate linear trend for different samples 

% take first part of the sample: 1996-2002 
b_begin = regress(log(y(1:29)),x_with_const(1:29,:));
lin_begin = b_begin(1) + b_begin(2)*x ;

% take another part of the sample 2003-2014 (Great Recession) 
b_middle = regress(log(y(30:76)),x_with_const(30:76,:));
lin_middle = b_middle(1) + b_middle(2)*x ;

% take the last part of the sample 2015-2024 (Covid) 
b_end = regress(log(y(77:end)),x_with_const(77:end,:));
lin_end = b_end(1) + b_end(2)*x ;

% Plot the different estimated trends with the trend for the full sample
figure
    h = plot(t, [log(y) lin lin_begin lin_middle lin_end],'LineWidth',1.5);
    set(h(1),'color','b', 'LineWidth', 3);
    set(h(2),'color','r', 'LineWidth', 3);
    set(h(3),'color','c')
    set(h(4),'color','k')
    set(h(5),'color', 'm')
    line([2003, 2003], ylim, 'Color', 'c', 'LineWidth', 2, 'LineStyle', '--'); 
    line([2015, 2015], ylim, 'Color', 'm', 'LineWidth', 2, 'LineStyle', '--'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('$\log(GDP)$', 'Trend', 'Trend (1996-2002)', 'Trend (2003-2014)', 'Trend (2015-2024)', 'Interpreter','latex',  'FontSize', 20)
    saveas(gcf,'figures/Figure3GermanGDPLinearTrendSamples.png')

%% Question 1.3.: Using the HP filter 
% Set smoothing parameter for the HP filter.
% lambda = 1600 is suggested for quarterly data by Ravn and Uhlig (2002) 
lambda = 1600;

%% Filter the time series for GDP, consumption and investment 
% [Trend,Cyclical] = hpfilter(Y) returns the additive trend and cyclical
% components  
[y_trend, y_cyc] = hpfilter(log(y), lambda);
[c_trend, c_cyc] = hpfilter(log(c), lambda);
[i_trend, i_cyc] = hpfilter(log(i), lambda);


%% Question 1.4.: Plot time series and trend component.
figure
subplot(3,1,1)
    h(1) = plot(t, log(y), 'b', 'LineWidth', 3);
    hold on
    h(2) = plot(t, y_trend, 'b--', 'LineWidth', 3);
    hold off 
    axis tight
    legend('GDP','Trend GDP', 'Location', 'Northwest', 'Interpreter','latex')
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    title(['GDP Series and Trend Component ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex')

subplot(3,1,2)
    h(3) = plot(t, log(c), 'r', 'LineWidth', 3);
    hold on
    h(4) = plot(t, c_trend, 'r--', 'LineWidth', 3);
    hold off
    legend('Consumption','Trend Consumption', 'Location', 'Northwest', 'Interpreter','latex')
    axis tight
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    title(['Consumption Series and Trend Component ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex')

subplot(3,1,3)
    h(5) = plot(t, log(i), 'k', 'LineWidth', 3);
    hold on
    h(6) = plot(t, i_trend, 'k--', 'LineWidth', 3);
    legend('Investment','Trend Investment', 'Location', 'Northwest', 'Interpreter','latex')
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    title(['Investment Series and Trend Component ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

saveas(gcf,'figures/Figure4.png')

%% Plot cyclical component of the time series.
figure
subplot(3,1,1)
    plot(t, y_cyc, 'b', 'LineWidth', 3);
    axis tight
    set(gca, 'FontSize', 15)
    legend('GDP', 'Interpreter','latex')
    title('Cyclical Component of GDP','interpreter','latex')
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')

subplot(3,1,2)
    plot(t, y_cyc, 'b', 'LineWidth', 3);
    hold on
    plot(t, c_cyc, 'r--', 'LineWidth', 3);
    axis tight
    set(gca, 'FontSize', 15)
    legend('GDP','Consumption', 'Interpreter','latex')
    title('Cyclical Component of Consumption','interpreter','latex')
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')

subplot(3,1,3)
    plot(t, y_cyc, 'b', 'LineWidth', 3);
    hold on
    plot(t, i_cyc, 'r--', 'LineWidth', 3);
    axis tight
    set(gca, 'FontSize', 15)
    legend('GDP','Investment', 'Interpreter','latex')
    title('Cyclical Component of Investment','interpreter','latex')
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

saveas(gcf,'figures/Figure5.png')

%% Question 1.6. & Figure 6: Illustrating the effect of lambda 
% Decompose GDP using lambda = 10 (almost no cycle) and lambda = 10000 
% (close to linear trend) 
[y_trend_10, y_cyc_10] = hpfilter(log(y), 10);
[y_trend_10000, y_cyc_10000] = hpfilter(log(y), 10000);

figure 
    h(1) = plot(t, log(y), 'k', 'LineWidth', 2);
    hold on 
    h(2) = plot(t, y_trend, 'r', 'LineWidth', 2);
    hold on 
    h(3) = plot(t, y_trend_10, 'g', 'LineWidth', 2);
    hold on 
    h(4) = plot(t, y_trend_10000, 'b', 'LineWidth', 2);
    hold off
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('GDP','Trend $\lambda = 1600$','Trend $\lambda = 10$','Trend $\lambda = 10000$', 'Interpreter','latex',  'FontSize', 20)
    saveas(gcf,'figures/Figure6.png')

%% Question 1.6. & Figure 7 and 8: Illustrating the instability at the margin 

[y_trend_1, y_cyc_1] = hpfilter(log(y(1:95)), lambda);
[y_trend_2, y_cyc_2] = hpfilter(log(y(1:96)), lambda);
[y_trend_3, y_cyc_3] = hpfilter(log(y(1:97)), lambda);
[y_trend_4, y_cyc_4] = hpfilter(log(y(1:98)), lambda);
[y_trend_5, y_cyc_5] = hpfilter(log(y(1:99)), lambda);
[y_trend_6, y_cyc_6] = hpfilter(log(y(1:100)), lambda);
[y_trend_7, y_cyc_7] = hpfilter(log(y(1:101)), lambda);
[y_trend_8, y_cyc_8] = hpfilter(log(y(1:102)), lambda);
[y_trend_9, y_cyc_9] = hpfilter(log(y(1:103)), lambda);

% Trend 
figure
    h(1) = plot(t, log(y), 'k', 'LineWidth', 3);
    hold on 
    h(2) = plot(t(1:95), y_trend_1, 'b', 'LineWidth', 1);
    hold on 
    h(3) = plot(t(1:96), y_trend_2, 'b', 'LineWidth', 1);
    hold on 
    h(4) = plot(t(1:97), y_trend_3, 'b', 'LineWidth', 1);
    hold on 
    h(5) = plot(t(1:98), y_trend_4, 'b', 'LineWidth', 1);
    hold on 
    h(6) = plot(t(1:99), y_trend_5, 'b', 'LineWidth', 1);
    hold on 
    h(7) = plot(t(1:100), y_trend_6, 'b', 'LineWidth', 1);
    hold on 
    h(8) = plot(t(1:101), y_trend_7, 'b', 'LineWidth', 1);
    hold on 
    h(9) = plot(t(1:102), y_trend_8, 'b', 'LineWidth', 1);
    hold on 
    h(10) = plot(t(1:103), y_trend_9, 'b', 'LineWidth', 1);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    saveas(gcf,'figures/Figure7.png')
% Cycle 
figure
    h(2) = plot(t(80:95), y_cyc_1(80:95), 'b', 'LineWidth', 1);
    hold on 
    h(3) = plot(t(80:96), y_cyc_2(80:96), 'b', 'LineWidth', 1);
    hold on 
    h(4) = plot(t(80:97), y_cyc_3(80:97), 'b', 'LineWidth', 1);
    hold on 
    h(5) = plot(t(80:98), y_cyc_4(80:98), 'b', 'LineWidth', 1);
    hold on 
    h(6) = plot(t(80:99), y_cyc_5(80:99), 'b', 'LineWidth', 1);
    yline(0); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    saveas(gcf,'figures/Figure8.png')

%% Question 1.6: Compute standard deviations (relative to the standard deviation of GDP).
std_y = std(y_cyc);
std_c = std(c_cyc) / std(y_cyc);
std_i = std(i_cyc) / std(y_cyc);

disp(['Standard deviation of output: ' num2str(std(y_cyc))]) 
disp(['Standard deviation of investment: ' num2str(std(i_cyc))]) 
disp(['Standard deviation of consumption: ' num2str(std(c_cyc))]) 
disp(['Standard deviation of consumption relative to utput: ' num2str(std_c)]) 
disp(['Standard deviation of investment relative to utput: ' num2str(std_i)]) 