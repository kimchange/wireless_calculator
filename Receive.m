% function Receive

% Check whether the signal is sent
flag = 0;
while(flag==0)
    
    voicing = audiorecorder(8000,16,1);
    recordblocking(voicing, 0.1);
    voice = getaudiodata(voicing);

    voice=abs(voice);
    if max(voice) > 0.3
        flag=1;
        pause(0.3);
        disp('已接通，开始接收信息…')
    end
end


voicing = audiorecorder(8000,16,1);
recordblocking(voicing, 5);
voice = getaudiodata(voicing);

% voice = abs(voice);
% for ii = 1:9000*5
%     if voice(ii) > 0.6
%         voice(ii) = 0.6;
%     end
% end

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

msg = double( (am(msg_begin + 200:400:msg_begin + 400*79 +200)>0.3*max(am)) );

fun_binary_num = zeros(6,80);

for ii = 1:80
    fun_binary_num(ii) = msg(ii);
end

fun_binary_num = fun_binary_num';

fun_binary_str = num2str(fun_binary_num,'%d');

fun_dec = bin2dec(fun_binary_str);

result = eval(char(fun_dec)')

result_str = num2str(result);

result_binary_str = dec2bin(result_str);

result_binary_str_row = reshape(result_binary_str',1,length(result_binary_str(:)));

msg = zeros( 1,length(result_binary_str_row)*400);

dt=1.2500e-004;
t=dt:dt:400*dt;
SIN1 = sin(2*pi*1000*t);
SIN2 = sin(2*pi*500*t);

for ii = 1:length(result_binary_str_row)
    if(result_binary_str_row(ii) == '1')
        msg(1+400*(ii-1):400*ii) = 10*SIN1;
    else
        msg(1+400*(ii-1):400*ii) = 10*SIN2;
    end
end

% 开始回发结果
sound(msg,8000);



