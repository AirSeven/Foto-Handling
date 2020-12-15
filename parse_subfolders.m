s = dir;

for k = 3:length(s)
    if s(k).isdir
        cd(s(k).name);
        fprintf('\nCurrent Directory:\t\\%s\n',s(k).name);
        sort_by_date(2017,[12],[1:31],2,'*.jpg');
        sort_by_date(2018,[1:12],[1:31],2,'*.jpg');
        cd('..');
    end
end