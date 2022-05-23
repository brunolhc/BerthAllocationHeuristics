function[fifo_aloc] = MatrixSolToVectorial(Ship_qt, Berth_qt, Aloc)

k = 1; i = 1; count = 1; count2 = 0; fifo_aloc = zeros(Ship_qt+Berth_qt-1,1);
while count <= Ship_qt+Berth_qt-1 && count2 < Ship_qt
    if Aloc(i,k) == 0
        if i ~= 1
            count = count+1; i = 1;
        end
        k = k+1;
    else
        fifo_aloc(count) = Aloc(i,k);
        i = i+1; count = count+1; count2 = count2+1;
    end
end