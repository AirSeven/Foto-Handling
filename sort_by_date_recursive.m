function sort_by_date_recursive(yearvec,monthvec,dayvec,timeshift,ext)

% read current directory
s = dir;

for k = 3:length(s)
    if s(k).isdir
        % change directory
        cd(s(k).name);
        fprintf('\nCurrent Directory:\t\\%s\n',s(k).name);
        % call sort_by_date
        sort_by_date(yearvec,monthvec,dayvec,timeshift,ext);
        % recursive call
        sort_by_date_recursive(yearvec,monthvec,dayvec,timeshift,ext);
        % change back
        cd('..');
    end
end