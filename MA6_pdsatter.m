% Preston Satterfield
% 1972081
% MA 6

%% Task 1
% Prompt user to enter critical temp
% Check if is in range 300 - 350 K
% - use an if statement and a while loop to validate data

crit_temp = 0;

while crit_temp > 350 || crit_temp < 300
    crit_temp = input('Enter Critical temperature (300 - 350K): ');
end

%% Task 2
% Create phase diagram for the mixture by developing curves with the data
% Model fusion curve as a power eq
% Model vaporization curve with exponential curve

% Intersection of curves is triple point, Find intersection using fzero and
% anonymous function

% Sublimation curve is linear equation using origin (T=150, P=0), and
% triple point

% PLOT:
% Fusion begins at triple point and ends at upper limit
% Vaporization begin at triple point and end at critical temp
% Sublimation begin at T=150 P=0 and end at triple point

% FORMAT:
% x-axis label
% y-axis label
% Title
% gridlines
% phase labels
% blue lines
% line thickness 3
% axis limits

% load data and pull out data
data = load('Boundaries.csv');
fus_temp = data(1,:);
fus_pressure = data(2,:);
vap_temp = data(3,:);
vap_pressure = data(4,:);

% find m and b using polyfit
fusion_fit = polyfit(log10(fus_temp), log10(fus_pressure), 1);
vap_fit = polyfit(vap_temp, log(vap_pressure), 1);

fus_m = fusion_fit(1);
fus_b = 10^(fusion_fit(2));

vap_m = vap_fit(1);
vap_b = exp(vap_fit(2));

% create anonymous equations to solve the function
fusion_eq = @(x) fus_b .* x.^(fus_m);
vapor_eq = @(x) vap_b .* exp(vap_m .*x);

% find triple point (point of intersection with fusion and vaporization)
diff = @(x) fusion_eq(x) - vapor_eq(x);
triple_point_temp = fzero(diff, 210);
triple_point_pressure = fusion_eq(triple_point_temp);

% Find sublimation equation m, b, and create anonymous function
sub_fit = polyfit([150, triple_point_temp], [0, triple_point_pressure], 1);
sub_m = sub_fit(1);
sub_b = sub_fit(2);
sublimation_eq = @(x) sub_m .* x + sub_b;

% plot
hold on
plot([150, triple_point_temp], [0, triple_point_pressure], '-b', 'LineWidth', 3);
fplot(fusion_eq, [triple_point_temp, crit_temp], '-b', 'LineWidth', 3)
fplot(vapor_eq, [triple_point_temp, crit_temp], '-b', 'LineWidth', 3)
plot([crit_temp, crit_temp], [vapor_eq(crit_temp), 60], '-b', 'LineWidth', 3)

text(200,40,'Solid')
text(300,40,'Liquid')
text(300,10,'Gas')

grid on
title('Phase Diagram of Unknown Mixture')
xlabel('Temperature(T)[K]')
ylabel('Pressure(P)[atm]')
axis([150, 350, 0, 60]);

%% Task 3
% prompt user to input a point to anaylze
% Check: if point is within diagram limits
% If not, prompt user to enter valid point
menu4 = 1;
phase = [];
while menu4 == 1
    user_point = [0, 0];
    while user_point(1) < 150 || user_point(1) > 350 || user_point(2)...
            < 0 || user_point(2) > 60
        user_point = input('Enter a test point on the phase diagram [T, P]: '); 
    end
    
    phase_calculated = CheckPhase(user_point, fusion_eq, vapor_eq,...
                        sublimation_eq, crit_temp, triple_point_temp);
    phase = [phase; [user_point(1),  user_point(2), phase_calculated]];
    
    fprintf("The point (%d, %d) is in the %s phase. \n", user_point(1),...
        user_point(2), phase_calculated);
    % Task 4, repeat if needed
    menu4 = 0;
    while menu4 == 0
       menu4 = menu('Would you like to enter another point: ', 'Yes', 'No'); 
    end
    
end

%% Task 5, print a table
%{
[phase_length, ~] = size(phase); 
fprintf('Temperature [K]\t Pressure[atm] \tState\n') % header
for i = 1:phase_length  % iterates through table
    fprintf('%s\t%s\t%s\n', phase(i, 1), phase(i, 2), phase(i, 3))
end
%}
table_t5 = table(phase(:,1), phase(:,2), phase(:,3), 'VariableNames',...
    {'Temperature[K]', 'Pressure[atm]', 'State'});
disp(table_t5);

%% Task 6
total_size = (350 - 150) * (60 - 0);

sub_gas_size = integral(sublimation_eq, 150, triple_point_temp);
vapor_gas_size = integral(vapor_eq, triple_point_temp, crit_temp);
superfluid_size = (350 - crit_temp) * (60 - 0);

gas_total_area = sub_gas_size + vapor_gas_size + superfluid_size;

gas_percent_total = (gas_total_area / total_size) * 100;
fprintf('The gas phase is %0.2f%% of the phase diagram \n', gas_percent_total);
