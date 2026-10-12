%% BATALHA NAVAL 3D - VERSAO COMPLETA
clear; clc;

%% --- MENU PRINCIPAL ---
sairDoJogo = false;
global espacoLivre;
espacoLivre = false;

reproduzir_som_inicio();
clc;
while ~sairDoJogo
    disp('=== BATALHA NAVAL 3D ===');
    disp('1 - Iniciar novo jogo (2 jogadores)');
    disp('2 - Jogar contra o computador');
    disp('3 - Configurações');
    disp('4 - Consultar histórico de jogos');
    disp('5 - Sair');
    

    opcao_valida = false;
    while ~opcao_valida
        opcao = str2double(input('Escolha uma opção: ', 's'));
        if isnan(opcao) || ~ismember(opcao,1:5)
            disp('Erro: Insira apenas números de 1 a 5!');
        else
            opcao_valida = true;
        end
    end

    switch opcao
        case 1, jogarBatalhaNaval(false);
        case 2, jogarBatalhaNaval(true);
        case 3, configuracoes();
        case 4, consultar_historico();
        case 5
            sairDoJogo = true;
            disp('Obrigado por jogar! Até a próxima!');
        
    end
end


%% --- INICIALIZACAO DOS JOGADORES ---
function jogarBatalhaNaval(singlePlayer)
    clc;
    partidaConcluida = false;

    % Inicializa jogadores, tabuleiros e frotas
    nomes = cell(1,2);
    tabuleiros = cell(1,2);
    frotas = cell(1,2);

    % Captura nomes e distribui frotas em um único loop
    for i = 1:2
        % Nome do jogador ou Computador
        if i == 2 && singlePlayer
            nomes{i} = 'Computador';
        else
            nome_valido = false;
            while ~nome_valido
                nomes{i} = input(sprintf('Jogador %d (nome de guerra): ', i), 's');
                if ~isempty(strtrim(nomes{i}))
                    nome_valido = true;
                else
                    disp('Nome não pode ser vazio!');
                end
            end
        end
        
        % Escolha de distribuição de frota
        if i == 2 && singlePlayer
             escolha = 'A'; % Computador sempre usa distribuição automática
        else
        escolha = '';
        while ~ismember(upper(escolha), {'A','M'})
            escolha = input('Distribuição (A)utomática ou (M)anual? ', 's');
        end
        end
        if upper(escolha) == 'M'
            [tabuleiros{i}, frotas{i}] = distribuir_frota_manual();
        else
            [tabuleiros{i}, frotas{i}] = distribuir_frota();
        end
    end

    % Sorteio de quem inicia
    jogadorAtual = randi(2);
    disp(['O jogador que começa é: ', nomes{jogadorAtual}]);

    % Loop de jogo
    fimDeJogo = false;
    jogadas = 0;
    totalAcertos = [0, 0];
    maxAcertos = 4*1 + 3*2 + 2*3 + 1*4 + 1*27;

while ~fimDeJogo  
    clc;
    jogadas = jogadas + 1;
    fprintf('--- Jogada %d ---\n', jogadas);
    
    jogador = jogadorAtual;
    oponente = 3 - jogador; 
    nomeJog = nomes{jogador}; 
    
    fprintf('É a vez de %s\n', nomeJog);

    % Exibir estatísticas do jogo
    fprintf('=== Estatísticas ===\n');
    fprintf('Jogadas realizadas: %d\n', jogadas);
    fprintf('Total de acertos: %d\n', totalAcertos(jogador));
    fprintf('Acertos restantes para vencer: %d\n\n', maxAcertos - totalAcertos(jogador));
    
    fprintf('=== Navios Inimigos ===\n');
    status_frota = obter_status_frota(frotas{oponente});
    disp(status_frota);

    if singlePlayer && jogador == 2
        % Lógica do computador (só eixo Z)
        eixo = 'z';  % Força sempre eixo Z
        coord = randi([0,9], 1, 2); 
        coord = coord + 1;
        % Determinar coordenadas
        if eixo == 'x'
            x = 1:10;
            y = coord(1);
            z = coord(2);
        elseif eixo == 'y'
            x = coord(1);
            y = 1:10;
            z = coord(2);
        else
            x = coord(1);
            y = coord(2);
            z = 1:10;
        end
        disp('Pressione qualquer tecla para continuar...');
        pause;
        % Disparar
        [tabuleiros{oponente}, frotas{oponente}, acertos] = disparar(tabuleiros{oponente}, frotas{oponente}, x, y, z);
        totalAcertos(jogador) = totalAcertos(jogador) + acertos;
        
        % Mensagem
        fprintf('O Computador disparou no eixo %s, coordenadas fixas %d e %d.\n', upper(eixo), coord(1)-1, coord(2)-1);
        fprintf('Acertos nesta jogada: %d\n', acertos);
        
        % Verificar vitória
        if totalAcertos(jogador) >= maxAcertos
            fprintf('\n\n🏆 O COMPUTADOR VENCEU! 🏆\n');
            fimDeJogo = true;
            reproduzir_som_vitoria();
            partidaConcluida = true; 
            salvar_resultado(nomes{1}, nomes{2}, jogadas, nomes{jogador}, partidaConcluida); 
        end
        
        % Atualizar plots
        figure(1); clf;
        set(gcf, 'Position', [100, 100, 1200, 600]);                
        subplot(1,2,1);
        plot_tabuleiro(tabuleiros{1}, ['Tabuleiro de ' nomes{1}]);
        title(sprintf('🎯 %s ', nomes{1}));                
        subplot(1,2,2);
        plot_tabuleiro(tabuleiros{2}, ['Impactos em ' nomes{2}]);
        title(sprintf('🔥 %s ', nomes{2}));
        
        % Passar a vez
        jogadorAtual = oponente;
        pause(2);
         
    else
        % Lógica para jogador humano
        disp('1 - Realizar disparo');
        
        disp('2 - Voltar ao menu principal');
        opcao_valida_jogo = false;
while ~opcao_valida_jogo
    opcao_str = input('Escolha: ', 's');
    opcaoJogo = str2double(opcao_str);
    if isnan(opcaoJogo) || ~ismember(opcaoJogo, [1 2])
        disp('Opção inválida! Escolha 1 ou 2.');
    else
        opcao_valida_jogo = true;
    end
end
        
        switch opcaoJogo
            case 1 
             eixo = lower(input('Eixo de disparo (x/y/z): ', 's')); 
                while ~ismember(eixo, {'x','y','z'})                   
                    eixo = lower(input('Eixo inválido! Escolha x/y/z: ', 's')); 
                end
    
                % Obter coordenadas de acordo com o eixo
                exemplo = {'yz','xz','xy'};
                   valido = false;
                while ~valido
             
                    coordStr = input(sprintf('Coordenadas fixas (ex: %s): ', exemplo{find(eixo == ['x','y','z'], 1)}), 's');
                    coordStr = strrep(coordStr, ' ', '');  % Remove espaços
                    if length(coordStr) == 2 && all(isstrprop(coordStr, 'digit'))
                        coord = [str2double(coordStr(1)), str2double(coordStr(2))];
                    else
                        coord = sscanf(coordStr, '%d %d')';
                    end
                    coord = round(coord); 
                    
                    if numel(coord) == 2 && all(coord >= 0 & coord <= 9)
                        valido = true;
                    else
                        disp('Erro: informe duas coordenadas entre 0 e 9,(ex: 79).');
                    end
                end
                                    
                % Converter para coordenadas 3D

                coord = coord + 1;

                if eixo == 'x'
                    x = 1:10; y = coord(1); z = coord(2);
                elseif eixo == 'y'
                    x = coord(1); y = 1:10; z = coord(2);
                else
                    x = coord(1); y = coord(2); z = 1:10;   
                end
               
                % Executar disparo
                [tabuleiros{oponente}, frotas{oponente}, acertos] = disparar(tabuleiros{oponente}, frotas{oponente}, x, y, z);
                totalAcertos(jogador) = totalAcertos(jogador) + acertos; 
    
                % Plotar tabuleiro
                figure(1); clf;
                set(gcf, 'Position', [100, 100, 1200, 600]);
                
                subplot(1,2,1);
                plot_tabuleiro(tabuleiros{1}, ['Tabuleiro de ' nomes{1}]);
                title(sprintf('🎯 %s ', nomes{1}));
                
                subplot(1,2,2);
                plot_tabuleiro(tabuleiros{2}, ['Impactos em ' nomes{2}]);
                title(sprintf('🔥 %s ', nomes{2}));

                
                % Verificar vitória
                if totalAcertos(jogador) >= maxAcertos
                    fprintf('\n\n🏆 VITÓRIA DE %s! 🏆\n', upper(nomeJog)); 
                    fimDeJogo = true;
                    reproduzir_som_vitoria();
                   partidaConcluida = true;
                    salvar_resultado(nomes{1}, nomes{2}, jogadas, nomes{jogador}, partidaConcluida);
                end

                jogadorAtual = oponente; 
           
            case 2
                 partidaConcluida = false; 
                salvar_resultado(nomes{1}, nomes{2}, jogadas, 'N/A', partidaConcluida);
                close all;
                return;
            otherwise
               disp('Opção inválida! Pressione qualquer tecla para continuar...');
                pause;
        end
    end 
    
end
end
%% --- FUNÇÕES AUXILIARES---

function status = obter_status_frota(frota)
    tipos_lineares = {
        'caca',          1, 4;    
        'fragata',       2, 3;    
        'contratorpedeiro', 3, 2; 
        'cruzador',      4, 1     
    };
    
    status = '';
    
    for t = 1:size(tipos_lineares, 1)
        tipo = tipos_lineares{t, 1};
        tamanho = tipos_lineares{t, 2};
        qtd_original = tipos_lineares{t, 3};
        
        afundados = qtd_original;
        partes_atingidas = 0;
        
        if isfield(frota, tipo)
            navios = frota.(tipo);
            qtd_atual = length(navios);
            afundados = qtd_original - qtd_atual;
            
            partes_restantes = 0;
            for i = 1:qtd_atual
                partes_restantes = partes_restantes + size(navios(i).coords, 1);
            end
            partes_originais = qtd_original * tamanho;
            partes_atingidas = partes_originais - partes_restantes;
        else
            partes_atingidas = qtd_original * tamanho;
        end
        
        status = sprintf('%s%s: %d/%d afundados, %d/%d partes atingidas\n', status, ...
            upper(tipo), afundados, qtd_original, partes_atingidas, qtd_original * tamanho);
    end
    
    partes_atingidas_nm = 0;
    afundada_nm = 0;
    if isfield(frota, 'nave_mae') && ~isempty(frota.nave_mae)
        coords_nm = frota.nave_mae.coords;
        partes_restantes_nm = size(coords_nm, 1);
        partes_atingidas_nm = 27 - partes_restantes_nm;
        afundada_nm = (partes_restantes_nm == 0);
    else
        partes_atingidas_nm = 27;
        afundada_nm = 1;
    end
    status = sprintf('%sNAVE-MÃE: %d/1 afundada, %d/27 partes atingidas\n', status, afundada_nm, partes_atingidas_nm);
end

function configuracoes()
    global espacoLivre;
    while true
        clc;
        disp('=== CONFIGURAÇÕES ===');
        if espacoLivre
            disp('1 - Espaço entre navios: Ligado');
        else
            disp('1 - Espaço entre navios: Desligado');
        end
        disp('2 - Voltar');
        opcao = input('Escolha uma opção: ');
        
        switch opcao
            case 1
                espacoLivre = ~espacoLivre;
                if espacoLivre
                    disp('Espaço entre navios LIGADO!');
                else
                    disp('Espaço entre navios DESLIGADO!');
                end
                pause(1);
            case 2
                return;
            otherwise
                disp('Opção inválida!');
                pause(1);
        end
    end
end

function [tabuleiro, frota] = distribuir_frota_manual()
    global espacoLivre;
    tabuleiro = zeros(10,10,10);
    frota = struct();

    tipos = { {'caca',1,4,2}, {'fragata',2,3,3}, {'contratorpedeiro',3,2,4}, {'cruzador',4,1,5}, {'nave_mae',3,1,6} };

    for t = 1:length(tipos)
        tipo = tipos{t}{1}; 
        tamanho_navio = tipos{t}{2}; 
        qtd = tipos{t}{3}; 
        code = tipos{t}{4};
        
        for n = 1:qtd
            colocou = false;
            % Alteração 2: Posição inicial centralizada para nave-mãe
            if strcmp(tipo, 'nave_mae')
                pos = [5,5,5]; % Inicia no centro
            else
                pos = [1,1,1];
            end
            axis = 'x';
            tamanho = tamanho_navio;
            
            while ~colocou
                if strcmp(tipo, 'nave_mae')
                    hFig = figure('Name', sprintf('%s #%d', upper(tipo), n), 'KeyPressFcn', @keyPressNM);
                    drawShipNM();
                    uiwait(hFig);
                else
                    hFig = figure('Name', sprintf('%s #%d', upper(tipo), n), 'KeyPressFcn', @keyPress);
                    drawShip();
                    uiwait(hFig);
                end

                if strcmp(tipo, 'nave_mae')
                    [X,Y,Z] = meshgrid(pos(1)-1:pos(1)+1, pos(2)-1:pos(2)+1, pos(3)-1:pos(3)+1);
                    coords = [X(:), Y(:), Z(:)];
                    coords = coords(all(coords >= 1 & coords <= 10, 2), :);
                else
                    coords = computeCoords(pos, tamanho, axis);
                end

                valido = validar_posicao(coords, tabuleiro, espacoLivre);
                if valido
                    for k = 1:size(coords, 1)
                        tabuleiro(coords(k,1), coords(k,2), coords(k,3)) = code;
                    end
                    frota.(tipo)(n).coords = coords;
                    colocou = true;
                else
                    uiwait(errordlg('Posição inválida! Navios não podem se sobrepor.'));
                end
            end
        end
    end

   function keyPressNM(src, event)
        % Alteração 1: Limites de movimento para 2-9
        switch event.Key
            case 'uparrow', pos(2) = min(9, pos(2)+1);
            case 'downarrow', pos(2) = max(2, pos(2)-1);
            case 'leftarrow', pos(1) = max(2, pos(1)-1);
            case 'rightarrow', pos(1) = min(9, pos(1)+1);
            case 'w', pos(3) = min(9, pos(3)+1);
            case 's', pos(3) = max(2, pos(3)-1);
            case 'return', delete(src); uiresume;
        end
        drawShipNM();
    end

     function drawShipNM()
        clf; hold on;
        [exX, exY, exZ] = ind2sub(size(tabuleiro), find(tabuleiro ~= 0));
        scatter3(exX-1, exY-1, exZ-1, 50, [0 0.5 0], 'filled');
        [X,Y,Z] = meshgrid(pos(1)-1:pos(1)+1, pos(2)-1:pos(2)+1, pos(3)-1:pos(3)+1);
        coords = [X(:), Y(:), Z(:)];
        coords = coords(all(coords >= 1 & coords <= 10, 2), :);
        scatter3(coords(:,1)-1, coords(:,2)-1, coords(:,3)-1, 100, 'r', 'filled');
        grid on; xlim([0 9]); ylim([0 9]); zlim([0 9]); 
        view(3); title('Setas: mover | W/S: altura | Enter: confirmar');
        drawnow; hold off;
     end

    function keyPress(src, event)
        switch event.Key
            case 'uparrow', pos(2) = min(10, pos(2)+1);
            case 'downarrow', pos(2) = max(1, pos(2)-1);
            case 'leftarrow', pos(1) = max(1, pos(1)-1);
            case 'rightarrow', pos(1) = min(10, pos(1)+1);
            case {'x','y','z'}, axis = event.Key;
            case 'w', pos(3) = min(10, pos(3)+1);
            case 's', pos(3) = max(1, pos(3)-1);
            case 'return', delete(src); uiresume;
        end
        drawShip();
    end

function drawShip()
        clf; hold on;
        [exX, exY, exZ] = ind2sub(size(tabuleiro), find(tabuleiro ~= 0));
        scatter3(exX-1, exY-1, exZ-1, 50, [0 0.5 0], 'filled');
        coords = computeCoords(pos, tamanho, axis);
        scatter3(coords(:,1)-1, coords(:,2)-1, coords(:,3)-1, 100, 'r', 'filled');
        grid on; xlim([0 9]); ylim([0 9]); zlim([0 9]); 
        view(3); title('Setas: mover | W/S: altura | X/Y/Z: rotar | Enter: confirmar');
        drawnow; hold off;
    end


    function coords = computeCoords(pos, len, axis)
        dir = zeros(1,3);
        switch axis
            case 'x', dir(1) = 1;
            case 'y', dir(2) = 1;
            case 'z', dir(3) = 1;
        end
        coords = pos + (0:len-1)' * dir;
    end
end

function [tabuleiro, frota] = distribuir_frota()
    global espacoLivre;
    tabuleiro = zeros(10,10,10);
    frota = struct(); 
    
    % Definição dos tipos de navios
    tipos_lineares = {
        'caca',          1, 4;    
        'fragata',       2, 3;    
        'contratorpedeiro', 3, 2; 
        'cruzador',      4, 1     
    };
    
    % Posicionamento dos navios lineares
    for t = 1:size(tipos_lineares,1) 
        tipo = tipos_lineares{t,1}; 
        tamanho = tipos_lineares{t,2};  
        qtd = tipos_lineares{t,3}; 
        
        % Determinar código com base no tipo
        switch tipo
            case 'caca'
                code = 2;
            case 'fragata'
                code = 3;
            case 'contratorpedeiro'
                code = 4;
            case 'cruzador'
                code = 5;
        end
        
        for n = 1:qtd
            colocou = false; 
            tentativas = 0;
            
            while ~colocou && tentativas < 1000  
                dir = randi(3);
                pos = randi([1, 11-tamanho],1,3);
                
                coords = zeros(tamanho,3);
                for i = 0:tamanho-1
                    coords(i+1,:) = pos;
                    coords(i+1,dir) = coords(i+1,dir) + i;
                end
                
                valido = true;
                for c = 1:size(coords,1)
                    x = coords(c,1); y = coords(c,2); z = coords(c,3);
                    if any([x,y,z] < 1) || any([x,y,z] > 10) || tabuleiro(x,y,z) ~= 0
                        valido = false;
                        break;
                    end

                    if espacoLivre
                        for dx = -1:1
                            for dy = -1:1
                                for dz = -1:1
                                    if dx == 0 && dy == 0 && dz == 0
                                        continue;
                                    end
                                    nx = x + dx;
                                    ny = y + dy;
                                    nz = z + dz;
                                    if nx >= 1 && nx <= 10 && ny >= 1 && ny <= 10 && nz >= 1 && nz <= 10
                                        if ~ismember([nx ny nz], coords, 'rows') && tabuleiro(nx, ny, nz) ~= 0
                                            valido = false;
                                            break;
                                        end
                                    end
                                end
                                if ~valido, break; end
                            end
                            if ~valido, break; end
                        end
                    end
                    if ~valido, break; end
                end
                
                if valido
                    for c = 1:size(coords,1)
                        tabuleiro(coords(c,1), coords(c,2), coords(c,3)) = code;
                    end
                    
                    
                    if isfield(frota, tipo)
                        frota.(tipo)(end+1).coords = coords;
                    else
                        frota.(tipo).coords = coords;
                    end
                    colocou = true;
                end
                tentativas = tentativas + 1;
            end
            
            if ~colocou
                error('Falha ao posicionar navios! Reinicie o jogo.');
            end
        end
    end
    
    % Posicionamento da nave-mãe (3x3x3)
    colocou = false;
    tentativas = 0;
    tamanho_nave_mae = 3;  
    code = 6;  % Código para nave-mãe
    
    
        end
        while ~colocou && tentativas < 1000
        pos = randi([1, 10-tamanho_nave_mae+1],1,3);
        
        coords = zeros(tamanho_nave_mae^3, 3);
        index = 1;
        for x = 0:tamanho_nave_mae-1
            for y = 0:tamanho_nave_mae-1
                for z = 0:tamanho_nave_mae-1
                    coords(index,:) = pos + [x y z];
                    index = index + 1;
                end
            end
        valido = true;
        for c = 1:size(coords,1)
            x = coords(c,1); y = coords(c,2); z = coords(c,3);
            if any([x,y,z] < 1) || any([x,y,z] > 10) || tabuleiro(x,y,z) ~= 0
                valido = false;
                break;
            end
        end
        
        if valido
            for c = 1:size(coords,1)
                tabuleiro(coords(c,1), coords(c,2), coords(c,3)) = code;
            end
            
            frota.nave_mae.coords = coords;
            colocou = true;
        end
        tentativas = tentativas + 1;
    end
    
    if ~colocou
        error('Falha ao posicionar a nave-mãe! Reinicie o jogo.');
    end
end

function [tabuleiro, frota, acertos] = disparar(tabuleiro, frota, x, y, z)
    acertos = 0;
    
    for i = 1:length(x)
        for j = 1:length(y)
            for k = 1:length(z)
                xi = x(i); yj = y(j); zk = z(k); 
                
                current_val = tabuleiro(xi, yj, zk);
                
                if current_val >=2 && current_val <=6  % Verifica se é um navio não atingido
                    original_code = current_val;
                    tabuleiro(xi, yj, zk) = original_code + 10; % Marca como atingido
                    acertos = acertos + 1;
                    
                    % Atualiza a frota
                    tipos = fieldnames(frota);
                    for t = 1:length(tipos) 
                        navios = frota.(tipos{t});
                        for n = 1:length(navios) 
                            idx = ismember(navios(n).coords, [xi yj zk], 'rows');
                            if any(idx) 
                                navios(n).coords(idx,:) = []; 
                                if isempty(navios(n).coords) 
                                    navios(n) = []; 
                                end
                                frota.(tipos{t}) = navios; 
                                break; 
                            end
                        end
                    end
                    
                elseif current_val ==0  % Água
                    tabuleiro(xi, yj, zk) = -1; 
                end
            end
        end
    end

    if acertos > 0
        reproduzir_som(true); 
    else
        reproduzir_som(false); 
    end
end

function plot_tabuleiro(tab, nome)
    hold on;

    % Informações de cores e nomes para navios atingidos
    ship_hit_info = {
        12, 'Caça', [1 0 0];       % Vermelho
        13, 'Fragata', [0 1 0];    % Verde
        14, 'Contratorpedeiro', [0 0 1]; % Azul
        15, 'Cruzador', [1 1 0];   % Amarelo
        16, 'Nave-Mãe', [1 0 1];   % Magenta
    };

    % Plotar erros (águas)
    [x_miss, y_miss, z_miss] = ind2sub(size(tab), find(tab == -1));
    if ~isempty(x_miss)
        scatter3(x_miss-1, y_miss-1, z_miss-1, 100, [0.5 0.5 0.5], 'filled', 'DisplayName', 'Erros');
    end

    % Plotar acertos por tipo de navio
    for i = 1:size(ship_hit_info, 1)
        code = ship_hit_info{i, 1};
        nome_navio = ship_hit_info{i, 2};
        cor = ship_hit_info{i, 3};
        
        [x_hit, y_hit, z_hit] = ind2sub(size(tab), find(tab == code));
        if ~isempty(x_hit)
            scatter3(x_hit-1, y_hit-1, z_hit-1, 100, cor, 'filled', 'DisplayName', nome_navio);
        end
    end

    grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(['Tabuleiro de ' nome]);
    view(3);
    rotate3d on;
    legend show;
    xlim([0 9]); ylim([0 9]); zlim([0 9]);
    daspect([1 1 1]); 
    hold off;
end

function valido = validar_posicao(coords, tabuleiro, espacoLivre)
    valido = true;
    for c = 1:size(coords,1)
        x = coords(c,1); y = coords(c,2); z = coords(c,3);
        % Verificar limites do tabuleiro
        if any([x,y,z] < 1) || any([x,y,z] > 10)
            valido = false;
            return;
        end
        % Verificar se célula está ocupada
        if tabuleiro(x,y,z) ~= 0
            valido = false;
            return;
        end
        % Verificar espaço ao redor se necessário
        if espacoLivre
            for dx = -1:1
                for dy = -1:1
                    for dz = -1:1
                        if dx == 0 && dy == 0 && dz == 0
                            continue;
                        end
                        nx = x + dx;
                        ny = y + dy;
                        nz = z + dz;
                        if nx >= 1 && nx <= 10 && ny >= 1 && ny <= 10 && nz >= 1 && nz <= 10
                            if tabuleiro(nx, ny, nz) ~= 0
                                valido = false;
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

function reproduzir_som(acertou)
    if acertou 
       [som, Fs] = audioread('hi-hi-hi-ha-clash-royale.wav');
    else
        [som, Fs] = audioread('clash-royale-_-king-crying-1-made-with-Voicemod.wav');
    end
    sound(som, Fs); 
end

function reproduzir_som_vitoria()
    try
        [som, Fs] = audioread('clash-royale-draw.wav'); 
        sound(som, Fs);
    catch
        warning('Arquivo de som de vitória não encontrado.');
    end
end

function reproduzir_som_inicio()
    try
        [som, Fs] = audioread('clash-royale-intro_DU1UL39.wav'); 
        sound(som, Fs);
    catch
        warning('Arquivo de som de início não encontrado.');
    end
end

function salvar_resultado(jogador1, jogador2, jogadas, vencedor, concluida)
    nome_ficheiro = 'resultados.txt';
    
    if ~exist(nome_ficheiro, 'file')
        cabecalho = sprintf('Data\tJogador1\tJogador2\tJogadas\tVencedor\tStatus\n');
        fid = fopen(nome_ficheiro, 'w');
        fprintf(fid, cabecalho);
        fclose(fid);
    end
    
    data = datetime('now', 'Format', 'dd-MM-yyyy HH:mm:ss');
    status = iif(concluida, 'Concluída', 'Abandonada');
    
    fid = fopen(nome_ficheiro, 'a');
    fprintf(fid, '%s\t%s\t%s\t%d\t%s\t%s\n', ...
            char(data), jogador1, jogador2, jogadas, vencedor, status);
    fclose(fid);
end

function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end

function consultar_historico()
    clc;
    nome_ficheiro = 'resultados.txt';
    
    if ~exist(nome_ficheiro, 'file')
        disp('Ainda não há resultados registados!');
        pause(1);
        return
    end
    
    [dados, cabecalho] = ler_resultados(nome_ficheiro);
    
    fprintf('\n=== HISTÓRICO DE JOGOS ===\n');
    fprintf('%-22s %-12s %-12s %-8s %-12s %-12s\n', 'Data', 'Jogador1', 'Jogador2', 'Jogadas', 'Vencedor', 'Status');
    fprintf('---------------------------------------------------------------------------------------------\n'); % Linha separadora
    for i = 1:size(dados,1)
        fprintf('%-22s %-12s %-12s %-8d %-12s %-12s\n', dados{i,:});
    end
    fprintf('\nPressione qualquer tecla para voltar...\n');
    pause;
end

function [dados, cabecalho] = ler_resultados(arquivo)
    fid = fopen(arquivo, 'r');
    cabecalho = fgetl(fid);
    dados = textscan(fid, '%s %s %s %d %s %s', 'Delimiter', '\t');
    fclose(fid);
    
    % Converter para formato de célula uniforme
    num_linhas = length(dados{1});
    dados_formatados = cell(num_linhas, 6);
    for i = 1:num_linhas
        dados_formatados{i,1} = dados{1}{i};
        dados_formatados{i,2} = dados{2}{i};
        dados_formatados{i,3} = dados{3}{i};
        dados_formatados{i,4} = dados{4}(i);
        dados_formatados{i,5} = dados{5}{i};
        dados_formatados{i,6} = dados{6}{i};
    end
    dados = dados_formatados;
end