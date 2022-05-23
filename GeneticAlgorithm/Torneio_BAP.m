function[x, f_x, z_x, T_x, t_x, machine_x] = Torneio_BAP(x, y, f_x, f_y, z_x, z_y, T_x, T_y, t_x, t_y, machine_x, machine_y)
% Section AG function, type 2elements tournament
% x,y - BAP allocations vectors
% f_x, f_y - Fitness of the allocations
% T_x, T_y - Mooring time of the allocation vectors (just for registry)
% t_x, t_y - Service time of the allocation vectors (just for registry)

if f_y > f_x
    x = y;
    f_x = f_y;
    z_x = z_y;
    T_x = T_y;
    t_x = t_y;
    machine_x = machine_y;
end    