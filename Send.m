% function Send
GG=0;%控制循环结束标志，若接收到的最后结果正确，将其置位，结束循环

fun=input('输入算式：\n','s');%turn string to numbers

% Verify input validity
try
    result = eval(fun);
catch
    disp('Syntax Error !')
end

fun_binary_str = dec2bin(fun);

% fun_binary_str = str2num( fun_binary_str );

fun_binary_str_row = reshape(fun_binary_str',1,length(fun_binary_str(:)));

msg = zeros( 1,length(fun_binary_str_row)*400);

dt=1.2500e-004;
t=dt:dt:400*dt;
SIN1 = sin(2*pi*1000*t);
SIN2 = sin(2*pi*500*t);

for ii = 1:length(fun_binary_str_row)
    if(fun_binary_str_row(ii) == '1')
        msg(1+400*(ii-1):400*ii) = 10*SIN1;
    else
        msg(1+400*(ii-1):400*ii) = 10*SIN2;
    end
end

head=[SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1];
sound(head,8000);
disp('呼叫中…')
pause(0.4+1);

sound(msg,8000);
disp('发送中…');

% pause(length(msg(:))/8000);
pause(5);
disp('发送结束，准备接收!');

voicing_receive = audiorecorder(8000,16,1);
recordblocking(voicing_receive, 5);
voice = getaudiodata(voicing_receive);

bp = fir1(48,[0.16,0.28]);
voice= filter(bp,1,voice);

am = abs(hilbert(voice));% 包络

% 抽样判决
voice_1 = find(am > 0.3*max(am));
for ii = 1:400
    if (voice_1(ii) + 1 == voice_1(ii+1) & voice_1(ii+1) + 1 == voice_1(ii+2))
        msg_begin = voice_1(ii);
        break;
    end
end

msg_receive = double( (am(msg_begin + 200:400:msg_begin + 400*79 +200)>0.3*max(am)) );

fun_binary_num = zeros(6,80);

for ii = 1:80
    fun_binary_num(ii) = msg_receive(ii);
end

fun_binary_num = fun_binary_num';

fun_binary_str = num2str(fun_binary_num,'%d');

fun_dec = bin2dec(fun_binary_str);

result_receive = eval(char(fun_dec)')


% end



