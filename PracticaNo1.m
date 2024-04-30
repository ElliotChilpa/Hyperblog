clear all
close all
clc

n_muestras = 30; %numero de muestras por pulso

sf = 64; %factor de dispersión máxima
ovsf = cell(log2(sf)+1,1); %celdas que almecenen los códigos de hasta sf
ovsf{1} = 0; 

%GENERACION DE CODIGOS OVSF
for i=2:log2(sf)+1
    orden = 2^(i-1);
    for j   =1:orden/2 %bifurcaciones
        if j == 1 %para la primer bifurcación 
            ovsf{i}(1:orden) = repmat(ovsf{i-1}(1,:), 1,2);
        else
            ovsf{i}(end+1, :) = repmat(ovsf{i-1}(j,:), 1, 2);
        end
        ovsf{i}(end+1, :) =  [ovsf{i-1}(j,:) ~ovsf{i-1}(j,:)]; %2do código de la bifurcación
    end
end

%GENERACION DE CODIGOS: 1 con FD = 4, 2 con FD = 8 (y 2 con FD = 16)
%si se usa el cx_y, se usa un FD 'x' y ya no se usa c(2*x)_(y*2) ni c(2*x)_(y*2+1)
%si se desea el cx_y, se llama ovsf{}(y+1,:)
tf = 16; %tiempo final, tener en cuenta que el t_bit de cada código cambia. 
figure
%para el código de 4 bits, cada bit dura 4 instantes de tiempo
R1 = 4;
[c4_3,t] =pulsos(ovsf{3}(4,:),n_muestras,tf); %código con FD 4, ya no se usa c8_6 y c8_7
subplot(5, 1, 1)
plot(t, c4_3, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Codigo1 c4_3")

%para el código de 8 bits, cada bit dura 2 instantes de tiempo
R2 = 8;
[c8_5,t] = pulsos(ovsf{4}(6,:),n_muestras,tf);%código con FD 8, ya no se usa c16_10 y c16_11
c8_4 = pulsos(ovsf{4}(5,:),n_muestras,tf);%código con FD 8, ya no se usa c16_8 y c16_9
subplot(5, 1, 2)
plot(t, c8_5, 'b', 'LineWidth', 2), grid on, xlim([0 tf]), title("Codigo2 c8_5")
% subplot(5, 1, 3)
% plot(t, c8_4, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Codigo1 c8_4")

%para el código de 16 bits, cada bit dura 1 instantes de tiempo
R3 = 16;
[c16_7,t] = pulsos(ovsf{5}(8,:),n_muestras,tf);%código con FD 16, ya no se usa c32_14 y c32_15
c16_6 = pulsos(ovsf{5}(7,:),n_muestras,tf);%código con FD 16, ya no se usa c32_12 y c32_13
subplot(5, 1, 3)
plot(t, c16_7, 'b', 'LineWidth', 2), grid on, xlim([0 tf]), title("Codigo2 c16_7")
% subplot(5, 1, 5)
% plot(t, c16_6, 'b', 'LineWidth', 2), grid on, xlim([0 tf]), title("Codigo2 c16_6")

FD = 16;

%GENERACION BITS ALEATORIOS para cada usuario
users_4= randi([0 1], 4, 1)'; % para SF = 4
users_2 = randi([0 1], 2, 2); %para SF = 8
users_1 = randi([0 1], 1, 1); %para SF = 16
user1 = users_4;
user2 = users_2(1,:);
% user3 = users_2(2,:);
user4 = users_1(1);
% user5 = users_1(2);



% Mostrar bits aleatorios en una tabla
tabla_bits = table({user1}, {user2}, {user4}, 'VariableNames', {'User1', 'User2', 'User4'});
disp(tabla_bits);

figure
[u1,t] = pulsos(user1,n_muestras,tf);
subplot(5, 1, 1)
plot(t, u1, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Bits aleatorios user 1")

[u2,t] = pulsos(user2,n_muestras,tf);
subplot(5, 1, 2)
plot(t, u2, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Bits aleatorios user 2")

% [u3,t] = pulsos(user3,n_muestras,tf);
% subplot(5, 1, 3)
% plot(t, u3, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Bits aleatorios user 3")

[u4,t] = pulsos(user4,n_muestras,tf);
subplot(5, 1, 3)
plot(t, u4, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Bits aleatorios user 4")

% [u5,t] = pulsos(user5,n_muestras,tf);
% subplot(5, 1, 5)
% plot(t, u5, 'r', 'LineWidth', 2), grid on, xlim([0 tf]), title("Bits aleatorios user 5")

%DISPERSION DE LAS SEÑALES
figure
aux1 = [];
cd1 = repelem(ovsf{3}(4,:), 4);
for n = 1:1:length(user1)
    sd = repelem(user1(n), R1);
    aux1 = [aux1 sd];
end
aux1 = 1 - 2 * aux1;

aux2 = [];
cd2 = repelem(ovsf{4}(5,:), 2);
for n = 1:1:length(user2)
    sd = repelem(user2(n), R2);
    aux2 = [aux2 sd];
end
aux2 = 1 - 2 * aux2;

% aux3 = [];
% cd3 = repelem(ovsf{4}(6,:), 2);
% for n = 1:1:length(user3)
%     sd = repelem(user3(n), R2);
%     aux3 = [aux3 sd];
% end
% aux3 = 1 - 2 * aux3;

aux4 = [];
cd4 =ovsf{5}(7,:);
for n = 1:1:length(user4)
    sd = repelem(user4(n), R3);
    aux4 = [aux4 sd];
end
aux4 = 1 - 2 * aux4;
% 
% aux5 = [];
% cd5 = ovsf{5}(8,:);
% for n = 1:1:length(user5)
%     sd = repelem(user5(n), R3);
%     aux5 = [aux5 sd];
% end
% aux5 = 1 - 2 * aux5;

cd1 = 1 - 2 * cd1;
cd2 = 1 - 2 * cd2;
% cd3 = 1 - 2 * cd3;
cd4 = 1 - 2 * cd4;
% cd5 = 1 - 2 * cd5;

sd1 = aux1 .*cd1;
sd2 = aux2 .*cd2;
% sd3 = aux3 .*cd3;
sd4 = aux4 .*cd4;
% sd5 = aux5 .*cd5;

sd1 = (1-sd1)/2;
[pd1,t] = pulsos(sd1,n_muestras,16);
subplot(5, 1, 1)
plot(t, pd1, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal dispersa del usuario 1")

sd2 = (1-sd2)/2;
[pd2,t] = pulsos(sd2,n_muestras,16);
subplot(5, 1, 2)
plot(t, pd2, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal dispersa del usuario 2")

% sd3 = (1-sd3)/2;
% [pd3,t] = pulsos(sd3,n_muestras,16);
% subplot(5, 1, 3)
% plot(t, pd3, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal dispersa del usuario 3")

sd4 = (1-sd4)/2;
[pd4,t] = pulsos(sd4,n_muestras,163);
subplot(5, 1, 3)
plot(t, pd4, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal dispersa del usuario 4")

% sd5 = (1-sd5)/2;
% [pd5,t] = pulsos(sd5,n_muestras,16);
% subplot(5, 1, 5)
% plot(t, pd5, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal dispersa del usuario 5")

sd1 = aux1 .*cd1;
sd2 = aux2 .*cd2;
% sd3 = aux3 .*cd3;
sd4 = aux4 .*cd4;
% sd5 = aux5 .*cd5;

% SEÑAL MULTIPLEXADA
sm = sd1+sd2+sd4;
[pm,t] = pulsos(sm,n_muestras,16);
figure 
plot(t, pm, 'b', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal multiplexada")


%CORRELACIÓN DE LA SEÑAL MULTIPLEXADA
br1 = sm.*cd1;
br1 =[sum(br1(1:4))/4 sum(br1(5:8))/4 sum(br1(9:12))/4 sum(br1(13:16))/4];

br2 = sm.*cd2;
br2=[sum(br2(1:8))/8 sum(br2(9:16))/8];

% br3 = sm.*cd3;
% br3=[sum(br3(1:8))/8 sum(br3(9:16))/8];

br4 = sum(sm.*cd4)/16;

% br5 = sum(sm.*cd5)/16;

figure
user1_rx = [];
for i = 1:length(br1)
    if user1(i) > 0
        user1_rx = [user1_rx 1];
    else 
        user1_rx = [user1_rx 0];
    end
end
[rx1,t] = pulsos(user1_rx,n_muestras,16);
subplot(5, 1, 1)
plot(t, rx1, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal recibida user 1")

user2_rx = [];
for i = 1:length(br2)
    if user2(i) > 0
        user2_rx = [user2_rx 1];
    else 
        user2_rx = [user2_rx 0];
    end
end
[rx2,t] = pulsos(user2_rx,n_muestras,16);
subplot(5, 1, 2)
plot(t, rx2, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal recibida user 2")

% user3_rx = [];
% for i = 1:length(br3)
%     if user3(i) > 0
%         user3_rx = [user3_rx 1];
%     else 
%         user3_rx = [user3_rx 0];
%     end
% end
% [rx3,t] = pulsos(user3_rx,n_muestras,16);
% subplot(5, 1, 3)
% plot(t, rx3, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal recibida user 3")

user4_rx = [];
for i = 1:length(br4)
    if user4(i) > 0
        user4_rx = [user4_rx 1];
    else 
        user4_rx = [user4_rx 0];
    end
end
[rx4,t] = pulsos(user4_rx,n_muestras,16);
subplot(5, 1, 3)
plot(t, rx4, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal recibida user 4")

% user5_rx = [];
% for i = 1:length(br5)
%     if user5(i) > 0
%         user5_rx = [user5_rx 1];
%     else 
%         user5_rx = [user5_rx 0];
%     end
% end
% [rx5,t] = pulsos(user5_rx,n_muestras,16);
% subplot(5, 1, 5)
% plot(t, rx5, 'r', 'LineWidth', 2), grid on, xlim([0 16]), title("Señal recibida user 5")


function [c,t] = pulsos(codigo,muestras,tf)
    %normaliza de -1 a 1
    c = 1 - 2 * codigo;
    c = repelem(c, muestras);
    t = linspace(0, tf, length(c))
end