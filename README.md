################################################
#
#  Extrai formantes de vogais selecionadas com TextGrid
#
################################################
# 
# Com este procedimento é possível automatizar a extração dos formantes de vogais previamente selecionadas pelo analista.
#
# 1. Crie um objeto do tipo "formant" para aquele som;
# 2. Muita atenção na configuração do número de formantes # e no alcance do espectro.
#
# Marque os intervalos que deseja analisar em um Textgrid:
#
# ~~~~~~~~ ------ ~~~~~~~ --- ~~~~~~~~ ---
# __________________________________
# | ah | | ih | | eh |
#
#
#  Abra o item do menu <PRAAT> e em seguida clique em <NEW SCRIPT>. Copie o código do script e execute com <RUN>.
#
#  Você irá observar a criação de um objeto contendo a tabela com os valores dos formantes.
################################################
