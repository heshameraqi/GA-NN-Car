clc;
clear all;
close all;

%% Do initializations
fig = figure(1);
xlabel('[Meters]');
ylabel('[Meters]');
collision_bool = false;

%% Car and sensor Configurations
car.wheelBase = 2.6; %[Meters] The distance between the two axles
car.width = 1.7; %[Meters]
car.length = 4.3; %[Meters]
car.wheelLength = 0.45; %[Meters]
car.wheelWidth = 0.22; %[Meters]

sensor.angles = [0 30 60 90 120 150 180] * pi/180; % [Degrees] (TODO: Should be automatically generated from nbrOfInputNodes)
sensor.range = 20;
sensor.sensor_dot_radius_ratio = 0.05; % sensor_circle_radius = ratio * car.width;

dt = 0.01; %[Seconds] Time Step
carLocation = [0 0]; %[X Y] in [Meters] Car Head (Sensor) Initial Location
carSpeed = 10*ones(1,1200); %[meters/hour]
carHeading = 90 * pi/180; %[Degrees] Car Initial Heading Counter Clock Wise
steerAngle = [40*ones(1,40) 30*ones(1,40) 20*ones(1,40) 10*ones(1,40) 0*ones(1,40) ...
               0*ones(1,40) -10*ones(1,40) -20*ones(1,40) -30*ones(1,40) -40*ones(1,40) ]* pi/180; %[Degrees] Counter Clock Wise (Useless Intial Value)
steerAngle = [steerAngle steerAngle steerAngle];
           
camera_mode = 0; %0:Centered within cameraVisibleRange 1:Has full Map visible
cameraVisibleRange = 30; % Drawing Camera Range (The bigger, the higher world) (60 is good value)

%% Environment Configurations
env.dx_dy = [15 70 90 40 40 50 -20 15 30 50 -15 -40 -30 -40 15 -20 -35 -40 -25 50 20 40 -15 -30 -20 -60 -40 60 -15 -30 -50 15 ...
    -15 -30 60 -20 -80 -70 15 55 75 -65];
env.intial_point = [-7 -20];
env.destination = [140 200];
env.destination_dot_radius_ratio = 1; % sensor_circle_radius = ratio * car.width;

%% Iterating Generations
env.lines = GetEnvLines(env); %[x1 y1 x2 y2; ....]
cameraVisibleRange = cameraVisibleRange /2;
Fitness = sqrt((carLocation(1)-env.destination(1))^2+(carLocation(2)-env.destination(2))^2);
for i = 1: length(carSpeed)
    
    % Move Car and Draw Environment - Get Sensor Readings and Collision State
    clf(fig);
    hold on;
    [newCenters sensor.readings collision_bool] = MoveCarTimestep(carLocation, carHeading, steerAngle(i), car, sensor, env, 1);
    axis equal;
    if (camera_mode == 0)
        axis([newCenters(1)-cameraVisibleRange newCenters(1)+cameraVisibleRange newCenters(2)-cameraVisibleRange newCenters(2)+cameraVisibleRange]);
    end
    pause(0.0001);
%     if (collision_bool)
%         break;
%     end
  
    % Apply sensor reading to ANN to calculate steerAngle
%     sensor.readings = [sensor.readings 1]; %Adding Bias Node
%     outputs = Feedforward(sensor.readings, Chromosomes(pop,:), Network_Arch, unipolarBipolarSelector);
%     steerAngle = outputs; %[Degrees] Counter Clock Wise (Useless Intial Value)
    
    % 2D car steering physics (Calculate carLocation and carHeading)
    frontWheel = carLocation + car.wheelBase/2 * [cos(carHeading) sin(carHeading)];
    backWheel  = carLocation - car.wheelBase/2 * [cos(carHeading) sin(carHeading)];
    backWheel  = backWheel  + carSpeed(i) * dt * [cos(carHeading) sin(carHeading)];
    frontWheel = frontWheel + carSpeed(i) * dt * [cos(carHeading+steerAngle(i)) sin(carHeading+steerAngle(i))];
    carLocation = (frontWheel + backWheel) / 2;
    carHeading = atan2( frontWheel(2) - backWheel(2) , frontWheel(1) - backWheel(1) );
    
    % Calculate fitness (distance to destination)
    Fitness = min(Fitness, sqrt((carLocation(1)-env.destination(1))^2+(carLocation(2)-env.destination(2))^2));
end





