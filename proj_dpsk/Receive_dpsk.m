flag = 0;
load('lowpass.mat');
load('highpass.mat');
load('bandpass.mat');

% app.TextArea.Value = '等待中';
% app.TextArea2.Value = '等待中';
disp('等待中');

while(flag==0)
    
    voicing = audiorecorder(20000,16,1);
    recordblocking(voicing, 0.5);
    voice = getaudiodata(voicing);
    
    voice = filter(bandpassvector,0.18,voice);
    am = abs(hilbert(voice));% 包络
    
    voice_0 = find(am > 0.15);
    % disp('lab')
    % length(voice_0)
    if (max(abs(voice)) > 0.15 & length(voice_0) > 200)
        flag=1;
        pause(0.3);
        disp('已接通，开始接收信息…')
        % app.TextArea.Value = '已接通，开始接收信息…';
    end
end


voicing = audiorecorder(16000,16,1);
recordblocking(voicing, 6);
voice = getaudiodata(voicing);


voice = filter(bandpassvector,0.25,voice);

am = abs(hilbert(voice));% 包络

% 找起始点
voice_1 = find(am > 0.3*max(am));
for ii = 1:400
    if (voice_1(ii) + 1 == voice_1(ii+1) & voice_1(ii+1) + 1 == voice_1(ii+2) & ...
            voice_1(ii+2) + 1 == voice_1(ii+3) & voice_1(ii+3) + 1 == voice_1(ii+4) &...
            voice_1(ii+4) + 1 == voice_1(ii+5) & voice_1(ii+5) + 1 == voice_1(ii+6) &...
            voice_1(ii+6) + 1 == voice_1(ii+7) & voice_1(ii+7) + 1 == voice_1(ii+8) &...
            voice_1(ii+8) + 1 == voice_1(ii+9) & voice_1(ii+9) + 1 == voice_1(ii+10) )
        msg_begin = voice_1(ii);
        break;
    end
end

y1 = voice(msg_begin+400:end).*voice(msg_begin:end-400);
y1 = filter(Lowpassvector,1,y1);
msg = double( (y1( 200:400: 400*118 +200) < 0.1*min(y1)) );

figure(1);
plot(y1)
title('差分相干解调')
xlabel('t')
ylabel('y1')
% hold on
% judge = zeros(1,400*120);
% judge(msg_begin+250:400:msg_begin + 400*119 +250) = max(am);
% plot(judge)
% hold off


[msg_decode,err] = decode(msg,7,4,'hamming/binary');

err_sum = sum(err); % 总的误码个数

disp('误码率BER:')

BER = err_sum/length(msg)

fun_binary_num = zeros(7,30);

msg_decode_row_0 = [msg_decode',zeros(1,119 - length(msg_decode))];

for ii = 1:119
    fun_binary_num(ii) = msg_decode_row_0(ii);
end


fun_binary_num = fun_binary_num';

fun_binary_str = num2str(fun_binary_num,'%d');


fun_dec = bin2dec(fun_binary_str);

disp(char(fun_dec)')

% app.TextArea.Value = char(fun_dec)';

result = eval(char(fun_dec)')

result_str = num2str(result);

% app.TextArea2.Value = result_str;

% app.TextArea2.Value = {result_str;['BER = ',num2str(BER)]};

result_binary_str = dec2bin(result_str,7);

result_binary_str_row = reshape(result_binary_str',1,length(result_binary_str(:)));

result_binary_row = str2num(result_binary_str_row')';

result_binary_code=encode(result_binary_row,7,4,'hamming/binary');

result_binary_code_dpsk = dpskmod(result_binary_code,2);

msg = zeros( 1,400+length(result_binary_code_dpsk)*400);

dt=1.2500e-004;
t=dt:dt:400*dt;
SIN1 = sin(2*pi*1000*t);

msg(1:400) = 10*SIN1;
for ii = 2:(length(result_binary_code_dpsk)+1)
    if(real(result_binary_code_dpsk(ii-1)) == 1)
        msg(1+400*(ii-1):400*ii) = 10*SIN1;
    else
        msg(1+400*(ii-1):400*ii) = -10*SIN1;
    end
end


% 开始回发结果
pause(1);
sound(msg,16000);

% plot(app.UIAxes,msg);
% hold(app.UIAxes,'on')
% judge = zeros(1,length(msg));
% judge(200:400:length(msg)) = 12;
% plot(app.UIAxes,judge);
% hold(app.UIAxes,'off');

figure(2)
plot(msg)
title('回发信息波形')
xlabel('t')
ylabel('msg')
hold on
judge = zeros(1,400*120);
judge(200:400:length(msg)) = 12;
plot(judge)
hold off









