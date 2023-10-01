import copy

def debug_show(result_file, show_str):
    #print (show_str)
    result_file.write(show_str)

spike_log_file = open("../program/spike.log", "r")
modelsim_log_file = open("sim/dut.core.log", "r")

result_file = open("result.log", "w")

start_addr = "0x000100dc"

spike_log = spike_log_file.readlines()
modelsim_log = modelsim_log_file.readlines()

spike_log_work = []
spike_log_tmp = []

flag_end = 0
i = 0
while(i < (len(spike_log))):
    flag_find = 0
    line = spike_log[i]
    words = line.split()
    # find start of command
    if (len(words) > 0 and words[0] == '(spike)' and flag_find == 0):
        k = copy.deepcopy(i)
        while (k < (len(spike_log)) and flag_find == 0):
            line = spike_log[k]
            words = line.split()
            # find command
            if (len(words) > 0 and words[0] == 'core' and flag_find == 0):
                #print(line)
                spike_log_tmp.append(line)
                t = copy.deepcopy(k)
                while (t < (len(spike_log)) and flag_find == 0):
                    line = spike_log[t]
                    words = line.split()
                    #find regs
                    if (len(words) > 0 and words[0] == 'zero:' and flag_find == 0):
                        for m in range(8):
                            #print(spike_log[t+m])
                            spike_log_tmp.append(spike_log[t+m])
                        flag_find = 1
                        tmp = t + 7
                        i = copy.deepcopy(tmp)
                    else:
                        t+=1
                if (flag_find == 0):
                    flag_end = 1
                    break
            else:
                k+=1
    if (flag_end):
        break
    else:
        i+=1

#for line in spike_log_tmp:
start = 0
i = 0
for i in range(len(spike_log_tmp)):
    line = spike_log_tmp[i]
    words = line.split()
    pos = line.find("0x")
    if words[2] == start_addr:
        start = 1
    if start:
        if (words[0] != 'core:'):
            remains = 80 - len(line[:-1])
            spike_log_work.append(line[:-1] + " " * remains)
        else:
            remains = 80 - len(line[pos:-1])
            spike_log_work.append(line[pos:-1] + " " * remains)
    i+=1


#for i in spike_log_work:
#    result_file.write(i + '\n')

modelsim_log_work = modelsim_log

max_len = max(len(spike_log_work), len(modelsim_log_work))

i = 0
try:
    while(i < max_len):
        spike_words = spike_log_work[i].split()
        modelsim_words = modelsim_log_work[i].split()
        show_str = "{0}   ::::   {1}".format(spike_log_work[i], modelsim_log_work[i])
        debug_show(result_file, show_str)
        if (spike_words[0] == 'core'):

            if (spike_words[2] != modelsim_words[1]):
                show_str = "ERROR: mismatch addresses\n"
                debug_show(result_file, show_str)
                break

            if (spike_words[3] != modelsim_words[2]):
                show_str = "ERROR: mismatch commands\n"
                debug_show(result_file, show_str)
                break
        else:
            if (spike_words[1] != modelsim_words[1] or \
                spike_words[3] != modelsim_words[3] or \
                spike_words[5] != modelsim_words[5] or \
                spike_words[7] != modelsim_words[7]):
                show_str = "ERROR: different register value\n"
                debug_show(result_file, show_str)
                break
        i+=1




except Exception as e:
    show_str = "different sizes: spike:{0}, modelsim:{1}\n".format(len(spike_log_work), len(modelsim_log_work))
    debug_show(result_file, show_str)
    pass

show_str = "PASS\n"
debug_show(result_file, show_str)
spike_log_file.close()
modelsim_log_file.close()
result_file.close()