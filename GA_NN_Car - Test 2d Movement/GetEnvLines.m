function [Lines] = GetEnvLines(env)

Lines = zeros(length(env.dx_dy),4);

intial_point = env.intial_point;
for i=1:length(env.dx_dy)
    new_point = intial_point;
    if (mod(i,2) == 1)
        new_point(1) = new_point(1)+env.dx_dy(i);
    else
        new_point(2) = new_point(2)+env.dx_dy(i);
    end
    
    Lines(i,:) = [intial_point(1) intial_point(2) new_point(1) new_point(2)];
    intial_point = new_point;
end