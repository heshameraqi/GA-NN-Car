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

% % Draw Environment
% for i=1:length(Lines(:,1))
%     line([Lines(i,1) Lines(i,3)], [Lines(i,2) Lines(i,4)]);
% end
% xlabel('meters');
% ylabel('meters');
% separation = 20;
% axis([min(min(Lines(:,[1 3])))-separation max(max(Lines(:,[1 3])))+separation ...
%     min(min(Lines(:,[2 4])))-separation max(max(Lines(:,[2 4])))+separation])
% axis equal;
% keyboard