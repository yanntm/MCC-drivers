#! /usr/bin/env python3

import json
import os
import os.path
import subprocess
import sys
import time

import nupn

##################################################################################

def print_result(nb_states, marking, place):
  tech = 'TECHNIQUES DECISION_DIAGRAMS SEQUENTIAL_PROCESSING'
  print('STATE_SPACE STATES', nb_states, tech)
  print('STATE_SPACE TRANSITIONS', -1, tech)
  print('STATE_SPACE MAX_TOKEN_PER_MARKING', marking, tech)
  print('STATE_SPACE MAX_TOKEN_IN_PLACE', place, tech)

##################################################################################

# Don't print to stdout
# TODO: prepend with date
printerr = lambda *x : print(*x, file=sys.stderr)

##################################################################################

os.environ['LD_LIBRARY_PATH']="/usr/local/lib:/usr/local/lib64:" + os.environ.get('LD_LIBRARY_PATH', default="")

printerr(os.environ)

##################################################################################

# We only compete in the StateSpace category.
if os.environ['BK_EXAMINATION'] != 'StateSpace':
  print("DO_NOT_COMPETE")
  sys.exit(0)


##################################################################################

# Some common paths and names
model_name = os.environ['BK_INPUT']
model_file = os.path.join(os.path.abspath(os.getcwd()), 'model.pnml')
binpath = os.environ['BK_BIN_PATH']
orders_dir = binpath + '/orders'
pnmc = binpath + '/pnmc'
caesar = binpath + '/caesar.sdd'
results_file = 'results.json'
model_bpn_file = os.path.join(os.path.abspath(os.getcwd()), 'model.bpn')

##################################################################################

##################################################################################

# We don't handle colored models.
with open('iscolored', 'r') as is_colored_file:
  if is_colored_file.read().rstrip() == "TRUE":
    cli = [ binpath+ '/../itstools/its-tools'
        , '-pnfolder' , '.'
        , '-examination', 'StateSpace'
        , '--reduce', 'STATESPACE'
        ]  
    # Launch itstools to unfold
    printerr(cli)
    subprocess.call(cli, stdout=sys.stderr)
    # patch resulting file name
    os.system("mv model.pnml model.COL.pnml")
    os.system("mv model.STATESPACE.pnml model.pnml")
    


# Is it a known model?
# known = not os.path.isfile(os.path.join(os.path.abspath(os.getcwd()), 'NewModel'))
# printerr('Known', known)

known = False


##################################################################################

# First check if we have a model with a NUPN tool specific section
try:

  printerr('Running NUPN extraction with model='+model_file+' and bpn='+model_bpn_file)
  nupn.parse(model_file, model_bpn_file)

  # Common command line arguments for both known and unknown models.
  cli = [ caesar
        , '--show-nb-states'
        , model_bpn_file]
  printerr(cli)
  output = subprocess.check_output(cli)

  # Export results to BenchKit
  nb_states = output.decode('ascii').split()[0]
  print_result(nb_states, -1, -1)
  sys.exit(0)

# Not a NUPN model or caesar.sdd failed.
except Exception as e:

  printerr(e)

  # Common command line arguments for both known and unknown models.
  cli = [ pnmc
        , '--cache-size=hom:16000000,sum:16000000,inter:8000000,diff:8000000'
        # , '--json=stats'
        # , '--time-limit=1'
        , '--format=pnml'
        , '--count-tokens'
        , model_file
        ]  

  if known:

    # Construct command line arguments for known models
    order_file = os.path.join(orders_dir, model_name + '.pnml.json')
    if os.path.isfile(order_file):
      cli.append('--order-load=' + order_file)
    else:
      cli.append('--order-force')

    # Launch pnmc.
    printerr(cli)
    subprocess.call(cli, stdout=sys.stderr)

  else: # Unknown

    cli.append('--order-force')

    # Launch pnmc
    printerr(cli)
    ret = subprocess.call(cli, stdout=sys.stderr)

    # Check if pnmc correctly finished.
    if ret != 0:
      printerr('pnmc failed with return code ' + ret)
      print('CANNOT COMPUTE')
      sys.exit(0)
    
    while not os.path.exists(results_file):
      time.sleep(1/10) # 1/10 second

  # Export results to BenchKit
  try:
    with open(results_file, 'r') as f:
      results = json.load(f)
      nb_states = results['pnmc']['states']
      marking = results['pnmc']['max number of tokens per marking']
      place  = results['pnmc']['max number of tokens in a place']
      print_result(nb_states, marking, place)
  except FileNotFoundError:
      print('CANNOT COMPUTE')
      sys.exit(0)

  sys.exit(0)
