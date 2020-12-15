function sort_by_date(yearvec,monthvec,dayvec,timeshift,ext)

% scans current directory for files with extension ext and sorts them by
% year, month and day. Therefore, vectors of years, months and days are to
% be provided as search criteria. The additional parameter timeshift [h]
% allows to open a new folder for the same day if more than timeshift hours
% are between one set of files and the next.
%
% syntax:        sort_by_date(yearvec,monthvec,dayvec,timeshift,ext)
% usage example: sort_by_date(2013,[1:12],[1:31],2,'*.jpg')

%% Initialization
bFound = 0;

%% Scan current directory
fprintf('\nScanning current directory for Media (%s)...',ext);
s = dir(ext);
fprintf('done!');

%% Loop years, months and dates
fprintf('\nReading EXIF Data...');
for k = 1:length(s)
    % initialize EXIF flag
    bExif = 1;
    %     % try to get EXIF data
    %     strctImf = imfinfo(s(k).name);
    try
        % extract EXIF record date
        DateVecs(k,:) = extract_datetime_from_exif(s(k).name); %#ok<*AGROW>
    catch
        % no EXIF data available. Set flag.
        bExif = 0;
        DateVecs(k,:) = [0 0 0 0 0 0];
    end
    if any(DateVecs(k,:) < 0)
        % no EXIF data available. Set flag.
        bExif = 0;
        DateVecs(k,:) = [0 0 0 0 0 0];
    end        
    if ~bExif
        % skip this file and display a warning (no EXIF data)
        fprintf('\n\t\t### WARNING: File "%s":\tEXIF Record Date missing! ###',s(k).name);
        continue;
    end
end
if ~exist('DateVecs')
    fprintf('done! No data. Operation canceled.\n');
    return;
end
fprintf('done!');
for y = yearvec
    for m = monthvec
        for d = dayvec
            ix = find(DateVecs(:,1)==y&DateVecs(:,2)==m&DateVecs(:,3)==d);
            if isempty(ix)
                continue;
            end
            bFound = 1;
            ix_tmp = find(diff(DateVecs(ix,4))>=timeshift);
            if ~isempty(ix_tmp)
                ix_sub = [0 ix_tmp' length(ix)];
                ix_count = 0;
                for sd = 1:length(ix_sub)-1
                    ix_count = ix_count + 1;
                    strngDir = sprintf('%u-%02.0f\\%u-%02.0f-%02.0f %02.0f',y,m,y,m,d,ix_count);
                    mkdir(pwd,strngDir);
                    fprintf('\n  Creating subdirectory %s...done!',strngDir);
                    fileIx = ix(ix_sub(sd)+1:ix_sub(sd+1));
                    s_sub = s(fileIx);
                    fprintf('\n    Moving files...');
                    for k = 1:length(s_sub)
                        fprintf('\n      %s',s_sub(k).name);
                        movefile([pwd,'\',s_sub(k).name],[pwd,'\',strngDir,'\',s_sub(k).name],'f');
                    end
                    % --- Rename newly created folder acc. to pic examples
                    if (ismember(upper(ext),{'*.JPG','*.JPEG','*.PNG','*.GIF','*.BMP','*.TIF'}))
                        % show pics
                        fg = figure('NumberTitle','Off','Name',strngDir);
                        set(fg, 'Position', get(0,'ScreenSize'));
                        for n=1:min(length(s_sub),6)
                            subplot(2,3,n);
                            imshow([pwd,'\',strngDir,'\',s_sub(n).name]);
                        end
                        % request Description
                        strngDesc = inputdlg('Short Description:');
                        close(fg);
                        % rename folder (delete if Description == 'XXX')
                        if strcmp(strngDesc,'XXX')
                            rmdir([pwd,'\',strngDir],'s');
                            fprintf('\nDirectory "%s" selected to be removed by user.',[pwd,'\',strngDir]);
                        else
                            movefile([pwd,'\',strngDir],[pwd,'\',strngDir,'_',strngDesc{:}]);
                            fprintf('\n Renamed Directory to "%s", Next!',[pwd,'_',strngDesc{:}]);
                        end
                        % ---
                    end
                    fprintf('\n    ...done!');
                end
            else
                strngDir = sprintf('%u-%02.0f\\%u-%02.0f-%02.0f',y,m,y,m,d);
                mkdir(pwd,strngDir);
                fprintf('\n  Creating subdirectory %s...done!',strngDir);
                fprintf('\n    Moving files...');
                for k = ix'
                    fprintf('\n      %s',s(k).name);
                    movefile([pwd,'\',s(k).name],[pwd,'\',strngDir,'\',s(k).name],'f')
                end
                if (ismember(upper(ext),{'*.JPG','*.JPEG','*.PNG','*.GIF','*.BMP','*.TIF'}))
                    % --- Rename newly created folder acc. to pic examples
                    % show pics
                    fg = figure('NumberTitle','Off','Name',strngDir);
                    set(fg, 'Position', get(0,'ScreenSize'));
                    for n=1:min(length(ix),6)
                        subplot(2,3,n);
                        imshow([pwd,'\',strngDir,'\',s(ix(n)).name]);
                    end
                    % request Description
                    strngDesc = inputdlg('Short Description:');
                    close(fg);
                    % rename folder (delete if Description == 'XXX')
                    if strcmp(strngDesc,'XXX')
                        rmdir([pwd,'\',strngDir],'s');
                        fprintf('\nDirectory "%s" selected to be removed by user.',[pwd,'\',strngDir]);
                    else
                        movefile([pwd,'\',strngDir],[pwd,'\',strngDir,'_',strngDesc{:}]);
                        fprintf('\n Renamed Directory to "%s", Next!',[pwd,'_',strngDesc{:}]);
                    end
                    % ---
                end
                fprintf('\n    ...done!');
            end
        end
    end
end
fprintf('\n');
if ~bFound
    fprintf('<No files matching the search patterns>\n');
end
