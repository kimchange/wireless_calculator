y1 = msg(401:end).*msg(1:end-400);
y1 = filter(Lowpassvector,1,y1);
msg_1 = double(y1(200:400:end-200)<0);
decode(msg_1,7,4,'hamming/binary')