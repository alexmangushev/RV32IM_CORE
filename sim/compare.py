def debug_show(result_file, show_str):
    print (show_str)
    result_file.write(show_str)

spike_log_file = open("../program/spike.log", "r")
modelsim_log_file = open("sim/dut.log", "r")

result_file = open("result.log", "w")

start_addr = "0x000100dc"

spike_log = spike_log_file.readlines()
modelsim_log = modelsim_log_file.readlines()

spike_log_work = []

start = 0
for line in spike_log:
    words = line.split()
    pos = line.find("0x")
    if words[2] == start_addr:
        start = 1
    if start:
        remains = 60 - len(line)
        spike_log_work.append(line[pos:-1] + " " * remains)


modelsim_log_work = []

start = 0
for line in modelsim_log:
    words = line.split()
    pos = line.find("0x")
    if words[1] == start_addr:
        start = 1
    if start:
        if (len(words) == 3):
            string = line[pos: -1]
            string += "     {0}\n".format(words[0])
            modelsim_log_work.append(string)
    #print (words)

max_len = max(len(spike_log_work), len(modelsim_log_work))

try:
    for i in range(max_len):
        spike_words = spike_log_work[i].split()
        modelsim_words = modelsim_log_work[i].split()
        show_str = "{0}   ::::   {1}".format(spike_log_work[i], modelsim_log_work[i])
        debug_show(result_file, show_str)

        if (spike_words[0] != modelsim_words[0]):
            show_str = "ERROR: mismatch addresses\n"
            debug_show(result_file, show_str)
            break

        if (spike_words[1] != modelsim_words[1]):
            show_str = "ERROR: mismatch commands\n"
            debug_show(result_file, show_str)
            break

except Exception as e:
    show_str = "different sizes: spike:{0}, modelsim:{1}\n".format(len(spike_log_work), len(modelsim_log_work))
    debug_show(result_file, show_str)
    pass

show_str = "PASS\n"
debug_show(result_file, show_str)
spike_log_file.close()
modelsim_log_file.close()
result_file.close()