# ⚓ Batalha Naval 3D (MATLAB)

Projeto académico desenvolvido em **MATLAB** no âmbito de curso de Engenharia, reinterpretando o clássico jogo da Batalha Naval num ambiente tridimensional interativo ($10 \times 10 \times 10$). O projeto conta com interface gráfica customizada, lógica de inteligência artificial (Singleplayer), controlos de posicionamento de frota e persistência de dados.

---

## 🚀 Funcionalidades Principais

- **Visualização Tridimensional Interativa:** Tabuleiros renderizados em 3D (`scatter3`) com suporte para rotação de câmara e identificação de acertos por cor.
- **Modos de Jogo:**
  - **2 Jogadores (Local):** Confronto direto entre dois jogadores no mesmo computador.
  - **Contra o Computador (Singleplayer):** Modo de jogo contra uma inteligência artificial integrada.
- **Distribuição de Frota:**
  - **Automática:** Algoritmo de alocação aleatória e validação de limites de espaço.
  - **Manual:** Sistema interativo de posicionamento através do teclado em ambiente 3D.
- **Frota Diversificada:**
  - **Caças** ($1 \text{ bloco}$)
  - **Fragatas** ($2 \text{ blocos}$)
  - **Contratorpedeiros** ($3 \text{ blocos}$)
  - **Cruzadores** ($4 \text{ blocos}$)
  - **Nave-Mãe** ($3 \times 3 \times 3 \text{ blocos}$)
- **Áudio e Efeitos Sonoros:** Integração de efeitos sonoros dinâmicos para início de partida, disparos certeiros, falhas e momentos de vitória.
- **Registo e Histórico:** Gravação automática dos resultados e dados das partidas num ficheiro de texto (`resultados.txt`), consultável a partir do menu principal.
- **Configurações:** Opção personalizável para exigir espaçamento de segurança entre navios vizinhos.

---

## 🎮 Como Executar

1. Certifica-te de que tens o **MATLAB** instalado.
2. Clona este repositório para o teu computador:
   ```bash
   git clone [https://github.com/TOMASNOZESS/JOGO_BATALHA_NAVAL_MATLAB.git](https://github.com/TOMASNOZESS/JOGO_BATALHA_NAVAL_MATLAB.git)
