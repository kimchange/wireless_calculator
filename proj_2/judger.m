hold on
judge = zeros(1,length(am));
judge(msg_begin + 250:400:msg_begin + 400*99 +250) = 1.5;
stem(judge)