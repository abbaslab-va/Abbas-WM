function ClasEx2FunRework(byte)
global BpodSystem

availableBytes = 1:5
validSelection = availableBytes(availableBytes ~= byte)

choose = randsample(validSelection, 1);

SendBpodSoftCode(choose)
disp(strcat('port active = ', num2str(choose));
