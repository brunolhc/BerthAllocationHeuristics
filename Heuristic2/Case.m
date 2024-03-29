%small test case, for preliminar tests

%test 1
N = 3;
B = 2;
M = 2;
size_pop = 10;
Ship(1).nome = 1;
Ship(2).nome = 2;
Ship(3).name = 3;
Ship(1).a = 0;
Ship(2).a = 0;
Ship(3).a = 2;
Ship(1).b = 10;
Ship(2).b = 10;
Ship(3).b = 10;
Ship(1).q = 100;
Ship(2).q = 100;
Ship(3).q = 200;
Machine(1).q = 4;
Machine(2).q = 3;
Machine(1).v = 20;
Machine(2).v = 30;
t_est = [2.5 3.3; 2.5 3.3; 5 6.7];

%Test 2
N = 7;
B = 3;
M = 2;
size_pop = 14;
Ship(1).nome = 1;
Ship(2).nome = 2;
Ship(3).name = 3;
Ship(4).name = 4;
Ship(5).name = 5;
Ship(6).name = 6;
Ship(7).name = 7;
Ship(1).a = 0;
Ship(2).a = 0;
Ship(3).a = 2;
Ship(4).a = 0;
Ship(5).a = 0;
Ship(6).a = 1;
Ship(7).a = 3;
Ship(1).b = 100;
Ship(2).b = 100;
Ship(3).b = 100;
Ship(4).b = 100;
Ship(5).b = 100;
Ship(6).b = 100;
Ship(7).b = 100;
Ship(1).q = 100;
Ship(2).q = 100;
Ship(3).q = 200;
Ship(4).q = 250;
Ship(5).q = 200;
Ship(6).q = 50;
Ship(7).q = 100;
Machine(1).q = 4;
Machine(2).q = 3;
Machine(1).v = 20;
Machine(2).v = 30;

%Test 3
Ship_qt = 7;
N = 7;
Berth_qt = 3;
B = 3;
Machine_qt = 2;
M=2;
size_pop = 50;
Ship(1).nome = 1;
Ship(2).nome = 2;
Ship(3).name = 3;
Ship(4).name = 4;
Ship(5).name = 5;
Ship(6).name = 6;
Ship(7).name = 7;
Ship(1).a = 0;
Ship(2).a = 0;
Ship(3).a = 2;
Ship(4).a = 0;
Ship(5).a = 0;
Ship(6).a = 1;
Ship(7).a = 3;
Ship(1).b = 100;
Ship(2).b = 100;
Ship(3).b = 100;
Ship(4).b = 100;
Ship(5).b = 100;
Ship(6).b = 100;
Ship(7).b = 100;
Ship(1).q = 100;
Ship(2).q = 100;
Ship(3).q = 200;
Ship(4).q = 250;
Ship(5).q = 200;
Ship(6).q = 50;
Ship(7).q = 100;
Machine(1).q = 4;
Machine(2).q = 3;
Machine(1).v = 20;
Machine(2).v = 30;
t_med = 26;
Ship_Alocation= [1 2 0 3 4 5 0 6 7]; 
machine_used =     [1     1;
     1     1;
     1     1;
     1     1;
     1     1;
     2     1;
     2     1;
     3     3;
     1     1;
     1     2;
     2     1;
     2     3;
     2     2;
     1     1];
 machine_used = machine_used';
a = 4;
b = 1;
max_it = 10;


% Test excel 8
Ship_qt = 9;
N = 9;
Berth_qt = 3;
B = 3;
Machine_qt = 3;
M=3;
size_pop = 50;
Ship(1).nome = 1;
Ship(2).nome = 2;
Ship(3).name = 3;
Ship(4).name = 4;
Ship(5).name = 5;
Ship(6).name = 6;
Ship(7).name = 7;
Ship(8).name = 8;
Ship(9).name = 9;

Ship(1).a = 2;
Ship(2).a = 0;
Ship(3).a = 0;
Ship(4).a = 4;
Ship(5).a = 3;
Ship(6).a = 1;
Ship(7).a = 1;
Ship(8).a = 0;
Ship(9).a = 1;

Ship(1).q = 80000;
Ship(2).q = 40000;
Ship(3).q = 80000;
Ship(4).q = 40000;
Ship(5).q = 80000;
Ship(6).q = 80000;
Ship(7).q = 80000;
Ship(8).q = 80000;
Ship(9).q = 80000;

Ship(1).b = 100;
Ship(2).b = 100;
Ship(3).b = 100;
Ship(4).b = 100;
Ship(5).b = 100;
Ship(6).b = 100;
Ship(7).b = 100;
Ship(8).b = 100;
Ship(9).b = 100;

Machine(1).q = 6;
Machine(2).q = 4;
Machine(3).q = 3;

Machine(1).v = 1000*24;
Machine(2).v = 1500*24;
Machine(3).v = 1800*24;
a = 4;
b = 1;
max_it = 3;
size_pop = 20;
