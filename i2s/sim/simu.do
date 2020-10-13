quit -sim

vlib work

vcom -reportprogress 300 -work work {i2s_reader.vhd}

vcom -reportprogress 300 -work work {i2s_reader_tb.vhd}

vsim work.i2s_reader_tb

add wave sim:/i2s_reader_tb/u/*

run -all
