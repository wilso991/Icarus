%{
Pareto Results Plotted - Loading .csv File Instead of Running

Command to save Pareto results after running:
writetable(struct2table(architectures), 'Pareto_Results.csv')

%}

architectures = readtable('../Pareto_Results.csv'); % Note this loads the .csv file as a table, need to use table2array to use it in calculations/plotting
cost = table2array(architectures(:, 14));
SV = table2array(architectures(:, 10)) + table2array(architectures(:, 11)) + table2array(architectures(:, 12)) + table2array(architectures(:, 13));

figure(1)
plot(cost, SV, 'k.')
grid on
hold on
plot(linspace(3E8, 3E8, 1000), linspace(0, 25, 1000), 'r-')
title('Pareto Plot')
xlabel('Cost [$]')
ylabel('Science Value')
