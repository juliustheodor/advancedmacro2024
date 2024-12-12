%% Advanced Macroeconomics, Problem Set 7, Exercise 2.3 and 2.4 
% Julius Schoelkopf, M.Sc. (November 2024) 

% Code for simulating the following stochastic process with AR(1) component:
% ln A(t) = A_tilde(t) = rho * A_tilde(t-1) + epsilon(t)

% Clean up and delete previous results 
clear; close all; clc;

% Set number of periods to be considered.
t = 10;

%% Question 2.3b - Simulation for rho = 0.5 
% Specify shock vector, i.e. the value of epsilon for each period t.
% Here: a unity shock at period 1.
epsilon = zeros(1,t);
epsilon(1) = 1;

% Initialize objects for ln A and A_tilde.
ln_A = zeros(1,t);
A_tilde = zeros(1,t+1);

% Set starting value.
% A_tilde is shifted one period ahead since Matlab starts counting at 1.
A_tilde(1) = 0;

% Set AR parameter which governs the persistence of the process.
rho = 0.5;

% Loop over the number of periods t specified above.
for i = 1:t
    A_tilde(i+1) = rho*A_tilde(i) + epsilon(i);
    ln_A(i) = A_tilde(i+1);
end

% Plot the process.
subplot(2,1,1)
plot(ln_A, 'r', 'LineWidth', 2)
set(gca, 'FontSize', 18, 'TickLabelInterpreter','latex')
legend(['$\rho_A$ = ',num2str(rho)],'interpreter','latex')
title('$\ln A_t$','interpreter','latex')
set(gcf,'color','w') 
axis tight

subplot(2,1,2)
plot(epsilon, 'b--', 'LineWidth' , 2)
set(gca, 'FontSize', 18, 'TickLabelInterpreter','latex')
title('Sequence of Shocks','interpreter','latex')
set(gcf,'color','w') 
axis tight
saveas(gcf,'figures/Figure9ARprocess.png')

%% Question 2.4 comparison with rho = 0, 1 and 1.5 

% Define rho values to iterate over
rho_values = [0, 0.5, 1, 1.5];

% Create a 2x2 subplot figure
figure;

for j = 1:length(rho_values)
    rho = rho_values(j);

    % Initialize objects for ln A and A_tilde
    ln_A = zeros(1, t);
    A_tilde = zeros(1, t + 1);

    % Set starting value
    A_tilde(1) = 0;

    % Loop over the number of periods t specified above
    for i = 1:t
        A_tilde(i + 1) = rho * A_tilde(i) + epsilon(i);
        ln_A(i) = A_tilde(i + 1);
    end

    % Plot ln_A in the appropriate subplot
    subplot(2, 2, j);
    plot(ln_A, 'r', 'LineWidth', 2);
    set(gca, 'FontSize', 18, 'TickLabelInterpreter', 'latex');
    legend(['$\rho_A$ = ', num2str(rho)], 'interpreter', 'latex');
    title('$\ln A_t$', 'interpreter', 'latex');
    axis tight;
end

% Set figure background color
set(gcf, 'color', 'w');

% Save the figure
saveas(gcf, 'figures/Figure10ARprocessallrho.png');