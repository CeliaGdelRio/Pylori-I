%OBJETIVO:
%Optimización de la configuración del robot para alcanzar con éxito el
%punto [0, 125, 100] de manera que la manipulabilidad sea máxima.

global TotalLinks length NSections MinAlpha NMembers score;

NMembers = 50; %Número de muestras en la población.
maxIter = 50;  %Máximo de iteraciones para el algoritmo.
iter = 0;
score = zeros(1, NMembers);    %Vector de putuaciones.
meanScores = zeros(1, maxIter);%Historico de puntuaciones medias.
maxScores = zeros(1, maxIter); %Historico de puntuaciones maximas.

TotalLinks = 100;   %Número total de enlaces de los robots.
length = 5 * TotalLinks;

NSections = 5;  %Número de secciones de los robots.

MinAlpha = pi*10/180;   %Mínimo valor de alpha admisible.

%Posicion objetivo:
x0 = 0;
y0 = 250;
z0 = 250;

logService('TRACE', 'PRIMERA POBLACION...');
P = initPopulation();
logService('TRACE', '... END PRIMERA POBLACION');

%% MAIN FLOW
logService('TRACE', 'MAIN LOOP...');
while iter < maxIter
    %EVALUACIÓN
    score = evaluate(P, x0, y0, z0);iKineGradientDescent
    meanScores(iter+1) = mean(score);
    maxScores(iter+1) = max(score);
    logService('INFO', 'Mean Score:');
    logService('INFO', meanScores(iter+1));
    
    %SELECCIÓN
    Ps = selection(P, 0.4);
    
    %CRUCE
    P = mix(P, Ps);
    
    iter = iter + 1;
    logService('INFO', "Progress: " + iter*100/maxIter + "%");
end
logService('TRACE', '... END MAIN LOOP');
%%
score = evaluate(P, x0, y0, z0);
logService('INFO', 'End score:');
logService('INFO', score);


%% INITIAL POPULATION
function P = initPopulation()
    global NMembers NSections TotalLinks;
    
    logService('DEBUG', 'INI - initPopulation');
    
    %Cell array for robot objects
    P = cell(1, NMembers);
    
    %Incialization of each robot
    logService('DEBUG', 'Inicializando robots...');
    for r = 1:NMembers
        N = randomNLinks();
        [A, ~] = defaultAlphas();
        for s = 1:NSections
            if N(s) == 0
                N(s) = 1;
            end
        end        
        P{r} = HRRTree(N, A);
    end
    logService('INFO', "Initial NLinks:");
    for r = 1:NMembers
        logService('INFO', P{r}.NLinks);
        sum = 0;
        for s = 1:NSections
            sum = sum + P{r}.NLinks(s);
        end
    
        if sum ~= TotalLinks
            logService('ERROR', 'Number of links differs from TotalLinks');
        end
    end
    
    logService('INFO', "Initial Alphas:");
    for r = 1:NMembers
        logService('INFO', P{r}.Alpha);
    end
    logService('DEBUG', 'FIN - initPopulation');
end

%% EVALUATION
function S = evaluate(P, x0, y0, z0)
    global NMembers length;
    logService('DEBUG', 'INI - evaluate');
    
    S = zeros(1, NMembers);
    parfor i = 1:NMembers
        currentPos = tform2trvec(P{i}.fKine(P{i}.Config));
        [X, Y, Z] = trajectory3(currentPos, [x0 y0 z0], 6, 'RECT');
        [~, error, ~] = P{i}.move(X, Y, Z, 'GradientDescent', 'Error', 0.05 * length);
        
        J = P{i}.jacobianHRR();
        m = manipulability(J);
        
        if error{1,1} >= 10
            S(i) = 0;
        else
            S(i) = m;
        end
    end
    logService('DEBUG', 'FIN - evaluate');
end

%% SELECTION
function Ps = selection(P, percentage)
    global NMembers score;
    logService('DEBUG', 'INI - selection');
    
    NSurvivors = cast(percentage*NMembers, 'uint8');
    Ps = cell(1, NSurvivors);
    
    maxScore = max(score);
    minScore = min(score);
    probSurv = zeros(1, NMembers);
    
    for i = 1:NMembers
        probSurv(i) = (score(i) - minScore)/(maxScore - minScore);
    end
    
    i = 1;
    j = 1;
    while j <= NSurvivors
        prob = rand();
        if prob < probSurv(i)
            Ps{j} = P{i};
            j = j + 1;
        end
        
        i = i + 1;
        if i > NMembers
            i = 1;
        end
    end
    
    logService('DEBUG', 'FIN - selection');
end

%% MIX
function Pm = mix(P, Ps)
    global NMembers score;
    logService('DEBUG', 'INI - mix');
    
    Pm = P;
    Ns = length(Ps);
    [~, best] = max(score);
    
    for i = 1:NMembers-1
        Z = 1;
        while Z
            Z = 0;
            w = rand(1, 2);
            F = cast(w(1)*Ns, 'uint8');
            M = cast(w(2)*Ns, 'uint8');
            if F == 0 || M == 0
                Z = 1;
            end
        end
        
        Pm{i} = reproduction(Ps{F}, Ps{M});
    end
    
    Pm{NMembers} = P{best};
    logService('DEBUG', 'FIN - mix');
end

%% REPRODUCTION
function Son = reproduction(F, M)
    global NSections TotalLinks;
    logService('DEBUG', 'INI - reproduction');
    
    wf = rand(); %Porcentaje de influencia del padre
    wm = rand(); %Porcentaje de influencia de la madre
    sum = 0.0;
    
    %1. Ponderacion del gen NLinks:
        NLinksF = cast(wf*F.NLinks, 'uint16');
        NLinksM = cast(wm*M.NLinks, 'uint16');

        NLinksSon = NLinksF + NLinksM;   %GenHijo = Suma ponderada GenPadres

    %2. Mutacion:
    Z = 1;
    while Z
        Z = 0;
        for i = 1:NSections
            if rand() > 0.9 %Probabilidad de mutacion
                if rand() > 0.5
                    NLinksSon(i) = NLinksSon(i) + 5;
                else
                    NLinksSon(i) = NLinksSon(i) - 5;
                    if NLinksSon(i) <= 0
                        NLinksSon(i) = 1;
                    end
                end
            end
            sum = sum + cast(NLinksSon(i)*1.0, 'double');
        end
        k=cast(TotalLinks*1.0, 'double') / sum;
        %Limitacion a TotalLinks, solo se modifica la distribucion:
        for i = 1:NSections
            NLinksSon(i) = cast(k * NLinksSon(i), 'uint16');
            if NLinksSon(i) == 0
                logService('DEBUG', 'Seccion vacia. Repitiendo reproduccion..."');
                Z = 1;
                sum = 0;
                break;
            end
        end
    end
    %3. Creacion del hijo
        [A, ~] = defaultAlphas();
        Son = HRRTree(NLinksSon, A);
    logService('DEBUG', 'FIN - reproduction');
end

%% RANDOM NLINKS
function N = randomNLinks()
    global TotalLinks NSections; 
    logService('DEBUG', 'INI - randomNLinks');
    N = zeros(1, NSections);
    sum = 0.0;
    sumN = 0;
    Z = 1; 
    
    rng('shuffle');
   
    %Asignacion de valores al vector:
    while Z    %Mientras ninguno sea cero...
        Z = 0;
        M = rand([1 NSections]);    %N de enlaces aleatorio a cada seccion (tanto por uno)
        for i = 1:NSections
           sum = sum + M(i);    %Suma de todos los enlaces
        end
    
        %Normalizado del vector:    
        for i = 1:NSections
            N(i) = cast(M(i)/sum*cast(TotalLinks, 'double'), 'uint16');
            sumN = sumN + N(i);
            %Si uno es cero se repite el proceso
            if N(i) == 0
               Z = 1;
               sum = 0.0;
               sumN = 0;
               break;
            end
        end 
        
        N(1) = N(1) + (TotalLinks - sumN);
    end 
    logService('DEBUG', 'FIN - randomNLinks');  
end

%% RANDOM ALPHAS
function [A, K] = randomAlphas()
    global NSections MinAlpha;
    logService('DEBUG', 'INI - randomAlphas');
    
    rng('shuffle');
    
    maxK = cast(2*pi/MinAlpha, 'uint8');    %Max N de veces que se puede sumar MinAlpha en un disco
    
    A = zeros(1, NSections);
    K = rand([1 NSections]);    %Angulo en tanto por uno aleatorio en cada seccion
    
    for i = 1:NSections 
        K(i) = cast(K(i)*maxK, 'uint8');    %Paso de tanto por uno a entero
        A(i) = 2*pi/K(i);   %Asignacion de angulos
    end
    logService('DEBUG', 'FIN - randomAlphas');
end

%% DEFAULT ALPHAS
function [A, K] = defaultAlphas()
    global NSections;
    logService('DEBUG', 'INI - defaultAlphas');
    
    A = zeros(1, NSections);
    K = rand([1 NSections]);
    
    for i = 1:NSections 
        K(i) = 2;
        A(i) = pi/2.0;
    end
    logService('DEBUG', 'FIN - defaultAlphas');
end