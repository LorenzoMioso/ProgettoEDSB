for i = 1:2:13
EEG.event(i).type = 2;
EEG.urevent(i).type = 2;
end

for i = 2:2:13
EEG.event(i).type = 4;
EEG.urevent(i).type = 4;
end
