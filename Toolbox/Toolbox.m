% Aerospace MQP VTOL UAV Optimizer
clc, clear variables
%% Physical Characteristics
rho=1.225;          %Kg/m^3
Gamma=1.4;
T=298;              %K
V=[10,15,20,25];    %m/s
c=.3048;            %m airfoil chord
Mu=1.86e-5;         %m^2/s at 25C
R=287;              %kJ/(Kg*K)
for i=1:length(V)
    Mach(i)=V(i)/sqrt(Gamma*R*T);   %Mach #
    Re(i)=rho*V(i)*c/Mu;            %Reynold's Number
end 
%% User Inputs
%General Aircraft Information
M_L=3;              %Kg Mass of Aircraft and Payload
M_E=2;              %Kg Mass of Empty Aircraft
W_L=9.81*M_L;       %N Weight Loaded
W_E=9.81*M_E;       %N Weight Empty
H=.1;               %M Height of Aircraft
%Air Foil Information
fprintf('Choose from the the following foils NACA4412, S1223, E423, MH114, SD7026 \n')
air_foil_input=input('Which airfoil is being used?','s');
V_input=input('What speed is being flown at? 10, 15, 20, or 25 m/s?','s');
air_foil_data=air_foil_find(air_foil_input,V_input);
Cl=air_foil_data(1);    %Coef. Lift
Cm=air_foil_data(2);    %Coef. Moment
V=str2double(V_input);  %m/s
%Autonomus Information

%Motor Information
%VTOL
%{
fprintf('Choose from these motors for VTOL:')
motor_input=input('What is the motors?','s');
vtol_motor_data=motor_find(motor_input);
%Horz
fprintf('Choose from these motors for VTOL:')
motor_input=input('What is the motors?','s');
horz_motor_data=motor_find(motor_input);
%}
%Battery Information
fprintf('Choose from these Batteries:')
fprintf('ZIPPYCompact35C, Turnigy35C, ZIPPYCompact40C, Turnigy40C,TurnigyNano-Tech45C, TurnigyGraphene45C \n')
battery_input=input('What is the battery?','s')
battery_data=battery_find(battery_input);
%% Calculations
% Air Foil Calculations (assuming rectangular wing)
e=.8;                       %Oswald Efficency
b=W_L/(.5*Cl*rho*V^2*c);    %m wingspan
AR=b^2/(b*c);               % Aspect Ratio
K = (4/3)/(pi()*e*AR);      %Drag polar
Cdi=Cl^2/(pi*AR*e);           % Coef. Drag Induced
D=.5*V^2*b*H*rho;           %N Drag
T2W=W_L/D;                  % Thrust to Weight Ratio
Horz_Power=V*D;             %W Horizontal Power 
fprintf('The cord will be %f meters \n',b)
fprintf('The Coef. of Drag Induced is %f \n',Cdi)
fprintf('The Power needed for horizontal flight is %f W',Horz_Power')

%Battery Calculations

%Motor Calculations
%VTOL
%{
num_vtol_motors= W_L/vtol_motor_data(5);                 %Number of Motors for VTOL
power_for_vtol=num_vtol_motors*vtol_motor_data(2);       %W Watts
vtol_motor_weight=num_vtol_motors*vtol_motor_data(4);    %Kg Weight of Motors
%Horz
num_horz_motors=D/horz_motor_data(5);                    %Number of Horozintal Motors for Flight
horz_motor_weight=horz_motor_data(4);
%}
%% Turning Calculations
Tmax = 2*D;
S = b*c;
CL_max = air_foil_data(3);
R_min = Radius_of_turn(V,W_L,S,Tmax,Cdi,CL_max,e,AR,K);
fprintf('The minimum radius of turn for this design is %f \n', R_min)
% check if turn radius fits in the flight area
if R_min >= (100/3.28)
    fprintf('Warning: The minimum radius of turn for this design is too large for the flight area \n')
end
%% Range Estimation

Margin = 1;   % fraction of battery dedicated to horizontal flight
P_autonomy = 0;    %[placeholder] power requirements for full autonomy during steady level flight
Voltage = 11.1; % voltage of 3S battery
Capacity = 2.2; % capacity of battery in Ampere-hours
% time of flight in seconds
t_horz = Margin*Capacity*Voltage*3600/(Horz_Power + P_autonomy)

%% Alternate Range Estimation
Cd0 = Cdi;  % place holder for total induced drag
eta_tot = 0.5; % placeholder for motor efficiency

[U_r, t_flight] = endurance(W_L,rho,S,K,Cd0,eta_tot,Voltage,Capacity)

%% Score Calculation
%SCORE
