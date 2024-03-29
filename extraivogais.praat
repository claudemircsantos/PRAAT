################################################
#
#  Extrai vogais de um arquivo de áudio
#  
#  Claudemir C. Santos
#  claudemircsantos@uol.com.br 
#
################################################
# 
# Com este procedimento é possível automatizar a extração 
# de vogais de um sinal de áudio.
#
# 1. Clique no objeto contendo o áudio desejado e execute
#    o script extraivogais.praat;	
# 2. Ao final ele apresenta o TextGrid com as vogais encontradas.
#
# Este script é uma adaptação do material "vowelonset.v4b.praat" de
# Hugo Quené, https://www.hugoquene.nl/tools/index.html
#
################################################


include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	dur1 = Get total duration

	runScript: "workpre.praat"
	wrk = selected("Sound")
	dur2 = Get total duration
	sf = Get sampling frequency


writeInfoLine: "Iniciando o processo de extração ..."
	appendInfoLine: " "
	appendInfoLine: "###################################################################"
	appendInfoLine: "#"
	appendInfoLine: "#  Extrai vogais de um objeto contendo um arquivo de som"
	appendInfoLine: "#  "
	appendInfoLine: "#  Claudemir C. Santos"
	appendInfoLine: "#  claudemircsantos@uol.com.br "
	appendInfoLine: "#"
	appendInfoLine: "###################################################################"
	appendInfoLine: " "


include minmaxf0.praat
	appendInfoLine: "Variação de F0 "
	appendInfoLine: "- Max      : ",maxF0, " Hz"
	appendInfoLine: "- 3° Q     : ",fixed$(q3,0), " Hz"
	appendInfoLine: "-> Mediana : ",fixed$(mediana,0), " Hz"
	appendInfoLine: "- 1° Q     : ",fixed$(q1,0), " Hz"
	appendInfoLine: "- Min      : ",minF0, " Hz"
	appendInfoLine: " "
	pitch = noprogress To Pitch: 0.01, minF0, maxF0

	selectObject: wrk
	totalamostra = Get number of samples
	totaltempo = Get total duration
	txamostra = Get sampling frequency
	appendInfoLine: "Taxa de amostra: ", txamostra, " Hz"
	appendInfoLine: "Total de amostras: ",totalamostra," : ",fixed$(totaltempo,0)," s"
	
	if sf > 11025
		rs = Resample: 11025, 1
	appendInfoLine: "Foi realizada reamostragem para 11025 Hz"
	else
		rs = Copy: "tmp"
	endif
	
	appendInfoLine: " "
	appendInfoLine: "Iniciando busca por vogais ..."
        Filter with one formant (in-place): 1000, 500

	framelength = 0.01
	int_tmp = noprogress To Intensity: 60, framelength, "no"
	maxint = Get maximum: 0, 0, "Cubic"
	t1 = Get time from frame number: 1

	matrix_tmp = Down to Matrix
	endtime = Get highest x
	ncol = Get number of columns
	coldist = Get column distance
	h = 1
	newt1 = t1 + (h * framelength)
	ncol = ncol - (2 * h)

	matrix_intdot = Create Matrix: "intdot", 0, endtime, ncol, coldist, newt1, 1, 1, 1, 1, 1, "(object[matrix_tmp][1, col + h + h] - object[matrix_tmp][1, col]) / (2 * h * dx)"
	temp_intdot = noprogress To Sound (slice): 1
	temp_rises = noprogress To PointProcess (extrema): 1, "yes", "no", "Sinc70"

	selectObject: temp_intdot
	temp_peaks = noprogress To PointProcess (zeroes): 1, "no", "yes"
	npeaks = Get number of points

	selectObject: temp_peaks
	for i to npeaks
		ptime[i] = Get time from index: i
	endfor

	selectObject: int_tmp
	for i to npeaks
		pint[i] = Get value at time: ptime[i], "Nearest"
	endfor

	selectObject: pitch
	for i to npeaks
		voiced[i] = Get value at time: ptime[i], "Hertz", "Nearest"
	endfor

	selectObject: temp_rises
	vwn = 0
	for i to npeaks
		if pint[i] > (maxint - 12) and voiced[i] <> undefined
			rindex = Get low index: ptime[i]
			if rindex > 0
				rtime = Get time from index: rindex
				vwn += 1
				otime[vwn] = (rtime + ptime[i]) / 2
				ltime[vwn] = max(ptime[i] - rtime, 0.05)
			endif
		endif
	endfor

	removeObject: wrk, pitch, rs, int_tmp, matrix_tmp, matrix_intdot, temp_intdot, temp_rises, temp_peaks

	if vwn > 0
		appendInfoLine: " "
		appendInfoLine: "Detectadas ", vwn, " vogais ..."
		tg = Create TextGrid: 0, dur2, "vowels", ""
		int_n = 1
		last_time = 0
		for i to vwn
			dif_time = otime[i]-last_time
			if dif_time > 0
				Insert boundary: 1, otime[i]
				int_n += 1
				Set interval text: 1, int_n, "vw"+string$(i)
				last_time = otime[i]
				e_time = otime[i] + ltime[i]
				dif_time = e_time - last_time
				Insert boundary: 1, e_time
				int_n += 1
				last_time = e_time
			endif
		endfor
								
 		selectObject: s
		calcpointprocess = To PointProcess (periodic, cc): 75, 600
				
		appendInfoLine: " "
		tabelajittershimmer = Create Table with column names: "Vogais", 0, "vogal time_in ltime time_out jitter shimmer"
		row_index = 0
		int_n = 1
				
		for i to vwn
			int_n += 1
			e_time = otime[i] + ltime[i]
			
			selectObject: calcpointprocess
			calcjitter = Get jitter (local): otime[i], e_time, 0.0001, 0.02, 1.3
			
			selectObject: s
			plusObject: calcpointprocess
			calcshimmer = Get shimmer (local): otime[i], e_time, 0.0001, 0.02, 1.3, 1.6
			
			
			# Adiciona os valores na tabela
			select Table Vogais
			Insert row: row_index+1
			row_index = row_index+1
			
						

			Set string value: row_index, "vogal", "vw"+string$(i)
			Set numeric value: row_index, "time_in", number(fixed$(otime[i],4))
			Set numeric value: row_index, "ltime", number(fixed$(ltime[i],4))
			Set numeric value: row_index, "time_out", number(fixed$(e_time,4))
			

			if calcjitter != undefined
				Set numeric value: row_index, "jitter", number(fixed$(calcjitter,4))
			else
				Set string value: row_index, "jitter", "NA"
			endif
			
			if calcshimmer != undefined
				Set numeric value: row_index, "shimmer", number(fixed$(calcshimmer,4))
			else
				Set string value: row_index, "shimmer", "NA"
			endif
						
		endfor
		removeObject: calcpointprocess
		selectObject: s, tg
		View & Edit
		selectObject: tabelajittershimmer
		View & Edit



	else
		removeObject: wrk
		selectObject: s
		result = Copy: s$ + "-vowels"

	endif
	
	appendInfoLine: "* PROCESSO ENCERRADO *"
endproc
