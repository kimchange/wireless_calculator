load('highpass.mat');
load('lowpass.mat');
load('bandpass.mat');

fun=input('输入算式：\n','s');%turn string to numbers

% Verify input validity
try
    result = eval(fun);
catch
    disp('Syntax Error !')
end

fun_binary_str = dec2bin(fun,7);

% fun_binary_str = str2num( fun_binary_str );


fun_binary_str_row = reshape(fun_binary_str',1,length(fun_binary_str(:)));

fun_binary_row = str2num(fun_binary_str_row')';

fun_binary_code=encode(fun_binary_row,7,4,'hamming/binary');
% decode(fun_binary_code,7,4,'hamming/binary')

msg = zeros( 1,400+length(fun_binary_code)*400);

dt=1.2500e-004;
t=dt:dt:400*dt;
SIN1 = sin(2*pi*1000*t);
SIN2 = sin(2*pi*200*t).*0;

msg(1:400) = 10*SIN1;
for ii = 2:(length(fun_binary_code)+1)
    if(fun_binary_code(ii-1) == 1)
        msg(1+400*(ii-1):400*ii) = 10*SIN1;
    else
        msg(1+400*(ii-1):400*ii) = 10*SIN2;
    end
end

head=[SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1,SIN1];
sound(head,20000);
disp('呼叫中…')
pause(0.4+1+0.5);

sound(msg,16000);
disp('发送中…');

% pause(length(msg(:))/8000);
pause(5.5);
disp('发送结束，准备接收!');

% plot(app.UIAxes,msg);
% hold(app.UIAxes,'on')
% judge = zeros(1,length(msg));
% judge(200:400:length(msg)) = 12;
% plot(app.UIAxes,judge);
% hold(app.UIAxes,'off');

figure(1)
plot(msg)
title('发送信息波形')
xlabel('t')
ylabel('msg')
hold on
judge = zeros(1,400*120);
judge(200:400:length(msg)) = 12;
plot(judge)
hold off

voicing_receive = audiorecorder(16000,16,1);
recordblocking(voicing_receive, 5);
voice = getaudiodata(voicing_receive);

% bp = fir1(48,[0.16,0.28]);
% voice= filter(bp,1,voice);
voice_h = filter(bandpassvector,1,voice);
voice_l = filter(Lowpassvector,1,voice);

am_h = abs(hilbert(voice_h));% 包络
am_l = abs(hilbert(voice_l));

% 抽样判决
voice_1 = find(am_h > 0.3*max(am_h));
for ii = 1:400
    if (voice_1(ii) + 1 == voice_1(ii+1) & voice_1(ii+1) + 1 == voice_1(ii+2) & ...
            voice_1(ii+2) + 1 == voice_1(ii+3) & voice_1(ii+3) + 1 == voice_1(ii+4) & ...
            voice_1(ii+4) + 1 == voice_1(ii+5) & voice_1(ii+5) + 1 == voice_1(ii+6) & ...
            voice_1(ii+6) + 1 == voice_1(ii+7) & voice_1(ii+7) + 1 == voice_1(ii+8) & ...
            voice_1(ii+8) + 1 == voice_1(ii+9) & voice_1(ii+40) + 61 == voice_1(ii+101) & ...
            voice_1(ii) +75 == voice_1(ii+75) ...
            )
        msg_begin = voice_1(ii);
        break;
    end
end

% msg_receive = double( (am(msg_begin + 400:800:msg_begin + 800*79 +400)>0.2*max(am)) );

sample_t = 200;

msg_receive = double( (am_h(msg_begin + sample_t:400:msg_begin + 400*119 +sample_t) > ...
    0.3*max(am_h)));
% ( am_l(msg_begin + sample_t:400:msg_begin + 400*119 +sample_t) )) );

msg_receive = msg_receive(2:end);

[msg_receive_decode,err] = decode(msg_receive,7,4,'hamming/binary');

err_sum = sum(err); % 总的误码个数

BER = err_sum/length(msg_receive)

fun_binary_num = zeros(7,30);

msg_receive_decode_row_0 = [msg_receive_decode',zeros(1,119 - length(msg_receive_decode))];

for ii = 1:119
    fun_binary_num(ii) = msg_receive_decode_row_0(ii);
end

% plot(app.UIAxes2,voice_h);
% hold(app.UIAxes2,'on')
% judge = zeros(1,400*80);
% judge(msg_begin+sample_t:400:msg_begin + 400*119 +sample_t) = max(am_h);
% plot(app.UIAxes2,judge);
% hold(app.UIAxes2,'off');

figure(2);
plot(voice_h)
title('接收信息波形')
xlabel('t')
ylabel('voice')
hold on
judge = zeros(1,400*120);
judge(msg_begin+sample_t:400:msg_begin + 400*119 +sample_t) = max(am_h);
plot(judge)
hold off


fun_binary_num = fun_binary_num';

fun_binary_str = num2str(fun_binary_num,'%d');

fun_dec = bin2dec(fun_binary_str);

result_receive = eval(char(fun_dec)')

% app.TextArea2.Value = char(fun_dec)';
% app.TextArea2.Value = {char(fun_dec)';['BER = ',num2str(BER)]};
disp('误码率:')
BER