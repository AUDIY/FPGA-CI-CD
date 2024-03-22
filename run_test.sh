#!/bin/bash

vlib work
vmap -work work
vlog rtl/*.sv rtl/*.v *.sv
vsim -c work.tb_uart -do "log -r /*; run -all"
