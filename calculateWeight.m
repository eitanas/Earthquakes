function [w, max_tau,  c_value] = calculateWeight( v, fs )
% gets a CC vector produced from two signals and returns the weight of the
% link - w
% max_i is tau max, meaning tau where w max was found. 
% sf is sampling frequency
n = length(v);

%finding  max index -
[maximum, ind_max] = max(v);
[minimum, ind_min] = min(v);
c_value = max(abs(maximum), abs(minimum));

if (abs(maximum) > abs(minimum))
    max_tau_ind = ind_max;
else 
    max_tau_ind = ind_min;
end
v(max_tau_ind) = [];
% calculating w -
average = mean(v);
standard_dev = std(v);


w = (c_value - average) / standard_dev;
max_tau = (max_tau_ind - floor(n/2)) / fs;

end

