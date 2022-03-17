function [hilos] = ang2long(newConfig)

pos = config2joints(newConfig);

%% ANGULOS TOTALES

    %Seccion 1
    eje1_2 = 9*pos(3);                %----------- Motores 1 y 2
    eje3_4 = 10*pos(2);               %----------- Motores 3 y 4

    %Secion 2
    eje5_6 = 6*pos(21);                %----------- Motores 5 y 6
    eje7_8 = 6*pos(22);               %----------- Motores 7 y 8

    %Seccion 3
    eje9_10 = 6*pos(33);                %----------- Motores 9 y 10
    eje11_12 = 6*pos(34);               %----------- Motores 11 y 12

    %Seccion 4
    eje13_14 = 4*pos(45);                %----------- Motores 13 y 14
    eje15_16 = 4*pos(46);               %----------- Motores 15 y 16

%% LONGITUDES

% 7,39mm/rad

    %Seccion 1
    if eje1_2 < 0
        longM1 = 7.39 * eje1_2;       %Tira el 1
        longM2 = -(7.39 * eje1_2);
    else
        longM1 = -(7.39 * eje1_2);    %Tira el 2
        longM2 = 7.39 * eje1_2;
    end

    if eje3_4 > 0
        longM3 = 7.39 * eje3_4;       %Tira el 3
        longM4 = -(7.39 * eje3_4);
    else
        longM3 = -(7.39 * eje3_4);    %Tira el 4
        longM4 = 7.39 * eje3_4;
    end

    %Seccion 2
    if eje5_6 > 0
        longM5 = 7.39 * eje5_6;
        longM6 = -(7.39 * eje5_6);
    else
        longM5 = -(7.39 * eje5_6);
        longM6 = 7.39 * eje5_6;
    end

    if eje7_8 > 0
        longM7 = 7.39 * eje7_8;
        longM8 = -(7.39 * eje7_8);
    else
        longM7 = -(7.39 * eje7_8);
        longM8 = 7.39 * eje7_8;
    end

    %Seccion 3
    if eje9_10 > 0
        longM9 = 7.39 * eje9_10;
        longM10 = -(7.39 * eje9_10);
    else
        longM9 = -(7.39 * eje9_10);
        longM10 = 7.39 * eje9_10;
    end

    if eje11_12 > 0
        longM11 = 7.39 * eje11_12;
        longM12 = -(7.39 * eje11_12);
    else
        longM11 = -(7.39 * eje11_12);
        longM12 = 7.39 * eje11_12;
    end

    %Seccion 4
    if eje13_14 > 0
        longM13 = 7.39 * eje13_14;
        longM14 = -(7.39 * eje13_14);
    else
        longM13 = -(7.39 * eje13_14);
        longM14 = 7.39 * eje13_14;
    end

    if eje15_16 > 0
        longM15 = 7.39 * eje15_16;
        longM16 = -(7.39 * eje15_16);
    else
        longM15 = -(7.39 * eje15_16);
        longM16 = 7.39 * eje15_16;
    end
    
    hilos = [longM1, longM2, longM3, longM4, longM5, longM6, longM7, longM8, longM9, longM10, longM11, longM12, longM13, longM14, longM15, longM16];

end

