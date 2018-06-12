clear all;
close all;

pkg load instrument-control;

s = serial('COM6');

set(s, 'baudrate', 57600);     % See List Below
set(s, 'bytesize', 8);        % 5, 6, 7 or 8
set(s, 'parity', 'n');        % 'n' or 'y'
set(s, 'stopbits', 1);        % 1 or 2
set(s, 'timeout', 123);     % 12.3 Seconds as an example here

%set(s,'InputBufferSize',100);
%set(s,'flowcontrol','hardware');
%set(s,'baudrate',57600);
%set(s,'parity','none');
%set(s,'DataBits',8);
%set(s,'stopbit',1);
%set(s,'timeout',10);
%disp(get(s,'name'));
%prop(1)-(get(s,'baudrate'));
%prop(2)-(get(s,'DataBits'));
%prop(3)-(get(s,'StopBit'));
%prop(4)-(get(s,'InputBufferSize'));
%disp(['Port Setup Done!!',num2str(prob)]);
fopen(s);
t=1;
disp('Running');
x=0;
while(t<2000)
    a = srl_read(s,1);
    a= max(a);
    x = [x a];
    
    plot(x);
    axis auto;
    grid on;
    title('Leitura Serial');
    xlabel('Tempo em (S)')
    ylabel('Qtd de Luz')
    h.XDataSource = 'x';
    h.YDataSource = 'y';
    grid on;
    ylim([0 300])
    disp([num2str(t),'th iteration max= ',num2str(a)]);
    hold on;
    t = t+1;
    a = 0;
    drawnow;
end
fclose(s);

