1.Questa Project compile
project comipleall

2.Simulation
vsim -novopt <tb_module_name>
vsim -novopt -suppress ALL <tb_module_name>

3.Simulation and FSM
vsim -voptargs=+acc -fsmdebug <tb_module_name>
vsim -suppress ALL -voptargs=+acc -fsmdebug <tb_module_name>
(Note:Use enum data type for states name to see FSM)
(Note: if you have used parameter as states name, then maybe you are not able to see FSM)
(Note: if you are going to try to see fsm in older .mpf, then it might not work in fancy lapi)

3.Simulation, FSM and RTL schematic
vsim -voptargs=+acc -fsmdebug -debugDB <tb_module_name>
vsim -suppress ALL -voptargs=+acc -fsmdebug -debugDB <tb_module_name>
sim>> left_click_<inst_name> >> Add to >> Schematic >> Full

## Coverage:


HOW TO SEE COVERAGE IN QUESTASIM:


1.Goto properties>coverage:.

![image](https://user-images.githubusercontent.com/88953654/178688466-7f0726ef-3c05-4bf3-a473-aca1b69bf4c7.png)

2.Mark all the options as shown in above:

3.Make do file:

quit -sim

project compileall

vlog -cover bst top_tb.sv

vsim -coverage -novopt top_TB

add wave *

run 5000

coverage report code all -html

![image](https://user-images.githubusercontent.com/88953654/178688672-86f3dff8-f2cb-4e95-9961-0ab07939c8d8.png)

![image](https://user-images.githubusercontent.com/88953654/178688709-c4375f5d-424a-4a81-9caa-c3c5a7105bb2.png)

4. Go INTO C:\questasim_10.1d\examples\covhtmlreport
OR
open: covhtmlreport/index.html

![image](https://user-images.githubusercontent.com/88953654/178688752-1328c358-478b-4de3-981c-8c9bc5dae1f7.png)

![image](https://user-images.githubusercontent.com/88953654/178688981-7592a92f-5f7a-47fb-abcf-e81048bf46c1.png)





