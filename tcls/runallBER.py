#runtcl1st if no report
#make plot
#
#rerun runtclscript add points to report
#update plot
#
#ideally refresh plot every minute

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

import time
import subprocess

def makeplot(inputtxt, linkname, plotbase, tag):

  with open(inputtxt, "r") as f:
      lines = (line for line in f if not any(line.startswith(c) for c in '@#'))
      date,time,pattern,ber,bits = np.genfromtxt(lines, dtype=str, usecols=(0,1,2,3,4), unpack=True, encoding='utf-8')

  print (date,time,pattern,ber,bits) 
  
  ber_f = ber
  bits_f = bits
  if type(ber) is np.str_:
     ber_f = [float(ber)]
     bits_f = [float(bits_f)]
     time = [time]
     date = [date]
     pattern = [pattern]
  else: 
     ber_f = [float(ber[i]) for i in range(len(ber))]
     bits_f = [float(bits[i]) for i in range(len(bits))]

  fig, ax1 = plt.subplots()
  
  color = 'tab:red'
  ax1.set_xlabel('time', fontsize = 15, color='black')
  ax1.set_ylabel('received bits', fontsize = 15, color=color)
  ax1.plot(time, bits_f, 'C0o', alpha=0.5, color=color)
  ax1.set_yscale('log')
  ax1.tick_params(axis='y', direction='in', which='both', colors=color)
  
  plt.xticks(rotation=45)
  plt.figtext(0.4, 0.6, '%s, link %s, %s PRBS' %(date[0], linkname, pattern[0]) )
  
  ax2 = ax1.twinx()  # instantiate a second axes that shares the same x-axis
  
  color = 'tab:blue'
  ax2.set_ylabel('bit error rate', fontsize = 15, color=color)  # we already handled the x-label with ax1
  ax2.plot(time, ber_f, 'C0o', alpha=0.5, color=color)
  ax2.set_yscale('log')
  ax2.tick_params(axis='y', direction='in', which='both', colors=color)
  
  fig.tight_layout()  # otherwise the right y-label is slightly clipped
  
  fig.savefig(plotbase + tag + "_link" + linkname + "_" + pattern[0] + ".png") 
  fig.savefig(plotbase + tag + "_link" + linkname + "_" + pattern[0] + ".pdf") 

  #plt.show()
  return ber_f[-1]

# execute tcl script to get bit error rate
# vivado -nojournal -nolog -mode batch -notrace -source getBER.tcl -tclargs 1 0 \
# "/net/top/homes/hmei/ODMB/odmbDevelopment/ibert_ultrascale_gth_0_ex/ibert_ultrascale_gth_0_ex.runs/impl_1/example_ibert_ultrascale_gth_0" 
# 
# tclargs: reprogram FPGA if 1, number of links, bit file path 

tclScriptBase = 'vivado -nojournal -nolog -mode batch -notrace -source ./getBER.tcl -tclargs '  
bitfile = '/net/top/homes/hmei/ODMB/odmbDevelopment/ibert_ultrascale_gth_0_ex/ibert_ultrascale_gth_0_ex.runs/impl_1/example_ibert_ultrascale_gth_0'
reportfilebase = 'reports/report_'
plotbase = 'plots/'
uniqueTag = '20200612_ber_v3'
nlinks = 2

currentBER = 1

while currentBER > 1e-12:

    cmd = tclScriptBase + " " + str(int(currentBER)) + " " +  str(nlinks) + " " +  bitfile + " " +  uniqueTag
    process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    print (stdout, stderr)

    for i in range(nlinks):

      reportname = reportfilebase + uniqueTag + "_link" + str(i) + ".out" 
      currentBER = makeplot(reportname, str(i), plotbase, uniqueTag)     

    print ("currentBER: ", currentBER)
    time.sleep(120)

